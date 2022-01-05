library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity Dispatch_board is
    port(
        
        --------------------------------------------------------------------------------------------
        -- Reset
        --------------------------------------------------------------------------------------------
        i_Rst_n      : in  std_logic;             -- General Reset, negative polarity
        -- --------------------------------------------------------------------------------------------
        -- -- Clocks
        -- --------------------------------------------------------------------------------------------
        -- i_Clk        : in  std_logic;             -- SPI Serial Clock reference

        --------------------------------------------------------------------------------------------
        -- ADC SPI
        --------------------------------------------------------------------------------------------
		
        i_ADC_SCK_p    : in std_logic_vector(3 downto 0);             -- SPI Serial Clock
        i_ADC_SCK_n    : in std_logic_vector(3 downto 0);             -- SPI Serial Clock
        
        i_ADC_CNV_n    : in std_logic_vector(3 downto 0);             -- SPI Convert Input, negative polarity
        
        o_ADC_SDO_p    : out  std_logic_vector(7 downto 0);              -- SPI Slave Data Output (MISO)
        o_ADC_SDO_n    : out  std_logic_vector(7 downto 0)              -- SPI Slave Data Output (MISO)     
           
    );
end entity Dispatch_board;

architecture RTL of Dispatch_board is
    
-- -- signal iADC_SCK    : std_logic_vector(0 to 7);             -- SPI Serial Clock
signal ADC_SCK    				: std_logic_vector(3 downto 0);              -- SPI Slave Data Output (MISO)
signal TB_ADC_Data_to_send     	: unsigned(15 downto 0) := (others => '0');
signal init						: unsigned(15 downto 0) := (others => '0');
-- signal ADC_CNV_n  : std_logic_vector(0 to 7);         

-- signal iSCK  : std_logic_vector(0 to 7); 
signal ADC_SDO  				: std_logic_vector(7 downto 0); 
signal o_Front_ADC_SDO			: std_logic;

signal debug_CNV : std_logic;
signal debug_SCK : std_logic;	
signal debug_SDO : std_logic;

signal cnt		:	integer :=0;

signal o_FIFO_rd_en    :	std_logic;          -- FIFO Read Enable flag to request a new data
signal i_FIFO_dout     :	std_logic_vector(31 downto 0); -- Data register read from FIFO to convert
signal i_FIFO_dout_unsigned     :	unsigned(31 downto 0); -- Data register read from FIFO to convert

begin

gen_IBUFDS_SCK : for I in 3 downto 0 generate
	IBUFDS_SCK : IBUFDS
	generic map (
      IOSTANDARD => "LVDS_25")
	port map (
      I 	=> i_ADC_SCK_p(I),     	-- Diff_p output (connect directly to top-level port)
      IB 	=> i_ADC_SCK_n(I),   	-- Diff_n output (connect directly to top-level port)
      O 	=>  ADC_SCK(I)     		-- Buffer input 
	);
	end generate gen_IBUFDS_SCK;

	
lebel_emulator : entity work.ADCLTC2311_Emulators
	port map (
        --------------------------------------------------------------------------------------------
        -- Reset
        --------------------------------------------------------------------------------------------
        i_Rst_n         =>	i_Rst_n,
        --------------------------------------------------------------------------------------------
        -- ADC Inputs
        --------------------------------------------------------------------------------------------
        i_FIFO_empty    =>	'0',	
        o_FIFO_rd_en    =>	o_FIFO_rd_en,
        i_FIFO_dout     =>	std_logic_vector(i_FIFO_dout_unsigned),
        --------------------------------------------------------------------------------------------
        -- ADC SPI
        --------------------------------------------------------------------------------------------
        i_ADC_SCK       =>	ADC_SCK(0),
        i_ADC_CNV_n     =>	i_ADC_CNV_n(0),
        o_Front_ADC_SDO =>	o_Front_ADC_SDO,
        o_Back_ADC_SDO  =>	open
    );
	
    data_emul : process
    begin
	
		i_FIFO_dout_unsigned <= (others => '0');
        wait until i_Rst_n = '1';
		
        while True loop
            wait until rising_edge(o_FIFO_rd_en);
			i_FIFO_dout_unsigned <= i_FIFO_dout_unsigned + "1";
        end loop; 
		
    end process data_emul;
		
gen_adssdo : for i in 7 downto 0 generate	
ADC_SDO(i) <= o_Front_ADC_SDO;	
end generate;
 
gen_OBUFDS_ADC_SDO : for I in 7 downto 0 generate 
	OBUFDS_ADC_SDO : OBUFDS
	generic map (
    IOSTANDARD => "LVDS_25")
	port map (
      O 	=> o_ADC_SDO_p(I),     	-- Diff_p output (connect directly to top-level port)
      OB 	=> o_ADC_SDO_n(I),   	-- Diff_n output (connect directly to top-level port)
      I 	=> ADC_SDO(I)     -- Buffer input 
	);	
end generate gen_OBUFDS_ADC_SDO;

debug_CNV	<= i_ADC_CNV_n(0);
debug_SCK	<= ADC_SCK(0);
debug_SDO	<= ADC_SDO(0);

	
-- o_ADC_CNV_n(0)	<= ADC_CNV_n(0);
-- o_ADC_CNV_n(1)	<= ADC_CNV_n(2);
-- o_ADC_CNV_n(2)	<= ADC_CNV_n(4);
-- o_ADC_CNV_n(3)	<= ADC_CNV_n(6);
  
-- o_ADC_SCK(0)	<= ADC_SCK(0);	-- DU 1
-- o_ADC_SCK(1)	<= ADC_SCK(2);	-- DU 2
-- o_ADC_SCK(2)	<= ADC_SCK(4);	-- DU 3
-- o_ADC_SCK(3)	<= ADC_SCK(6);	-- DU 4
  

			
-- o_ADC_CNV_n <= iADC_CNV_n;

-- iSCK(0) <= not iADC_SCK(0);             -- DU 1
-- iSCK(1) <= iADC_SCK(1);
-- iADC_SDO(0) <= iSDO(0);
-- iADC_SDO(1) <= iSDO(1);

-- iSCK(2) <= not iADC_SCK(2);             -- DU 2
-- iSCK(3) <= iADC_SCK(3);
-- iADC_SDO(2) <= iSDO(2);
-- iADC_SDO(3) <= not iSDO(3);

-- iSCK(4) <= not iADC_SCK(4);             -- DU 3
-- iSCK(5) <= iADC_SCK(5);
-- iADC_SDO(4) <= iSDO(4);
-- iADC_SDO(5) <= iSDO(5);

-- iSCK(6) <= iADC_SCK(6);                 -- DU 4
-- iSCK(7) <= iADC_SCK(7);
-- iADC_SDO(6) <= iSDO(6);
-- iADC_SDO(7) <= not iSDO(7);


end architecture RTL;
