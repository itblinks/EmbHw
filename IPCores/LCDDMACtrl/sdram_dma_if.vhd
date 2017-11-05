library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sdram_dma_if is
	port(
		clk               : in  std_logic;
		rst               : in  std_logic;
		-- Avalon Master to SDRAM
		avm_addr          : out std_logic_vector(31 downto 0);
		avm_read          : out std_logic;
		avm_readData      : in  std_logic_vector(31 downto 0);
		avm_readDataValid : in  std_logic;
		avm_waitRequest   : in  std_logic;
		-- DMA interface
		dma_initTF        : in  std_logic;
		dma_startAddr     : in  std_logic_vector(31 downto 0);
		dma_sizeTF        : in  std_logic_vector(31 downto 0);
		dma_pop           : in  std_logic;
		dma_dataRdy       : out std_logic;
		dma_dataValid     : out std_logic;
		dma_dataOut       : out std_logic_vector(31 downto 0)
	);
end entity sdram_dma_if;

architecture RTL of sdram_dma_if is
	-- SDRAM READ BUFFER
	constant BUFFSIZE           : integer := 64;
	type BUFF_TYPE is array (BUFFSIZE - 1 downto 0) of std_logic_vector(31 downto 0);
	signal buffA                : BUFF_TYPE;
	signal buffB                : BUFF_TYPE;
	signal RegBuffReadDone      : std_logic_vector(1 downto 0);
	signal SigBuffNewData       : std_logic_vector(1 downto 0);
	signal SigBuffReadDone      : std_logic_vector(1 downto 0);
	signal RegWriteBuffSelector : std_logic_vector(0 downto 0);
	signal SigWriteBuffSelector : std_logic_vector(0 downto 0);
	signal RegReadBuffSelector  : std_logic_vector(0 downto 0);
	signal SigReadBuffSelector  : std_logic_vector(0 downto 0);
	signal RegBuffWriteAddr     : std_logic_vector(5 downto 0);
	signal SigBuffWriteAddr     : std_logic_vector(5 downto 0);
	signal RegBuffReadAddr      : std_logic_vector(5 downto 0);
	signal SigBuffReadAddr      : std_logic_vector(5 downto 0);

	-- SDRAM WriteBuff FSM
	type S_WriteBuff is (s_idle, s_fillBuff, s_wait);
	signal s_writeBuff_curr      : S_WriteBuff;
	signal s_writeBuff_next      : S_WriteBuff;
	signal sdram_addr_start_curr : std_logic_vector(31 downto 0);
	signal sdram_addr_start_next : std_logic_vector(31 downto 0);
	signal sdram_addr_curr       : std_logic_vector(31 downto 0);
	signal sdram_addr_next       : std_logic_vector(31 downto 0);

	-- SDRAM ReadBuff FSM
	type S_ReadBuff is (s_idle, s_read);
	signal s_readBuff_curr : S_ReadBuff;
	signal s_readBuff_next : S_ReadBuff;
	signal dataRdy : std_logic;

begin

	avm_addr <= sdram_addr_curr;

	dma_dataRdy <= dataRdy;

	writeBuffFSMProc : process(s_writeBuff_curr, avm_readDataValid, dma_initTF, RegWriteBuffSelector, RegBuffWriteAddr, avm_waitRequest, dma_startAddr, sdram_addr_curr, sdram_addr_start_curr, dma_sizeTF, sdram_addr_start_next, RegBuffReadDone)
	begin
		-- default assignment
		s_writeBuff_next      <= s_writeBuff_curr; -- remain in current state
		avm_read              <= '0';
		sdram_addr_next       <= sdram_addr_curr;
		SigBuffWriteAddr      <= RegBuffWriteAddr;
		sdram_addr_start_next <= sdram_addr_start_curr;
		SigWriteBuffSelector  <= RegWriteBuffSelector;
		SigBuffNewData        <= (others => '0');
		case s_writeBuff_curr is
			when s_idle =>
				if dma_initTF = '1' then
					sdram_addr_start_next <= dma_startAddr; --set to first address
					sdram_addr_next       <= dma_startAddr; --set to start address
					SigBuffWriteAddr      <= (others => '0');
					s_writeBuff_next      <= s_fillBuff;
				end if;
			when s_wait =>
				if RegBuffReadDone /= "00" then -- buffer read
					s_writeBuff_next      <= s_fillBuff;
					sdram_addr_start_next <= std_logic_vector(unsigned(sdram_addr_start_curr) + BUFFSIZE);
					sdram_addr_next       <= sdram_addr_start_next;
				end if;
			when s_fillBuff =>
				avm_read <= '1';
				-- check if wait is requested or if buffer size is extracted from ram	or if end is reached
				if avm_waitRequest = '1' or sdram_addr_curr = std_logic_vector(unsigned(sdram_addr_start_curr) + BUFFSIZE) or unsigned(sdram_addr_curr) = unsigned(dma_startAddr) + unsigned(dma_sizeTF) then
					avm_read <= '0';
				else
					sdram_addr_next <= std_logic_vector(unsigned(sdram_addr_curr) + 1); -- set to subsequent address
				end if;

				-- if new data is present, increment buffer write address for next cycle 
				if avm_readDataValid = '1' then
					SigBuffWriteAddr <= std_logic_vector(unsigned(RegBuffWriteAddr) + 1);
					-- check if buffer is full
					if RegBuffWriteAddr = "111111" then -- buffer full
						SigBuffNewData(to_integer(unsigned(RegWriteBuffSelector))) <= '1';
						s_writeBuff_next                                           <= s_wait;
						SigWriteBuffSelector                                       <= not RegWriteBuffSelector; -- switch to other Reg
					end if;
				end if;

		end case;
	end process writeBuffFSMProc;

	writeBuffFSMProcSeq : process(clk, rst)
	begin
		if rst = '1' then
			RegBuffWriteAddr     <= (others => '0');
			RegWriteBuffSelector <= "0";
			buffA                <= (others => (others => '0')); -- set buffer A to all 0
			buffB                <= (others => (others => '0')); -- set buffer B to all 0
		elsif rising_edge(clk) then
			sdram_addr_curr       <= sdram_addr_next;
			s_writeBuff_curr      <= s_writeBuff_next;
			sdram_addr_start_curr <= sdram_addr_start_next;
			RegWriteBuffSelector  <= SigWriteBuffSelector;
			if s_writeBuff_curr = s_fillBuff then
				if avm_readDataValid = '1' then
					case RegWriteBuffSelector is
						when "0" =>
							buffA(to_integer(unsigned(RegBuffWriteAddr))) <= avm_readData;
						when "1" =>
							buffB(to_integer(unsigned(RegBuffWriteAddr))) <= avm_readData;
						when others =>
					end case;
				end if;
				RegBuffWriteAddr <= SigBuffWriteAddr;
			end if;
		end if;
	end process writeBuffFSMProcSeq;

	readBuffFSMProc : process(RegBuffReadAddr, RegBuffReadDone, RegReadBuffSelector, buffA, buffB, dma_pop, s_readBuff_curr, dataRdy, SigBuffNewData)
	begin
		s_readBuff_next     <= s_readBuff_curr;
		if unsigned(RegBuffReadDone) = "11" then
			dataRdy <= '0';
		else
			dataRdy <= '1';
		end if;
		SigBuffReadAddr     <= RegBuffReadAddr;
		SigReadBuffSelector <= RegReadBuffSelector;
		dma_dataOut         <= (others => '0');
		dma_dataValid       <= '0';
		SigBuffReadDone     <= RegBuffReadDone and not SigBuffNewData; -- clear if new data has arrived
		case s_readBuff_curr is
			when s_idle =>
				if dataRdy = '1' and dma_pop = '1' then
					s_readBuff_next <= s_read;
				end if;
			when s_read =>
				if RegBuffReadAddr = "111111" then -- end of buffer
					SigBuffReadAddr                                            <= (others => '0');
					SigBuffReadDone(to_integer(unsigned(RegReadBuffSelector))) <= '1';
					SigReadBuffSelector                                        <= not RegReadBuffSelector;
				else
					SigBuffReadAddr                                            <= std_logic_vector(unsigned(RegBuffReadAddr) + 1);
					SigBuffReadDone(to_integer(unsigned(RegReadBuffSelector))) <= '0';
				end if;
				case RegReadBuffSelector is
					when "0" =>
						dma_dataOut <= buffA(to_integer(unsigned(RegBuffReadAddr)));
					when "1" =>
						dma_dataOut <= buffB(to_integer(unsigned(RegBuffReadAddr)));
					when others =>
						dma_dataOut <= (others => '0');
				end case;
				dma_dataValid <= '1';
				s_readBuff_next <= s_idle;
		end case;
	end process readBuffFSMProc;

	readBuffFSMProcSeq : process(clk, rst)
	begin
		if rst = '1' then
			RegBuffReadDone     <= (others => '1');
			RegBuffReadAddr      <= (others => '0');
			RegReadBuffSelector <= "0";
		elsif rising_edge(clk) then
			RegReadBuffSelector <= SigReadBuffSelector;
			RegBuffReadAddr <= SigBuffReadAddr;
			RegBuffReadDone <= SigBuffReadDone;
			s_readBuff_curr <= s_readBuff_next;
		end if;
	end process readBuffFSMProcSeq;

end architecture RTL;
