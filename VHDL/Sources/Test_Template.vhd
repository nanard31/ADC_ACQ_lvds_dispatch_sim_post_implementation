library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Test_Template is
    port(
        rst             : in  std_logic;
        clk             : in  std_logic;
        i_start         : in  std_logic;
        o_finished      : out std_logic;
        i_debug_en      : in  std_logic;
        o_start_led     : out std_logic;
        --i_Samples_count : in  std_logic_vector(31 downto 0);
        o_Data          : out std_logic_vector(127 downto 0);
        o_Rdy           : out std_logic_vector(0 to 7);
  
		o_ADC_SCK     	: out std_logic_vector(0 to 3);             -- SPI Serial Clock
        o_ADC_CNV_n   	: out std_logic_vector(0 to 3);             -- SPI Convert Input, negative polarity
        i_ADC_SDO     	: in  std_logic_vector(0 to 7);
		
		init_calib_complete: in  std_logic
  
        -- o_ADC_SCK_p     : out std_logic_vector(0 to 7);
        -- o_ADC_SCK_n     : out std_logic_vector(0 to 7);
        -- o_ADC_CNV_n     : out std_logic_vector(0 to 7);
        -- i_ADC_SDO_p     : in std_logic_vector(0 to 7);
        -- i_ADC_SDO_n     : in std_logic_vector(0 to 7)
    
    );
end entity Test_Template;

architecture RTL of Test_Template is

    signal count : integer;
    signal data  : integer;
    signal debug : std_logic;
    signal rst_n : std_logic;

    signal o_Ready : std_logic_vector(0 to 7);
    signal o_Dout : std_logic_vector(16*8-1 downto 0);


begin

    ------------------------------------------------------------------------------------------------------------------------------------
    --
    -- ADCs
    --
    ------------------------------------------------------------------------------------------------------------------------------------

    rst_n <= not rst;

    ADCs_Drivers : entity work.ADCs
        port map(
            i_Rst_n     => rst_n,
            i_Clk       => clk,
            o_Ready     => o_Ready,
            o_Dout      => o_Dout,
			
			o_ADC_SCK    => o_ADC_SCK,            -- SPI Serial Clock
			o_ADC_CNV_n => o_ADC_CNV_n,         -- SPI Convert Input, negative polarity
			i_ADC_SDO    => i_ADC_SDO             -- SPI Slave Data Output (MISO)			
			
            -- o_ADC_SCK_p => o_ADC_SCK_p,
            -- o_ADC_SCK_n => o_ADC_SCK_n,
            -- o_ADC_CNV_n => o_ADC_CNV_n,
            -- i_ADC_SDO_p => i_ADC_SDO_p,
            -- i_ADC_SDO_n => i_ADC_SDO_n
        );

    ------------------------------------------------------------------------------------------------------------------------------------
    --
    -- ADCs simulator
    --
    ------------------------------------------------------------------------------------------------------------------------------------

    o_start_led <= debug;

                        -- o_Data <= o_Dout;
                        -- o_Rdy <= o_Ready(0);
                        
   fsm_process : process(clk, rst) is
       type state_type is (IDLE, WRITE_DATA, WAIT_NEXT);
       variable state : state_type := IDLE;

   begin
       if rst = '1' then
           count      <= 0;
           data       <= 0;
           o_Data     <= (others => '0');
           o_Rdy      <= (others => '0');
           o_finished <= '0';
           debug      <= '0';
           state      := IDLE;
       elsif rising_edge(clk) then

           case state is

               when IDLE =>
                   count      <= 0;
                   data       <= 0;
                   o_Data     <= (others => '0');
                   o_Rdy      <= (others => '0');
                   o_finished <= '0';
                   if i_start = '1' or init_calib_complete = '1' then
                       debug <= not debug;
                       state := WRITE_DATA;
                   end if;

               when WRITE_DATA =>

--                    if i_debug_en = '1' then
--                        o_Data <= X"16651664" & std_logic_vector(to_unsigned(data, 16)) & std_logic_vector(to_unsigned(data, 16)) & std_logic_vector(to_unsigned(data, 16)) & std_logic_vector(to_unsigned(data, 16)) & std_logic_vector(to_unsigned(data, 16)) & std_logic_vector(to_unsigned(data, 16));
--                        o_Rdy  <= '1';
--                        count  <= 0;
--                        data   <= data + 1;
--                        state := WAIT_NEXT;
--                    else
                       o_Data <= o_Dout;
                       o_Rdy <= o_Ready;
					   data   <= data + 1;
--                    end if;

                   

               when WAIT_NEXT =>

                   o_Rdy <= (others => '0');
                   count <= count + 1;

                   if count >= 20 then
                       state := WRITE_DATA;
                   end if;

                   --if data >= unsigned(i_Samples_count) then
                       o_finished <= '1';
                       state      := IDLE;
                   --end if;
           end case;

       end if;
   end process fsm_process;

end architecture RTL;
