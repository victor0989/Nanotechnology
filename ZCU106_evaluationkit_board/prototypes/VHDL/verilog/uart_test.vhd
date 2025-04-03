library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_test is
   port(
      UART2_CTS_I_B   : in std_logic;                    -- Pin físico AP17
      PCIE_PERST_B    : in std_logic_vector(2 downto 0); -- Pin físico L8
      PCIE_WAKE_B     : in std_logic;                    -- Pin físico L10
      UART_TX         : out std_logic_vector(10 downto 0); -- Salida del transmisor UART
      UART_RX_DATA    : out std_logic_vector(7 downto 0); -- Datos recibidos
      UART_TX_DATA    : out std_logic_vector(7 downto 0) -- Datos enviados
   );
end uart_test;

architecture arch of uart_test is
   signal tx_full, rx_empty : std_logic;
   signal rec_data, rec_data1 : std_logic_vector(7 downto 0);
   signal btn_tick : std_logic;
begin
   -- Incremental data loopback
   rec_data1 <= std_logic_vector(unsigned(rec_data) + 1);

   -- Led display
   UART_RX_DATA <= rec_data;
   UART_TX_DATA <= "11100000"; -- Ejemplo LED Display
   
   
end arch;

