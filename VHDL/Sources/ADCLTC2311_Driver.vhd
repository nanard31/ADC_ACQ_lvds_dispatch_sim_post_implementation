
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity ADCLTC2311_Driver is
    port(
        -- Reset and Clocks
        i_Rst_n         : in  std_logic;          -- General Reset, negative polarity
        i_Clk_100MHz    : in  std_logic;          -- State Machine clock
        -- Control
        i_Enable        : in  std_logic;          -- Enable flag to allow continuous sampling
        i_Debug_Pin_Sel : in  std_logic_vector(3 downto 0); -- Pattern selector
        o_Data_Ready    : out std_logic;          -- Ready flag when data register is up to date
        o_Data_Read     : out std_logic_vector(15 downto 0); -- Output data register from conversion
        -- ADC SPI
        o_ADC_SCK       : out std_logic;          -- SPI Serial Clock
        o_ADC_CNV_n     : out std_logic;          -- SPI Convert Input, negative polarity
        i_ADC_SDO       : in  std_logic;          -- SPI Slave Data Output (MISO)
        o_ADC_SCK_Gate  : out std_logic           -- Debug
    );
end ADCLTC2311_Driver;

architecture RTL of ADCLTC2311_Driver is

    -- State Machine
    type state_type is (S_Idle, S_Acquisition_and_Conversion);
    signal state : state_type;

    -- ADC Control Registers
    signal ADC_SCK_Gate      : std_logic;
    signal Master_Count      : unsigned(4 downto 0); -- Master count, max 31
    signal SPI_Received_Data : std_logic_vector(15 downto 0);

    signal Debug_cnt : unsigned(9 downto 0);

begin

    ------------------------------------------------------------------------------------------------------------------------------------------------------------
    --
    -- ADC SPI Protocol, deserializing data from Slave Data Output (SDO)
    --
    ------------------------------------------------------------------------------------------------------------------------------------------------------------

    p_ADC_SPI_Protocol : process(i_Rst_n, i_Clk_100MHz)
    begin
        if i_Rst_n = '0' then
            o_Data_Ready      <= '0';             -- No new value
            o_Data_Read       <= (others => '0'); -- Clear output
            o_ADC_CNV_n       <= '0';             -- No conversion requested
            ADC_SCK_Gate      <= '0';             -- Clock disable
            SPI_Received_Data <= (others => '0'); -- Empty buffer

            Master_Count <= (others => '0');
            Debug_cnt    <= (others => '0');
            state        <= S_Idle;               -- Start in idle state
        elsif rising_edge(i_Clk_100MHz) then
            -- FSM
            case state is                         -- FSM_freq = 100MHz, here sampling at here sampling at 4.5 MHz
                when S_Idle =>
                    -- Internal registers initialization
                    o_Data_Ready      <= '0';     -- No new value
                    o_ADC_CNV_n       <= '0';     -- No conversion requested
                    ADC_SCK_Gate      <= '0';     -- Clock disable
                    SPI_Received_Data <= (others => '0'); -- Empty buffer

                    if i_Enable = '1' then        -- Start a new acquisition only if enable
                        Master_Count <= (others => '0');
                        state        <= S_Acquisition_and_Conversion;
                    end if;
                ----------------------------------------------------------------------------------
                when S_Acquisition_and_Conversion =>
                    Master_Count <= Master_Count + "1"; -- Increment master count each cycle

                    case Master_Count is
                        --when 5X"00" =>            -- Start new acquisition, wait for at least 25ns with CNV_n in high state, here 3 cycles
                        when "00000" =>
							o_ADC_CNV_n <= '1';
							o_Data_Ready <= '0';
                        --when 5X"03" =>            -- End of acquisition, wait for at least 9.5ns, SCK Quiet Time from CNV_n falling edge
                        when "00011" =>
							--o_Data_Ready <= '0';  -- No new value
                            o_ADC_CNV_n  <= '0';
                        --when 5X"04" =>            -- Start new conversion
						when "00100" => 	
                            ADC_SCK_Gate <= '1';  -- Enable SCK
                        --when 5X"14" =>            -- End of conversion and readout, wait for at least 9.1ns, SCK Delay Time to CNV rising edge
                        when "10100" => 
							Master_Count <= (others => '0'); -- Reset counter for a new cycle
                            ADC_SCK_Gate <= '0';  -- Disable SCK
                            o_Data_Ready <= '1';  -- Strech pulse during at least 4 clock ticks
                            case i_Debug_Pin_Sel(2 downto 0) is
                                --when 3X"1" =>
								when "001" =>
                                    o_Data_Read <= X"5005";
                                --when 3X"2" =>
								when "010" =>
                                    o_Data_Read <= X"AFFA";
                                --when 3X"3" =>
								when "011" =>
                                    o_Data_Read <= SPI_Received_Data(14 downto 7) & X"55"; -- MSB & 0x55
                                --when 3X"4" =>
								when "100" =>
                                    o_Data_Read <= X"AA" & SPI_Received_Data(6 downto 0) & i_ADC_SDO; -- 0xAA & LSB
                                --when 3X"5" =>
								when "101" =>
                                    o_Data_Read <= X"D" & "00" & std_logic_vector(Debug_cnt); -- 4 + 2 + 10 bits
                                    Debug_cnt   <= Debug_cnt + "1";
                                when others =>
                                    o_Data_Read <= SPI_Received_Data(14 downto 0) & i_ADC_SDO;
                            end case;
                        when others =>            -- Do nothing
                    end case;

                    --if (Master_Count >= 5X"04" and Master_Count <= 5X"14") then
					if (Master_Count >= "00100" and Master_Count <= "10100") then
                        SPI_Received_Data <= SPI_Received_Data(14 downto 0) & i_ADC_SDO; -- Store the newly measured bit
                    end if;

                    if i_Enable = '0' then        -- Do not start a new acquisition only if disable
                        state <= S_Idle;
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

    o_ADC_SCK      <= i_Clk_100MHz when ADC_SCK_Gate = '1' else '1';
    o_ADC_SCK_Gate <= ADC_SCK_Gate;

    ------------------------------------------------------------------------------------------------------------------------------------------------------------
    --
    -- ADC SPI Protocol, deserializing data from Slave Data Output (SDO)
    --
    ------------------------------------------------------------------------------------------------------------------------------------------------------------

    --    p_ADC_Deserializer : process(i_Rst_n, i_Clk_100MHz)
    --    begin
    --        if i_Rst_n = '0' then
    --            SPI_Received_Data <= (others => '0'); -- Empty buffer
    --        elsif rising_edge(i_Clk_100MHz) then
    --            if ADC_SCK_Gate = '1' then
    --
    --                -- 16-bit standard SPI protocol, bits are received in descending order from bit #15 to bit #0
    --                SPI_Received_Data <= SPI_Received_Data(14 downto 0) & i_ADC_SDO; -- Store the newly measured bit
    --            else
    --                SPI_Received_Data <= (others => '0'); -- Empty buffer
    --            end if;
    --        end if;
    --    end process p_ADC_Deserializer;

end architecture RTL;
