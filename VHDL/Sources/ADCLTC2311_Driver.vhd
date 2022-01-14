
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity ADCLTC2311_Driver is
    port(
        -- Reset and Clocks
        i_Rst_n         : in  std_logic;          -- General Reset, negative polarity
        i_Clk_100MHz    : in  std_logic;          -- State Machine clock
        -- Control
        --i_Enable        : in  std_logic;          -- Enable flag to allow continuous sampling
        --i_Debug_Pin_Sel : in  std_logic_vector(3 downto 0); -- Pattern selector
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
            --Debug_cnt    <= (others => '0');
            --state        <= S_Idle;               -- Start in idle state
        elsif rising_edge(i_Clk_100MHz) then
            -- FSM
            Master_Count	<=	Master_Count + "1"; -- Increment master count each cycle
			
			o_Data_Ready      <= '0'; 
			
				if	Master_Count = "00000" then
				o_ADC_CNV_n <= '1';	
				else
					if	Master_Count = "00011" then
					o_ADC_CNV_n <= '0';	
					else
						if	Master_Count = "00100" then
						ADC_SCK_Gate <= '1';  -- Enable SCK
						else						
							--if (Master_Count >= "00101" and Master_Count < "10100") then
							if (Master_Count >= "00110" and Master_Count < "10101") then
								SPI_Received_Data <= SPI_Received_Data(14 downto 0) & i_ADC_SDO; -- Store the newly measured bit
								if	Master_Count = "10100" then
								ADC_SCK_Gate <= '0';  -- Disable SCK
								end if;
							else
									--if	Master_Count = "10100" then
									if	Master_Count = "10101" then
									SPI_Received_Data <= SPI_Received_Data(14 downto 0) & i_ADC_SDO; -- Store the newly measured bit
									--ADC_SCK_Gate <= '0';  -- Disable SCK
									else						
										--if	Master_Count = "10101" then
										if	Master_Count = "10110" then
										--SPI_Received_Data <= SPI_Received_Data(14 downto 0) & i_ADC_SDO; -- Store the newly measured bit
										Master_Count <= (others => '0'); -- Reset counter for a new cycle
										o_Data_Read		<=	SPI_Received_Data;			
										o_Data_Ready <= '1';  -- Strech pulse during at least 4 clock ticks	
										end if;	
									end if;
							end if;	
						end if;
					end if;	
				end if;
				
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
