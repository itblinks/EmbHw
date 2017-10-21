--------------------------------------------------------------
-- File: LCDCtrl.vhd
-- Rev: 0.9
-- Date: 09.10.2017
-- Author: Mario Fischer
-- Description: LCD Control of MES Board
--				with NIOS II Avalon Bus Interface
--------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ctrl_lcd_avalonSlave is
	port(
		--
		Clk_CI              : in    std_logic;
		Reset_RI            : in    std_logic;
		-- Avalon interface (slave)
		avs_Address_DI      : in    std_logic_vector(1 downto 0);
		avs_Read_SI         : in    std_logic;
		avs_ReadData_DO     : out   std_logic_vector(15 downto 0);
		avs_Write_SI        : in    std_logic;
		avs_WriteData_DI    : in    std_logic_vector(15 downto 0);
		avs_WaitRequest     : out   std_logic;
		-- LCD interface
		lcd_ChipSelect_n_SO : out   std_logic;
		lcd_DataCommand_SO  : out   std_logic;
		lcd_Write_n_SO      : out   std_logic;
		lcd_Read_n_SO       : out   std_logic;
		lcd_Reset_n_SO      : out   std_logic;
		lcd_im0_SO          : out   std_logic;
		lcd_Data_DIO        : inout std_logic_vector(15 downto 0)
	);
end entity ctrl_lcd_avalonSlave;

architecture rtl of ctrl_lcd_avalonSlave is

	type lcd_state is (S_reset, S_idle, S_write);
	type send_state is (S_idle, S_writeL, S_writeH);
	type wait_cnt_state is (S_idle, S_CntActive);
	constant wait_reset : std_logic_vector(15 downto 0) := x"00FF";
	constant wait_write : std_logic_vector(15 downto 0) := x"0001";

	signal RegWaitCnt  : std_logic_vector(15 downto 0);
	signal RegLCDData  : std_logic_vector(15 downto 0);
	signal RegCtrl     : std_logic_vector(15 downto 0);
	signal SigCtrl     : std_logic_vector(15 downto 0);
	signal CntActive   : std_logic;
	signal WriteDone   : std_logic;
	signal WriteActive : std_logic;
	signal LcdBusy     : std_logic;

	signal TrigRstCnt : std_logic;
	signal TrigWRXCnt : std_logic;

	signal s_curr_wait_cnt : wait_cnt_state;
	signal s_next_wait_cnt : wait_cnt_state;

	signal s_curr_lcd  : lcd_state;
	signal s_next_lcd  : lcd_state;
	signal s_curr_send : send_state;
	signal s_next_send : send_state;
	signal SigWaitCnt  : std_logic_vector(15 downto 0);

begin
	lcd_im0_SO <= '0';
	--------------------------------------------------------------
	-- Write Process with 1CC Latency
	--------------------------------------------------------------
	pRegWr : process(Clk_CI, Reset_RI) is
	begin
		if Reset_RI = '1' then
			-- Input by default
			RegLCDData <= (others => '0');
			RegCtrl    <= (3 => '1', others => '0'); -- set reset 
		elsif rising_edge(Clk_CI) then
			if avs_Write_SI = '1' then
				--Write cycle
				case avs_Address_DI is
					when "00"   => RegLCDData <= avs_WriteData_DI;
					when "01"   => RegCtrl <= avs_WriteData_DI;
					when others => null;
				end case;
			else
				RegCtrl <= SigCtrl;
			end if;
		end if;
	end process pRegWr;

	--------------------------------------------------------------
	-- Read Process with 1CC Latency
	--------------------------------------------------------------
	pRegRd : process(Clk_CI) is
	begin
		if rising_edge(Clk_CI) then
			if avs_Read_SI = '1' then
				--Read cycle
				case avs_Address_DI is
					when "00"   => avs_ReadData_DO <= RegLCDData;
					when "01"   => avs_ReadData_DO <= RegCtrl;
					when others => null;
				end case;
			end if;
		end if;
	end process pRegRd;

	--------------------------------------------------------------
	-- Memoryless Process of Ctrl FSM
	--------------------------------------------------------------	
	pCtrlLcd : process(s_curr_lcd, RegCtrl(0), RegWaitCnt, WriteDone, RegCtrl(1), RegCtrl(3), RegCtrl) is
	begin
		-- default assignment
		s_next_lcd      <= s_curr_lcd;
		WriteActive     <= '0';
		avs_WaitRequest <= '0';
		lcd_Reset_n_SO  <= '1';
		LcdBusy         <= '0';
		TrigRstCnt      <= '0';
		SigCtrl         <= RegCtrl;
		case s_curr_lcd is
			when S_reset =>
				if to_integer(unsigned(RegWaitCnt)) = 0 then
					s_next_lcd <= S_idle; -- lcd reset is not set low (keeps default)
				else
					LcdBusy        <= '1';
					lcd_Reset_n_SO <= '0'; -- remain in this state, keep reset low
				end if;
			when S_idle =>
				if RegCtrl(3) = '1' then
					s_next_lcd <= S_reset;
					TrigRstCnt <= '1';
					SigCtrl(3) <= '0';  -- clear reset
				elsif RegCtrl(0) = '1' or RegCtrl(1) = '1' then -- start LCD writing
					s_next_lcd      <= S_write;
					avs_WaitRequest <= '1';
					LcdBusy         <= '1';
				end if;
			when S_write =>
				WriteActive     <= '1';
				avs_WaitRequest <= '1'; -- hold in Wait Request
				LcdBusy         <= '1';
				if WriteDone = '1' then -- LCD command successfully written
					s_next_lcd          <= S_idle;
					SigCtrl(1 downto 0) <= (others => '0');
					avs_WaitRequest     <= '0';
				end if;
		end case;
	end process pCtrlLcd;

	--------------------------------------------------------------
	-- Memorising Process of Ctrl FSM
	--------------------------------------------------------------	
	pCtrlLcd_s : process(Clk_CI, Reset_RI) is
	begin
		if Reset_RI = '1' then
			s_curr_lcd <= S_idle;
		elsif rising_edge(Clk_CI) then
			s_curr_lcd <= s_next_lcd;
		end if;
	end process pCtrlLcd_s;

	--------------------------------------------------------------
	-- Memoryless Process of Send FSM
	--------------------------------------------------------------	
	pSendLcd : process(s_curr_send, RegCtrl(0), RegLCDData, CntActive, s_curr_lcd) is
	begin
		-- default assignment
		s_next_send         <= s_curr_send;
		lcd_DataCommand_SO  <= '1';
		lcd_Write_n_SO      <= '1';
		lcd_ChipSelect_n_SO <= '0';     -- remains always active so far
		lcd_Data_DIO        <= (others => '0');
		TrigWRXCnt          <= '0';
		WriteDone           <= '1';
		case s_curr_send is
			when S_idle =>
				if s_curr_lcd = S_write then -- kick this state machine 
					if RegCtrl(0) = '1' then -- send command
						lcd_DataCommand_SO <= '0'; -- 
					end if;
					lcd_Data_DIO <= RegLCDData;
					s_next_send <= S_writeL;
					TrigWRXCnt <= '1';
					WriteDone <= '0';
				end if;
			when S_writeL =>
				WriteDone      <= '0';
				if RegCtrl(0) = '1' then -- send command
					lcd_DataCommand_SO <= '0'; -- to send a command, we need to set DCX low
				end if;                 -- for data, DCX remains high
				lcd_Data_DIO   <= RegLCDData;
				lcd_Write_n_SO <= '0';
				if CntActive = '0' then
					s_next_send <= S_writeH;
					TrigWRXCnt  <= '1';
				end if;
			when S_writeH =>
				WriteDone    <= '0';
				if RegCtrl(0) = '1' then -- send command
					lcd_DataCommand_SO <= '0'; -- to send a command, we need to set DCX low
				end if;                 -- for data, DCX remains high
				lcd_Data_DIO <= RegLCDData;
				if CntActive = '0' then
					s_next_send <= S_idle;
					WriteDone   <= '1';
				end if;
		end case;
	end process pSendLcd;

	--------------------------------------------------------------
	-- Memorising Process of Send FSM
	--------------------------------------------------------------	
	pSendLcd_s : process(Clk_CI, Reset_RI) is
	begin
		if Reset_RI = '1' then
			s_curr_send <= S_idle;
		elsif rising_edge(Clk_CI) then
			s_curr_send <= s_next_send;
		end if;
	end process pSendLcd_s;

	--------------------------------------------------------------
	--Wait Counter FSM (mealy type)
	--------------------------------------------------------------	
	pWaitCnt : process(RegWaitCnt, TrigRstCnt, TrigWRXCnt, s_curr_wait_cnt) is
	begin
		-- default assignment
		s_next_wait_cnt <= s_curr_wait_cnt;
		CntActive       <= '0';
		SigWaitCnt      <= RegWaitCnt;
		case s_curr_wait_cnt is
			when S_idle =>
				if TrigRstCnt = '1' then
					SigWaitCnt      <= wait_reset;
					s_next_wait_cnt <= S_CntActive;
				elsif TrigWRXCnt = '1' then
					SigWaitCnt      <= wait_write;
					s_next_wait_cnt <= S_CntActive;
				end if;
			when S_CntActive =>
				CntActive <= '1';
				if unsigned(RegWaitCnt) = 0 then -- 1CC latency
					s_next_wait_cnt <= S_idle; --wait for cnt done

				end if;
		end case;
	end process pWaitCnt;

	--------------------------------------------------------------
	-- Memorising Process of Wait Cnt FSM
	--------------------------------------------------------------	
	pWaitCnt_s : process(Clk_CI, Reset_RI) is
	begin
		if Reset_RI = '1' then
			s_curr_wait_cnt <= S_idle;
			RegWaitCnt      <= (others => '0'); --reset wait cnt register
		elsif rising_edge(Clk_CI) then
			s_curr_wait_cnt <= s_next_wait_cnt;
			if CntActive = '1' then
				RegWaitCnt <= std_logic_vector(unsigned(RegWaitCnt) - 1);
			else
				RegWaitCnt <= SigWaitCnt;
			end if;
		end if;
	end process pWaitCnt_s;

end architecture rtl;

