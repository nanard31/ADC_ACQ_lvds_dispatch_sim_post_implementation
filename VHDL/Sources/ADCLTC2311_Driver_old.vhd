
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity ADCLTC2311_Driver is
    port(
        --------------------------------------------------------------------------------------------
        -- Reset
        --------------------------------------------------------------------------------------------
        i_Rst_n      : in  std_logic;             -- General Reset, negative polarity
        --------------------------------------------------------------------------------------------
        -- Clocks
        --------------------------------------------------------------------------------------------
        i_Clk        : in  std_logic;             -- SPI Serial Clock reference
        --------------------------------------------------------------------------------------------
        -- ADC
        --------------------------------------------------------------------------------------------
        o_Ready      : out std_logic;             -- Ready flag when data register is up to date
        o_Dout   : out std_logic_vector(15 downto 0); -- Output data register from conversion
        --------------------------------------------------------------------------------------------
        -- ADC SPI
        --------------------------------------------------------------------------------------------
        o_ADC_SCK    : out std_logic;             -- SPI Serial Clock
        --o_ADC_CNV_n  : out std_logic;             -- SPI Convert Input, negative polarity
        i_ADC_SDO    : in  std_logic              -- SPI Slave Data Output (MISO)
    );
end ADCLTC2311_Driver;

architecture RTL of ADCLTC2311_Driver is

    -- Serial Clock
    signal ADC_SCK_reg : std_logic;

    -- State Machine
    type state_type is (S_Idle, S_Acquisition, S_Conversion);
    signal state : state_type;

    -- ADC Control Registers
    signal SPI_Enable_SCK     : std_logic;
    signal SPI_Conversion_cnt : unsigned(1 downto 0); -- Wait at least
    signal SPI_Bit_Number_cnt : unsigned(3 downto 0); -- 16-bit standard SPI protocol
    signal SPI_Received_Data  : std_logic_vector(15 downto 0); -- Only the 12 LSB are useful for data output register

    signal Clk_100MHz : std_logic;
    
begin


div_clk : process(i_Rst_n, i_Clk)
    begin
        if i_Rst_n = '0' then
            Clk_100MHz <= '0';
        else
            if i_Clk = '1' and i_Clk'event then
                Clk_100MHz <= not Clk_100MHz;
            end if;
        end if;

    end process;
        
    ------------------------------------------------------------------------------------------------------------------------------------------------------------
    --
    -- ADC SPI Protocol, deserializing data from Slave Data Output (SDO)
    --
    ------------------------------------------------------------------------------------------------------------------------------------------------------------

    p_ADC_SPI_Protocol : process(i_Rst_n, Clk_100MHz)
    begin
        if i_Rst_n = '0' then
            o_Ready     <= '0';                   -- No new value
            o_Dout  <= (others => '0');       -- Clear output
            --o_ADC_CNV_n <= '0';                   -- No conversion requested

            SPI_Enable_SCK     <= '0';
            SPI_Conversion_cnt <= "00";
            SPI_Bit_Number_cnt <= X"F";           -- Send MSB first
            SPI_Received_Data  <= (others => '0'); -- Empty buffer
            state              <= S_Idle;         -- Start in idle state
        elsif rising_edge(Clk_100MHz) then
            -- FSM
            case state is                         -- FSM_freq = 100MHz, here sampling at here sampling at 4.35 MHz
                when S_Idle =>
                    -- Internal registers initialization
                    SPI_Enable_SCK     <= '0';
                    SPI_Conversion_cnt <= "00";
                    SPI_Bit_Number_cnt <= X"F";   -- Send MSB first
                    SPI_Received_Data  <= (others => '0'); -- Empty buffer

                    -- Outputs initialization
                    o_Ready     <= '0';           -- No new value
                    --o_ADC_CNV_n <= '0';           -- No conversion requested

                    -- Wait for at least 19.1ns, SCK Delay Time to CNV rising edge
                    -- Equivalent to 1 cycle in S_End_of_Conversion and 1 cycle in S_Idle, then auto start
                    state <= S_Acquisition;
                ----------------------------------------------------------------------------------
                when S_Acquisition =>
                    if SPI_Conversion_cnt < "11" then -- Wait for at least 25ns with CNV_n in high state
                        --o_ADC_CNV_n        <= '1'; -- Start new conversion
                        SPI_Conversion_cnt <= SPI_Conversion_cnt + "1";
                    else
                        --o_ADC_CNV_n <= '0';       -- No conversion requested
                        state       <= S_Conversion;
                    end if;
                ----------------------------------------------------------------------------------
                when S_Conversion =>
                    SPI_Enable_SCK <= '1';        -- Wait for at least 9.5ns, SCK Quiet Time from CNV_n falling edge

                    if SPI_Enable_SCK = '1' then
                        -- Store Data register bit
                        SPI_Received_Data <= SPI_Received_Data(14 downto 0) & i_ADC_SDO;

                        -- Bits are received in descending order from bit #15 to bit #0
                        SPI_Bit_Number_cnt <= SPI_Bit_Number_cnt - "1";

                        -- Check if end of conversion
                        if SPI_Bit_Number_cnt = X"0" then
                            SPI_Enable_SCK <= '0';
                            o_Ready        <= '1'; -- Data registers are up to date, all requested values have been converted
                            o_Dout     <= SPI_Received_Data(14 downto 0) & i_ADC_SDO; -- Store the last measured data
                            state          <= S_Idle; -- All bits have been sent
                        end if;
                    end if;
                ----------------------------------------------------------------------------------
                when others =>
                    state <= S_Idle;
            end case;
        end if;
    end process p_ADC_SPI_Protocol;

    ------------------------------------------------------------------------------------------------------------------------------------------------------------
    --
    -- ADC SPI Serial Clock (SCK) Generation
    --
    ------------------------------------------------------------------------------------------------------------------------------------------------------------

    p_ADC_SPI_SCK_Generator : process(i_Rst_n, Clk_100MHz)
    begin
        if i_Rst_n = '0' then
            ADC_SCK_reg <= '1';                   -- No clock
        elsif rising_edge(Clk_100MHz) then
            if SPI_Enable_SCK = '1' then
                ADC_SCK_reg <= not ADC_SCK_reg;   -- Toggle clock
            else
                ADC_SCK_reg <= '1';               -- No clock
            end if;
        end if;
    end process p_ADC_SPI_SCK_Generator;

    o_ADC_SCK <= ADC_SCK_reg;

end architecture RTL;
