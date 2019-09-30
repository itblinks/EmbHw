
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ctrl_lcd_dma is
	port(clk                 : in  std_logic;
	     rst                 : in  std_logic;
	     -- Avalon interface (slave)
	     avs_Address_DI      : in  std_logic_vector(1 downto 0);
	     avs_Read_SI         : in  std_logic;
	     avs_ReadData_DO     : out std_logic_vector(15 downto 0);
	     avs_Write_SI        : in  std_logic;
	     avs_WriteData_DI    : in  std_logic_vector(15 downto 0);
	     avs_WaitRequest     : out std_logic;
	     -- Avalon Master to SDRAM
	     avm_addr            : out std_logic_vector(31 downto 0);
	     avm_read            : out std_logic;
	     avm_readData        : in  std_logic_vector(31 downto 0);
	     avm_readDataValid   : in  std_logic;
	     avm_waitRequest     : in  std_logic;
	     lcd_ChipSelect_n_SO : out std_logic;
	     lcd_DataCommand_SO  : out std_logic;
	     lcd_Write_n_SO      : out std_logic;
	     lcd_Read_n_SO       : out std_logic;
	     lcd_Reset_n_SO      : out std_logic;
	     lcd_im0_SO          : out std_logic;
	     lcd_Data_DIO        : out std_logic_vector(15 downto 0)
	    );
end entity;

architecture rtl of ctrl_lcd_dma is
	signal dma_initTF      : std_logic;
	signal dma_startAddr   : std_logic_vector(31 downto 0);
	signal dma_sizeTF      : std_logic_vector(31 downto 0);
	signal dma_done        : std_logic;
	signal dma_pop         : std_logic;
	signal dma_dataRdy     : std_logic;
	signal dma_dataValid   : std_logic;
	signal dma_dataOut     : std_logic_vector(31 downto 0);
	signal DMA_WaitRequest : std_logic;
	signal DMA_Status      : std_logic_vector(4 downto 0);
	signal DMA_Reset       : std_logic;
	signal DMA_SendCommand : std_logic;
	signal DMA_SendData    : std_logic;
	signal DMA_Data        : std_logic_vector(15 downto 0);

begin
	i_sdram_dma : entity work.sdram_dma_if
		port map(
			clk               => clk,
			rst               => rst,
			avm_addr          => avm_addr,
			avm_read          => avm_read,
			avm_readData      => avm_readData,
			avm_readDataValid => avm_readDataValid,
			avm_waitRequest   => avm_waitRequest,
			dma_initTF        => dma_initTF,
			dma_startAddr     => dma_startAddr,
			dma_sizeTF        => dma_sizeTF,
			dma_done          => dma_done,
			dma_pop           => dma_pop,
			dma_dataRdy       => dma_dataRdy,
			dma_dataValid     => dma_dataValid,
			dma_dataOut       => dma_dataOut
		);

	i_lcd_if : entity work.lcd_ctrl_if
		port map(
			Clk_CI              => clk,
			Reset_RI            => rst,
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

end architecture rtl;
