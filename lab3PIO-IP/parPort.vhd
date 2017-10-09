library ieee;
use ieee.std_logic_1164.all;

entity PIO is
	port(
		-- Avalon interfaces signals
		Clk_CI       : in    std_logic;
		Reset_RLI    : in    std_logic;
		Address_DI   : in    std_logic_vector(2 downto 0);
		Read_SI      : in    std_logic;
		ReadData_DO  : out   std_logic_vector(7 downto 0);
		Write_SI     : in    std_logic;
		WriteData_DI : in    std_logic_vector(7 downto 0);
		-- Parallel Port external interface
		ParPort_DIO  : inout std_logic_vector(7 downto 0)
	);
end entity PIO;

architecture RTL of PIO is

	signal RegDir_D       : std_logic_vector(7 DOWNTO 0); -- Port Direction
	signal RegPort_D      : std_logic_vector(7 DOWNTO 0); -- State of the Port
	signal RegPinSynch0_D : std_logic_vector(7 DOWNTO 0); -- Pin Input Synch Stage 0
	signal RegPinSynch1_D : std_logic_vector(7 DOWNTO 0); -- Pin Input Synch State 1
	signal RegPin_D       : std_logic_vector(7 DOWNTO 0); -- Pin Input

begin

	--------------------------------------------------------------
	-- Write Process with 1CC Latency
	--------------------------------------------------------------
	pRegWr : process(Clk_CI, Reset_RLI) is
	begin
		if Reset_RLI = '0' then
			-- Input by default
			RegDir_D  <= (others => '0');
			RegPort_D <= (others => '0');
		elsif rising_edge(Clk_CI) then
			if Write_SI = '1' then
				--Write cycle
				case Address_DI(2 downto 0) is
					when "000"  => RegDir_D <= WriteData_DI;
					when "010"  => RegPort_D <= WriteData_DI;
					when "011"  => RegPort_D <= RegPort_D OR WriteData_DI;
					when "100"  => RegPort_D <= RegPort_D AND NOT WriteData_DI;
					when others => null;
				end case;
			end if;
		end if;
	end process pRegWr;

	--------------------------------------------------------------
	-- Read Process with 1CC Latency
	--------------------------------------------------------------
	pRegRd : process(Clk_CI) is
	begin
		if rising_edge(Clk_CI) then
			if Read_SI = '1' then
				--Read cycle
				case Address_DI(2 downto 0) is
					when "000"  => ReadData_DO <= RegDir_D;
					when "010"  => ReadData_DO <= RegPin_D;
					when "011"  => ReadData_DO <= RegPort_D;
					when others => null;
				end case;
			end if;
		end if;
	end process pRegRd;

	--------------------------------------------------------------
	-- Parallel Port output value
	-- Memory Less Process
	--------------------------------------------------------------
	pPortOut : process(RegDir_D, RegPort_D)
	begin
		for idx in 0 to 7 loop
			if RegDir_D(idx) = '1' then
				ParPort_DIO(idx) <= RegPort_D(idx);
			else
				ParPort_DIO(idx) <= 'Z';
			end if;
		end loop;
	end process pPortOut;

	--------------------------------------------------------------
	-- Parallel Port Input value
	-- Two stage input synchronisation
	--------------------------------------------------------------
	pPortIn : process(Clk_CI)
	begin
		if rising_edge(Clk_CI) then
			RegPinSynch0_D <= ParPort_DIO;
			RegPinSynch1_D <= RegPinSynch0_D;
			RegPin_D       <= RegPinSynch1_D;
		end if;
	end process pPortIn;

end architecture RTL;
