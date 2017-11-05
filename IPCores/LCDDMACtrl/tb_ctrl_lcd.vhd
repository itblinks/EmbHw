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

library ieee;
use ieee.numeric_std.all;
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

	signal clk_sti  : std_logic;
	signal Reset_RI : std_logic;

	signal lcd_ChipSelect_n_SO : std_logic;
	signal lcd_DataCommand_SO  : std_logic;
	signal lcd_Write_n_SO      : std_logic;
	signal lcd_Read_n_SO       : std_logic;
	signal lcd_Reset_n_SO      : std_logic;
	signal lcd_im0_SO          : std_logic;
	signal lcd_Data_DIO        : std_logic_vector(15 downto 0);
	constant CLK_PERIOD        : time := 20 ns;
	signal DMA_WaitRequest     : std_logic;
	signal DMA_Status          : std_logic_vector(4 downto 0);
	signal DMA_Reset           : std_logic;
	signal DMA_SendCommand     : std_logic;
	signal DMA_SendData        : std_logic;
	signal DMA_Data            : std_logic_vector(15 downto 0);
	signal avs_addr            : std_logic_vector(31 downto 0);
	signal avs_read            : std_logic;
	signal avs_readData        : std_logic_vector(31 downto 0);
	signal avs_readDataValid   : std_logic;
	signal avs_waitRequest     : std_logic;
	signal dma_initTF          : std_logic;
	signal dma_startAddr       : std_logic_vector(31 downto 0);
	signal dma_sizeTF          : std_logic_vector(31 downto 0);
	signal dma_pop             : std_logic;
	signal dma_dataRdy         : std_logic;

begin

	----------------------------------------------------
	-- Device under Test
	----------------------------------------------------
	DUT_ctrl_lcd_avalonSlave : entity work.lcd_ctrl_if
		port map(
			Clk_CI              => clk_sti,
			Reset_RI            => Reset_RI,
			DMA_WaitRequest     => DMA_WaitRequest,
			DMA_Status          => DMA_Status,
			DMA_Reset           => DMA_Reset,
			DMA_SendCommand     => DMA_SendCommand,
			DMA_SendData        => DMA_SendData,
			DMA_Data            => DMA_Data,
			lcd_ChipSelect_n_SO => lcd_ChipSelect_n_SO,
			lcd_DataCommand_SO  => lcd_DataCommand_SO,
			lcd_Write_n_SO      => lcd_Write_n_SO,
			lcd_Read_n_SO       => lcd_Read_n_SO,
			lcd_Reset_n_SO      => lcd_Reset_n_SO,
			lcd_im0_SO          => lcd_im0_SO,
			lcd_Data_DIO        => lcd_Data_DIO
		);

	DUT_sdram_dummy : entity work.sdram_dummy
		port map(
			clk               => clk_sti,
			rst               => Reset_RI,
			avs_addr          => avs_addr,
			avs_read          => avs_read,
			avs_readData      => avs_readData,
			avs_readDataValid => avs_readDataValid,
			avs_waitRequest   => avs_waitRequest
		);

	DUT_sdram_dma_if : entity work.sdram_dma_if
		port map(
			clk               => clk_sti,
			rst               => Reset_RI,
			avm_addr          => avs_addr,
			avm_read          => avs_read,
			avm_readData      => avs_readData,
			avm_readDataValid => avs_readDataValid,
			avm_waitRequest   => avs_waitRequest,
			dma_initTF        => dma_initTF,
			dma_startAddr     => dma_startAddr,
			dma_sizeTF        => dma_sizeTF,
			dma_pop           => dma_pop,
			dma_dataRdy       => dma_dataRdy
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
		DMA_Data        <= (others => '0');
		DMA_SendCommand <= '0';
		DMA_SendData    <= '0';
		DMA_Reset       <= '0';
		wait for 10 us + CLK_PERIOD/2;
		wait until rising_edge(clk_sti);
		DMA_Data        <= (others => '1');
		DMA_SendCommand <= '1';
		wait for CLK_PERIOD;
		wait until rising_edge(clk_sti);
		DMA_Data        <= (others => '0');
		DMA_SendCommand <= '0';
		wait for CLK_PERIOD*5;
		wait until rising_edge(clk_sti);
		DMA_Data        <= (others => '1');
		DMA_SendData    <= '1';
		wait for CLK_PERIOD;
		wait until rising_edge(clk_sti);
		DMA_Data        <= (others => '0');
		DMA_SendData    <= '0';
		wait;
	end process;

	genDMA : process
	begin
		dma_initTF    <= '0';
		dma_startAddr <= (others => '0');
		dma_sizeTF    <= (others => '0');
		dma_pop       <= '0';
		wait for 3.5*CLK_PERIOD;
		wait until rising_edge(clk_sti);
		dma_startAddr <= (1 => '1', 0 => '1', others => '0');
		dma_sizeTF    <= x"000000FF";
		dma_initTF    <= '1';
		wait for CLK_PERIOD;
		wait until rising_edge(clk_sti);
		dma_initTF    <= '0';
		wait for 2.9 us;
		dma_pop       <= '1';
		wait for 14 us;
		wait until rising_edge(clk_sti);
		dma_startAddr <= (1 => '1', 0 => '1', others => '0');
		dma_sizeTF    <= x"000000FA";
		dma_initTF    <= '1';
		wait for CLK_PERIOD;
		wait until rising_edge(clk_sti);
		dma_initTF    <= '0';
		wait for 2.9 us;
		dma_pop       <= '1';
		wait;
	end process;
	----------------------------------------------------
	-- Gen DMA
	----------------------------------------------------

	--	----------------------------------------------------
	--	-- Gen RAM read
	--	----------------------------------------------------
	--
	--	genRead : process
	--	begin
	--		avs_addr <= (others => '0');
	--		avs_read <= '0';
	--		wait for 3.5*CLK_PERIOD;
	--		avs_addr <= (1=> '1', others => '0');
	--		avs_read <= '1';
	--		for i in 0 to 20 loop
	--			wait for CLK_PERIOD;
	--			wait until rising_edge(clk_sti);
	--			if avs_waitRequest = '1' then
	--				avs_read <= '0';
	--			else
	--				avs_addr <= std_logic_vector(unsigned(avs_addr) + 1);
	--				avs_read <= '1';
	--			end if;
	--		end loop;
	--		wait for CLK_PERIOD;
	--		wait until rising_edge(clk_sti);
	--		avs_addr <= (others => '0');
	--		avs_read <= '0';
	--		wait;
	--	end process;
end architecture rtl;
