library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce is
   port(
      PMOD1_0_LS : in std_logic;                     -- Pin físico AN8 (Reset)
      PMOD1_1_LS : in std_logic;                     -- Pin físico AN9 (Reloj)
      PMOD1_2_LS : in std_logic;                     -- Pin físico AP11 (Control o evento)
      PMOD1_3_LS : in std_logic;                     -- Pin físico AN11 (Detección)
      PMOD1_4_LS : in std_logic;                     -- Pin físico AP9 (Transición de estado)
      db_level   : out std_logic;                    -- Nivel estable de debounce
      db_tick    : out std_logic                     -- Tick generado en estado estable
   );
end debounce;

architecture imp_fsmd_arch of debounce is
   constant N: integer := 21; -- Filtro de 2^N ciclos
   type state_type is (zero, wait0, one, wait1);
   signal state_reg, state_next: state_type;
   signal q_reg, q_next: unsigned(N-1 downto 0);
begin
   -- Registros de estado y datos
   process(PMOD1_0_LS, PMOD1_1_LS) -- Pines físicos asignados
   begin
      if PMOD1_0_LS = '1' then -- Reset asíncrono
         state_reg <= zero;
         q_reg <= (others => '0');
      elsif rising_edge(PMOD1_1_LS) then -- Reloj
         state_reg <= state_next;
         q_reg <= q_next;
      end if;
   end process;

   -- Lógica del próximo estado
   process(state_reg, q_reg, PMOD1_2_LS, q_next) -- Pines asignados
   begin
      state_next <= state_reg;
      q_next <= q_reg;
      db_tick <= '0';
      case state_reg is
         when zero =>
            db_level <= '0';
            if PMOD1_3_LS = '1' then -- Si se detecta un flanco ascendente
               state_next <= wait1;
               q_next <= (others => '1');
            end if;
         when wait1 =>
            db_level <= '0';
            if PMOD1_3_LS = '1' then
               q_next <= q_reg - 1;
               if q_next = 0 then
                  state_next <= one;
                  db_tick <= '1'; -- Genera un tick
               end if;
            else -- PMOD1_3_LS = '0'
               state_next <= zero;
            end if;
         when one =>
            db_level <= '1';
            if PMOD1_4_LS = '0' then
               state_next <= wait0;
               q_next <= (others => '1');
            end if;
         when wait0 =>
            db_level <= '1';
            if PMOD1_4_LS = '0' then
               q_next <= q_reg - 1;
               if q_next = 0 then
                  state_next <= zero;
               end if;
            else -- PMOD1_4_LS = '1'
               state_next <= one;
            end if;
      end case;
   end process;
end imp_fsmd_arch;

