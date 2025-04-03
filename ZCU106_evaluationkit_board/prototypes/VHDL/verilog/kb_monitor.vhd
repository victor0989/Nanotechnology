library ieee;
use ieee.std_logic_1164.all;

entity kb_monitor is
   port(
      DDR4_PAR     : in std_logic;                     -- Pin físico AC13
      DDR4_CKE     : in std_logic;                     -- Pin físico AB13
      DDR4_RESET_B : out std_logic                     -- Pin físico AF12
   );
end kb_monitor;

architecture arch of kb_monitor is
   constant SP: std_logic_vector(7 downto 0) := "00100000"; -- Espacio en ASCII

   type statetype is (idle, send1, send0, sendb);
   signal state_reg, state_next : statetype;
   signal scan_data, w_data : std_logic_vector(7 downto 0);
   signal scan_done_tick : std_logic;
   signal ascii_code : std_logic_vector(7 downto 0);
   signal hex_in : std_logic_vector(3 downto 0);
begin

   -- FSM para manejar los datos del teclado PS/2
   process(DDR4_PAR)
   begin
      if rising_edge(DDR4_PAR) then
         if DDR4_CKE = '0' then
            state_reg <= idle;
         else
            state_reg <= state_next;
         end if;
      end if;
   end process;

   -- Lógica del próximo estado
   process(state_reg, scan_done_tick, ascii_code)
   begin
      state_next <= state_reg;
      case state_reg is
         when idle =>
            if scan_done_tick = '1' then
               state_next <= send1;
            end if;

         when send1 =>
            state_next <= send0;

         when send0 =>
            state_next <= sendb;

         when sendb =>
            state_next <= idle;
      end case;
   end process;

   -- Código de escaneo a ASCII
   hex_in <= scan_data(7 downto 4) when state_reg = send1 else scan_data(3 downto 0);

   -- Conversión de dígitos hexadecimales a código ASCII
   with hex_in select
      ascii_code <=
         "00110000" when "0000", -- 0
         "00110001" when "0001", -- 1
         "00110010" when "0010", -- 2
         "00110011" when "0011", -- 3
         "00110100" when "0100", -- 4
         "00110101" when "0101", -- 5
         "00110110" when "0110", -- 6
         "00110111" when "0111", -- 7
         "00111000" when "1000", -- 8
         "00111001" when "1001", -- 9
         "01000001" when "1010", -- A
         "01000010" when "1011", -- B
         "01000011" when "1100", -- C
         "01000100" when "1101"; -- D;
end arch;

