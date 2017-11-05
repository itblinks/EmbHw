--------------------------------------------------------------
-- File: LCDCtrl.vhd
-- Rev: 0.9
-- Date: 09.10.2017
-- Author: Mario Fischer
-- Description: Test Bench for LCD Control
--------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity tb_ctrl_lcd is
end entity tb_ctrl_lcd;

architecture rtl of tb_ctrl_lcd is
	component ctrl_lcd_avalonSlave
		port(
			Clk_CI              : in    std_logic;
			Reset_RI            : in    std_logic;
			avs_Address_DI      : in    std_logic_vector(1 downto 0);
			avs_Read_SI         : in    std_logic;
			avs_ReadData_DO     : out   std_logic_vector(15 downto 0);
			avs_Write_SI        : in    std_logic;
			avs_WriteData_DI    : in    std_logic_vector(15 downto 0);
			avs_WaitRequest     : out   std_logic;
			lcd_ChipSelect_n_SO : out   std_logic;
			lcd_DataCommand_SO  : out   std_logic;
			lcd_Write_n_SO      : out   std_logic;
			lcd_Read_n_SO       : out   std_logic;
			lcd_Reset_n_SO      : out   std_logic;
			lcd_im0_SO          : out   std_logic;
			lcd_Data_DIO        : inout std_logic_vector(15 downto 0)
		);
	end component ctrl_lcd_avalonSlave;

	signal clk_sti             : std_logic;
	signal Reset_RI            : std_logic;
	signal avs_Address_DI      : std_logic_vector(1 downto 0);
	signal avs_Read_SI         : std_logic;
	signal avs_ReadData_DO     : std_logic_vector(15 downto 0);
	signal avs_Write_SI        : std_logic;
	signal avs_WriteData_DI    : std_logic_vector(15 downto 0);
	signal avs_WaitRequest     : std_logic;
	signal lcd_ChipSelect_n_SO : std_logic;
	signal lcd_DataCommand_SO  : std_logic;
	signal lcd_Write_n_SO      : std_logic;
	signal lcd_Read_n_SO       : std_logic;
	signal lcd_Reset_n_SO      : std_logic;
	signal lcd_im0_SO          : std_logic;
	signal lcd_Data_DIO        : std_logic_vector(15 downto 0);
	constant CLK_PERIOD        : time := 20 ns;

begin

	----------------------------------------------------
	-- Device under Test
	----------------------------------------------------
	DUT_ctrl_lcd_avalonSlave : entity work.ctrl_lcd_avalonslave
		port map(
			Clk_CI              => clk_sti,
			Reset_RI            => Reset_RI,
			avs_Address_DI      => avs_Address_DI,
			avs_Read_SI         => avs_Read_SI,
			avs_ReadData_DO     => avs_ReadData_DO,
			avs_Write_SI        => avs_Write_SI,
			avs_WriteData_DI    => avs_WriteData_DI,
			avs_WaitRequest     => avs_WaitRequest,
			lcd_ChipSelect_n_SO => lcd_ChipSelect_n_SO,
			lcd_DataCommand_SO  => lcd_DataCommand_SO,
			lcd_Write_n_SO      => lcd_Write_n_SO,
			lcd_Read_n_SO       => lcd_Read_n_SO,
			lcd_Reset_n_SO      => lcd_Reset_n_SO,
			lcd_im0_SO          => lcd_im0_SO,
			lcd_Data_DIO        => lcd_Data_DIO
		);
	----------------------------------------------------
	-- CLK Gen
	----------------------------------------------------
	genClk : process
	begin
		clk_sti <= '0';
		wait for CLK_PERIOD/2;
		clk_sti <= '1';
		wait for CLK_PERIOD/2;
	end process;

	----------------------------------------------------
	-- Reset Gen
	----------------------------------------------------
	Reset_RI <= '1', '0' after 2*CLK_PERIOD;

	genWrite : process
	begin
		wait for 10 us;
		avs_Address_DI   <= "00";
		avs_WriteData_DI <= (others => '1');
		avs_Write_SI     <= '1';
		wait for CLK_PERIOD;
		avs_Address_DI   <= "01";
		avs_WriteData_DI <= (0 => '1',4 => '1' ,others => '0');
		avs_Write_SI     <= '1';
		wait for CLK_PERIOD;
		avs_Write_SI     <= '0';
		wait for CLK_PERIOD*3.5;
		avs_Address_DI   <= "00";
		avs_WriteData_DI <= (others => '1');
		avs_Write_SI     <= '1';
		wait for CLK_PERIOD;
		avs_Address_DI   <= "01";
		avs_WriteData_DI <= (1 => '1', 4 => '1' ,others => '0');
		avs_Write_SI     <= '1';
		wait for CLK_PERIOD;
		avs_Write_SI     <= '0';
		avs_Address_DI   <= "00";
		avs_WriteData_DI <= (others => '0');
		wait;
	end process;

end architecture rtl;
