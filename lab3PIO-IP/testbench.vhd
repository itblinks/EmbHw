library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end entity testbench;

architecture RTL of testbench is
	constant period     : time := 10 ns;
	signal clk          : std_logic;
	signal rst          : std_logic;
	signal Read_SI      : std_logic;
	signal Address_DI   : std_logic_vector(2 downto 0);
	signal Write_SI     : std_logic;
	signal WirteData_DI : std_logic_vector(7 downto 0);

begin
	inst_parPort : entity work.PIO
		port map(
			Address_DI   => Address_DI,
			Write_SI     => Write_SI,
			WriteData_DI => WirteData_DI,
			Clk_CI       => clk,
			Reset_RLI    => rst,
			Read_SI      => Read_SI
		);

	clock_driver : process
	begin
		clk <= '0';
		wait for period / 2;
		clk <= '1';
		wait for period / 2;
	end process clock_driver;

	reset_activation : process
	begin
		rst <= '1', '0' after 10 ns;
	end process;
end architecture RTL;
