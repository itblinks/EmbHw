library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.math_real.all;

entity sdram_dummy is
	port(
		clk               : in  std_logic;
		rst               : in  std_logic;
		-- Avalon Master to SDRAM
		avs_addr          : in  std_logic_vector(31 downto 0);
		avs_read          : in  std_logic;
		avs_readData      : out std_logic_vector(31 downto 0);
		avs_readDataValid : out std_logic;
		avs_waitRequest   : out std_logic
	);
end entity sdram_dummy;

architecture RTL of sdram_dummy is

	--generate some dummy data, cosine and store in memory

	constant ADDR_WIDTH : integer := 16;
	constant DATA_WIDTH : integer := 32;
	constant MEM_DEPTH  : integer := 2**ADDR_WIDTH;
	type mem_type is array (0 to MEM_DEPTH - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);

	function init_mem return mem_type is
		constant SCALE    : real := 2**(real(DATA_WIDTH - 2));
		constant STEP     : real := 1.0/real(MEM_DEPTH);
		variable temp_mem : mem_type;
	begin
		for i in 0 to MEM_DEPTH - 1 loop
			temp_mem(i) := std_logic_vector(to_signed(integer(cos(2.0*MATH_PI*real(i)*STEP)*SCALE), DATA_WIDTH));
		end loop;
		return temp_mem;
	end;

	constant mem          : mem_type := init_mem;
	signal avs_read_fifo1 : std_logic;
	signal avs_read_fifo0 : std_logic;
	signal avs_read_fifo2 : std_logic;
	signal avs_addr_fifo1 : std_logic_vector(31 downto 0);
	signal avs_addr_fifo0 : std_logic_vector(31 downto 0);
	signal num_elements   : std_logic_vector(1 downto 0);
	function to_integer(s : std_logic) return integer is
	begin
		if s = '1' then
			return 1;
		else
			return 0;
		end if;
	end function;
	signal avs_read_fifo3 : std_logic;

begin
	avs_readDataValid <= avs_read_fifo3;
	dummyRAM : process(clk, rst)
	begin
		if rst = '1' then
			num_elements <= (others => '0');
			avs_readData    <= (others => '1');
			avs_read_fifo1  <= '0';
			avs_read_fifo0  <= '0';
			avs_read_fifo2  <= '0';
			avs_addr_fifo1  <= (others => '0');
			avs_addr_fifo0  <= (others => '0');
		elsif rising_edge(clk) then
			if avs_read = '1' then
				avs_addr_fifo1 <= avs_addr_fifo0;
				avs_addr_fifo0 <= avs_addr;
			else
				avs_addr_fifo1 <= avs_addr_fifo0;
				avs_addr_fifo0 <= (others => '0');
			end if;
			if avs_read_fifo2 = '1' then
				avs_readData <= mem(to_integer(unsigned(avs_addr_fifo1)));
			end if;
			avs_read_fifo0 <= avs_read;
			avs_read_fifo1 <= avs_read_fifo0;
			avs_read_fifo2 <= avs_read_fifo1;
			avs_read_fifo3 <= avs_read_fifo2;
			num_elements   <= std_logic_vector(unsigned(num_elements) + to_integer(avs_read) - to_integer(avs_read_fifo1));
		end if;
	end process;

	dummyRAMMemless : process(num_elements)
	begin
		if unsigned(num_elements) = 2 then
			avs_waitRequest <= '1';
		else
			avs_waitRequest <= '0';
		end if;
	end process;

end architecture RTL;
