
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity ADCLTC2311_Emulators is
    port(
        --------------------------------------------------------------------------------------------
        -- Reset
        --------------------------------------------------------------------------------------------
        i_Rst_n         : in  std_logic;          -- General Reset, negative polarity
        --------------------------------------------------------------------------------------------
        -- ADC Inputs
        --------------------------------------------------------------------------------------------
        i_FIFO_empty    : in  std_logic;          -- FIFO Empty flag
        o_FIFO_rd_en    : out std_logic;          -- FIFO Read Enable flag to request a new data
        i_FIFO_dout     : in  std_logic_vector(31 downto 0); -- Data register read from FIFO to convert
        --------------------------------------------------------------------------------------------
        -- ADC SPI
        --------------------------------------------------------------------------------------------
        i_ADC_SCK       : in  std_logic;          -- SPI Serial Clock, common to both ADC
        i_ADC_CNV_n     : in  std_logic;          -- SPI Convert Input, negative polarity; common to both ADC
        o_Front_ADC_SDO : out std_logic;          -- SPI Slave Data Output (MISO), front ADC
        o_Back_ADC_SDO  : out std_logic           -- SPI Slave Data Output (MISO), back ADC
    );
end ADCLTC2311_Emulators;

architecture RTL of ADCLTC2311_Emulators is

    signal SPI_Bit_Number_cpt      : unsigned(3 downto 0); -- 16-bit standard SPI protocol
    constant C_SDO_OutputDelayLine : time := 6 ns;

begin
    p_ADC_SPI_Protocol : process
    begin
        SPI_Bit_Number_cpt <= X"F";
        o_Front_ADC_SDO    <= 'Z';
        o_Back_ADC_SDO     <= 'Z';
        wait until i_Rst_n = '1';

        while True loop
            wait until rising_edge(i_ADC_CNV_n);
            -- CNV_n High
            if i_FIFO_empty = '0' then
                o_FIFO_rd_en <= '1';              -- Request new value from the FIFO
            end if;
            wait for 3 ns;                        -- Wait for bus relinquish time after CNV_n rising
            -- Outputs at high impedance during acquisition
            o_Front_ADC_SDO <= '0';
            o_Back_ADC_SDO  <= '0';

            wait until falling_edge(i_ADC_CNV_n);
            -- CNV_n Low
            o_FIFO_rd_en    <= '0';               -- No new value
            wait for 3 ns;                        -- Wait for SDO aata valid delay from CNV_n falling
            o_Front_ADC_SDO <= i_FIFO_dout(15);   -- Send MSB first
            o_Back_ADC_SDO  <= i_FIFO_dout(31);   -- Send MSB first

            while SPI_Bit_Number_cpt > X"0" loop
                wait until falling_edge(i_ADC_SCK); -- Clock at 100 MHz
                wait for C_SDO_OutputDelayLine;																		
                -- Bits are sent in descending order from bit #15 to bit #0 (front) and bit #31 to bit #16 (back)
                SPI_Bit_Number_cpt <= SPI_Bit_Number_cpt - "1";

                o_Front_ADC_SDO <= i_FIFO_dout(to_integer(SPI_Bit_Number_cpt)); -- Send bits #15-0
                o_Back_ADC_SDO  <= i_FIFO_dout(to_integer(SPI_Bit_Number_cpt) + 16); -- Send bits #31-16
            end loop;
        end loop;
    end process p_ADC_SPI_Protocol;

end architecture RTL;
