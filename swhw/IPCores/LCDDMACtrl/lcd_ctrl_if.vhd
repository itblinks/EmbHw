--------------------------------------------------------------
-- File: LCDCtrl.vhd
-- Rev: 0.9
-- Date: 09.10.2017
-- Author: Mario Fischer
-- Description: LCD Control of MSE Board
--				with NIOS II Avalon Bus Interface
--------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lcd_ctrl_if is
	port(
		--
		Clk_CI              : in    std_logic;
		Reset_RI            : in    std_logic;
		-- DMA interface
		DMA_WaitRequest     : out   std_logic;
		DMA_Status          : out   std_logic_vector(4 downto 0);
		DMA_Reset           : in    std_logic;
		DMA_SendCommand     : in    std_logic;
		DMA_SendData        : in    std_logic;
		DMA_Data            : in    std_logic_vector(15 downto 0);
		-- LCD interface
		lcd_ChipSelect_n_SO : out   std_logic;
		lcd_DataCommand_SO  : out   std_logic;
		lcd_Write_n_SO      : out   std_logic;
		lcd_Read_n_SO       : out   std_logic;
		lcd_Reset_n_SO      : out   std_logic;
		lcd_im0_SO          : out   std_logic;
		lcd_Data_DIO        : inout std_logic_vector(15 downto 0)
	);
end entity lcd_ctrl_if;

architecture rtl of lcd_ctrl_if is

	type lcd_state is (S_reset, S_idle, S_write);
	type send_state is (S_idle, S_writeL, S_writeH);
	type wait_cnt_state is (S_idle, S_CntActive);
	constant wait_reset : std_logic_vector(15 downto 0) := x"00FF";
	constant wait_write : std_logic_vector(15 downto 0) := x"0001";

	signal RegWaitCnt : std_logic_vector(15 downto 0);
	signal RegLCDData : std_logic_vector(15 downto 0);
	signal RegStatus  : std_logic_vector(4 downto 0);
	signal SigStatus  : std_logic_vector(4 downto 0);
	signal SigLCDData : std_logic_vector(15 downto 0);
	signal CntActive  : std_logic;
	signal WriteDone  : std_logic;
	signal TrigWrite  : std_logic;

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
	lcd_im0_SO    <= '0';
	lcd_Read_n_SO <= '1';

	DMA_Status <= RegStatus;
	--------------------------------------------------------------
	-- Memoryless Process of Ctrl FSM
	-- #FF = 0 
	--------------------------------------------------------------	
	pCtrlLcd : process(s_curr_lcd, RegWaitCnt, WriteDone, RegStatus, DMA_Data, DMA_Reset, DMA_SendCommand, DMA_SendData, RegLCDData) is
	begin
		-- default assignment
		s_next_lcd      <= s_curr_lcd;
		TrigWrite       <= '0';
		lcd_Reset_n_SO  <= '1';
		TrigRstCnt      <= '0';
		SigStatus       <= RegStatus;
		DMA_WaitRequest <= '1';
		SigLCDData      <= RegLCDData;
		case s_curr_lcd is
			when S_reset =>
				DMA_WaitRequest <= '0';
				if to_integer(unsigned(RegWaitCnt)) = 0 then
					s_next_lcd   <= S_idle; -- lcd reset is not set low (keeps default)
					SigStatus(3) <= '0'; -- clear reset status
				else
					SigStatus(2)   <= '1';
					lcd_Reset_n_SO <= '0'; -- remain in this state, keep reset low
				end if;
			when S_idle =>
				SigStatus(2) <= '0';    -- module not busy
				if DMA_Reset = '1' then
					s_next_lcd   <= S_reset;
					TrigRstCnt   <= '1';
					SigStatus(3) <= '1'; -- set reset status
				elsif DMA_SendCommand = '1' or DMA_SendData = '1' then -- start LCD writing
					SigLCDData   <= DMA_Data;
					s_next_lcd   <= S_write;
					TrigWrite    <= '1'; -- trigger write fsm
					SigStatus(2) <= '1'; -- write busy bit
					if DMA_SendCommand = '1' then
						SigStatus(0) <= '1'; -- set "write command" flag
					else
						SigStatus(1) <= '1'; -- set "write data" flag
					end if;
				else
					DMA_WaitRequest <= '0'; -- release wait request
				end if;
			when S_write =>
				SigStatus(2) <= '1';
				if WriteDone = '1' then -- LCD command successfully written
					s_next_lcd            <= S_idle;
					DMA_WaitRequest       <= '0'; -- release wait request to enable next data
					SigStatus(1 downto 0) <= (others => '0'); -- clear "write XX" flag  
				end if;
		end case;
	end process pCtrlLcd;

	--------------------------------------------------------------
	-- Memorising Process of Ctrl FSM 
	-- #FF = 2 (assuming binary encoding)
	--------------------------------------------------------------	
	pCtrlLcd_s : process(Clk_CI, Reset_RI) is
	begin
		if Reset_RI = '1' then
			s_curr_lcd   <= S_idle;
			RegStatus    <= (others => '0');
			RegLCDData <= (others => '0');
		elsif rising_edge(Clk_CI) then
			s_curr_lcd   <= s_next_lcd;
			RegStatus    <= SigStatus;
			RegLCDData <= SigLCDData;
		end if;
	end process pCtrlLcd_s;

	--------------------------------------------------------------
	-- Memoryless Process of Send FSM
	-- #FF = 0 
	--------------------------------------------------------------	
	pSendLcd : process(s_curr_send, RegStatus(0), RegLCDData, CntActive, TrigWrite) is
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
				if TrigWrite = '1' then -- kick this state machine 
					if RegStatus(0) = '1' then -- send command
						lcd_DataCommand_SO <= '0'; -- 
					end if;
					lcd_Data_DIO <= RegLCDData;
					s_next_send <= S_writeL;
					TrigWRXCnt <= '1';
					WriteDone <= '0';
				else
				end if;
			when S_writeL =>
				WriteDone      <= '0';
				if RegStatus(0) = '1' then -- send command
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
				if RegStatus(0) = '1' then -- send command
					lcd_DataCommand_SO <= '0'; -- to send a command, we need to set DCX low
				end if;                 -- for data, DCX remains high
				lcd_Data_DIO <= RegLCDData;
				if CntActive = '0' then -- time out done
					s_next_send <= S_idle;
				end if;
		end case;
	end process pSendLcd;

	--------------------------------------------------------------
	-- Memorising Process of Send FSM
	-- #FF = 2 (assuming binary encoding)
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
	-- #FF = 0
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
				if unsigned(RegWaitCnt) = 0 then -- 1CC latency
					--immediately start over
					if TrigRstCnt = '1' then
						SigWaitCnt      <= wait_reset;
						s_next_wait_cnt <= S_CntActive;
					elsif TrigWRXCnt = '1' then
						SigWaitCnt      <= wait_write;
						s_next_wait_cnt <= S_CntActive;
					else
						s_next_wait_cnt <= S_idle; --wait for cnt done
					end if;
				else
					SigWaitCnt <= std_logic_vector(unsigned(RegWaitCnt) - 1);
					CntActive  <= '1';
				end if;
		end case;
	end process pWaitCnt;

	--------------------------------------------------------------
	-- Memorising Process of Wait Cnt FSM
	-- #FF = 1 + 16 = 17
	--------------------------------------------------------------	
	pWaitCnt_s : process(Clk_CI, Reset_RI) is
	begin
		if Reset_RI = '1' then
			s_curr_wait_cnt <= S_idle;
			RegWaitCnt      <= (others => '0'); --reset wait cnt register
		elsif rising_edge(Clk_CI) then
			s_curr_wait_cnt <= s_next_wait_cnt;
			RegWaitCnt      <= SigWaitCnt;
		end if;
	end process pWaitCnt_s;

end architecture rtl;
