library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ctrl_lcd_avalonSlave_S is
  port(
    --
	 Clk_CI			: in	std_logic;
	 Reset_RI		: in	std_logic;
	 
	 -- Avalon interface (slave)
	 avs_Address_DI	: in	std_logic_vector (1 downto 0);
	 avs_Read_SI		: in	std_logic;
	 avs_ReadData_DO	: out	std_logic_vector (15 downto 0);
	 avs_Write_SI		: in	std_logic;
	 avs_WriteData_DI	: in	std_logic_vector (15 downto 0);
	 avs_WaitRequest	: out	std_logic;
	 
	 -- LCD interface
	 lcd_ChipSelect_n_SO	: out std_logic;
	 lcd_DataCommand_SO	: out std_logic;
	 lcd_Write_n_SO		: out std_logic;
	 lcd_Read_n_SO			: out std_logic;
	 lcd_Reset_n_SO		: out std_logic;
	 lcd_im0_SO				: out std_logic;
	 lcd_Data_DIO			: inout std_logic_vector (15 downto 0)
  );
end entity ctrl_lcd_avalonSlave_S;


architecture A of ctrl_lcd_avalonSlave_S is
	type lcd_state is (S_reset, S_idle, S_writeActive, S_writeInactive);
	
	constant waitCycles : integer := 2;
	signal RegWaitCnt : std_logic_vector (3 downto 0);
	signal SigWaitCnt : std_logic_vector (3 downto 0);
	signal c_st, n_st : lcd_state;
	
	signal RegCommand_D : std_logic_vector (15 downto 0);
	signal RegData_D : std_logic_vector (15 downto 0);

	-- internal avalonSlave to state machine
	signal RegLcdWrite_S : std_logic;
	signal RegLcdRead_S : std_logic;
	signal RegLcdData_S : std_logic;
	signal RegLcdCmd_S : std_logic;
	
	-- lcd IF
	signal Reg_lcdDC_S : std_logic;
	signal Reg_lcdWriteData_D : std_logic_vector(15 downto 0);
	signal Sig_lcdDC_S : std_logic;
	signal Sig_lcdWriteData_D : std_logic_vector(15 downto 0);
	
	-- avalon IF
	signal RegWaitRequest_S : std_logic;
	signal RegReadData_D : std_logic_vector (15 downto 0);


begin

avalonSlave:process(Clk_CI, Reset_RI)
begin
	if (Reset_RI = '1') then 
		-- registers for ReadData... (1 Cycle delay for read...)
		RegCommand_D <= (others => '0');
		RegData_D <= (others => '0');
		RegReadData_D <= (others => '0');
		RegLcdWrite_S <= '0';
		RegLcdRead_S <= '0';
		RegLcdCmd_S <= '0';
		RegLcdData_S <= '0';
	elsif rising_edge(Clk_CI) then
		RegLcdWrite_S <= '0';
		RegLcdRead_S <= '0';
		RegLcdCmd_S <= '0';
		RegLcdData_S <= '0';
		if avs_Read_SI = '1' then
			-- read from register (read from LCD not implemented now)
			case avs_Address_DI is
				when "00" => RegReadData_D <= RegCommand_D;
				when "01" => RegReadData_D <= RegData_D;
				--when "10" => RegReadData_D <= RegReadData_D;
				--when "11" => RegReadData_D <= RegReadData_D;			  			
				when others => RegReadData_D <= RegReadData_D;
			end case;			
		elsif avs_Write_SI = '1' then
			-- write to register and trigger state machine
			case avs_Address_DI is
				when "00" => RegCommand_D <= avs_WriteData_DI;
								 RegLcdWrite_S <= '1';
								 RegLcdCmd_S <= '1';
				when "01" => RegData_D <= avs_WriteData_DI;
								 RegLcdWrite_S <= '1';
								 RegLcdData_S <= '1';
				--when "10" => null;
				--when "11" => null;			  			
				when others => null;
			end case;
		end if;
	end if;
end process;

avs_ReadData_DO <= RegReadData_D;

lcd_seq:process(Clk_CI, Reset_RI)
begin
	if (Reset_RI = '1') then 
		c_st <= S_reset;
		Reg_lcdDC_S <= '0';
		Reg_lcdWriteData_D <= (others => '0');
		RegWaitCnt <= (others => '0');
	elsif rising_edge(Clk_CI) then
		c_st <= n_st;
		Reg_lcdDC_S <= Sig_lcdDC_S;
		Reg_lcdWriteData_D <= Sig_lcdWriteData_D;
		RegWaitCnt <= SigWaitCnt;
	end if;
end process;

lcd_Data_DIO <= Reg_lcdWriteData_D;
lcd_DataCommand_SO <= Reg_lcdDC_S;

lcd_com:process(c_st, Reg_lcdDC_S, Reg_lcdWriteData_D, RegWaitCnt, RegData_D, RegCommand_D, RegLcdWrite_S, RegLcdCmd_S, RegLcdData_S)
begin
	n_st <= c_st;
	-- fsm output
	lcd_ChipSelect_n_SO <= '1';
	Sig_lcdDC_S <= Reg_lcdDC_S;
	lcd_Write_n_SO <= '1';
	lcd_Read_n_SO <= '1';
	lcd_Reset_n_SO <= '1';
	lcd_im0_SO <= '0';
	Sig_lcdWriteData_D <= Reg_lcdWriteData_D;
	avs_WaitRequest <= '0';
	SigWaitCnt <= RegWaitCnt;
	
	case c_st is
		when S_reset =>
			lcd_Reset_n_SO <= '0';
			n_st <= S_idle;
		when S_idle =>
			SigWaitCnt <= (others => '0');
			if RegLcdWrite_S = '1' then
				avs_WaitRequest <= '1';
				if RegLcdCmd_S = '1' then
					Sig_lcdDC_S <= '0';
					Sig_lcdWriteData_D <= RegCommand_D;
					n_st <= S_writeActive;
				elsif RegLcdData_S = '1' then
					Sig_lcdDC_S <= '1';
					Sig_lcdWriteData_D <= RegData_D;
					n_st <= S_writeActive;
				end if;
			end if;
		when S_writeActive =>
			avs_WaitRequest <= '1';
			lcd_ChipSelect_n_SO <= '0';
			lcd_Write_n_SO <= '0';
			SigWaitCnt <= std_logic_vector(unsigned(RegWaitCnt) + 1);
			if (to_integer(unsigned(RegWaitCnt)) >= waitCycles) then
				SigWaitCnt <= (others => '0');
				n_st <= S_writeInactive;
			end if;
		when S_writeInactive =>
			avs_WaitRequest <= '1';
			lcd_ChipSelect_n_SO <= '0';
			SigWaitCnt <= std_logic_vector(unsigned(RegWaitCnt) + 1);
			if (to_integer(unsigned(RegWaitCnt)) >= waitCycles) then
				SigWaitCnt <= (others => '0');
				n_st <= S_idle;
			end if;
		when others =>
			n_st <= S_reset;
	end case;			
end process;

end A;
