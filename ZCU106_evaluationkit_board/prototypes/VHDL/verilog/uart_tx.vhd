library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
   generic(
      DBIT    : integer := 8;   -- Número de bits de datos
      SB_TICK : integer := 16   -- Ticks para los bits de parada
   );
   port(
      UART2_TXD_O_FPGA_RXD : out std_logic;  -- Salida serie TX
      UART2_RTS_O_B        : out std_logic;  -- RTS
      UART2_RXD_I_FPGA_TXD : in  std_logic;   -- Entrada RX
      UART2_CTS_I_B        : in  std_logic    -- Entrada CTS
   );
end uart_tx;

architecture arch of uart_tx is
   type state_type is (idle, start, data, stop);
   signal state_reg, state_next : state_type;
   signal s_reg, s_next         : unsigned(3 downto 0);
   signal n_reg, n_next         : unsigned(2 downto 0);
   signal b_reg, b_next         : std_logic_vector(7 downto 0);
   signal tx_reg, tx_next       : std_logic;
begin

   -- Proceso secuencial: Registro de estado y lógica de datos
   process(UART2_RXD_I_FPGA_TXD, UART2_CTS_I_B)
   begin
      if UART2_CTS_I_B = '1' then
         state_reg <= idle;
         s_reg     <= (others => '0');
         n_reg     <= (others => '0');
         b_reg     <= (others => '0');
         tx_reg    <= '1';
      elsif rising_edge(UART2_RXD_I_FPGA_TXD) then
         state_reg <= state_next;
         s_reg     <= s_next;
         n_reg     <= n_next;
         b_reg     <= b_next;
         tx_reg    <= tx_next;
      end if;
   end process;

   -- Lógica combinacional: Lógica de transición de estados y control de salida
   process(state_reg, s_reg, n_reg, b_reg, UART2_CTS_I_B, tx_reg)
   begin
      state_next <= state_reg;
      s_next     <= s_reg;
      n_next     <= n_reg;
      b_next     <= b_reg;

      case state_reg is
         when idle =>
            tx_next <= '1';
            if UART2_CTS_I_B = '1' then
               state_next <= start;
               s_next     <= (others => '0');
               b_next     <= b_reg;
            end if;

         when start =>
            tx_next <= '0';
            if UART2_CTS_I_B = '1' then
               if s_reg = to_unsigned(15, s_reg'length) then
                  state_next <= data;
                  s_next     <= (others => '0');
                  n_next     <= (others => '0');
               else
                  s_next <= s_reg + 1;
               end if;
            end if;

         when data =>
            tx_next <= b_reg(0);
            if UART2_CTS_I_B = '1' then
               if s_reg = to_unsigned(15, s_reg'length) then
                  s_next <= (others => '0');
                  b_next <= '0' & b_reg(7 downto 1);
                  if n_reg = to_unsigned(DBIT - 1, n_reg'length) then
                     state_next <= stop;
                  else
                     n_next <= n_reg + 1;
                  end if;
               else
                  s_next <= s_reg + 1;
               end if;
            end if;

         when stop =>
            tx_next <= '1';
            if UART2_CTS_I_B = '1' then
               if s_reg = to_unsigned(SB_TICK - 1, s_reg'length) then
                  state_next <= idle;
               else
                  s_next <= s_reg + 1;
               end if;
            end if;

         when others =>
            state_next <= idle;
      end case;
   end process;

   -- Asignaciones de las señales internas a los puertos físicos
   UART2_TXD_O_FPGA_RXD <= tx_reg;
   UART2_RTS_O_B        <= '1';  -- Señal RTS fija en alto

end arch;

