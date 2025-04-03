library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; -- Necesario para las operaciones con tipos unsigned

entity ps2_rx is
   port(
      FMC_HPC0_LA23_N    : in std_logic;                      -- Pin físico A11
      FMC_HPC0_LA23_P    : in std_logic;                      -- Pin físico B11
      FMC_HPC0_LA27_N    : in std_logic;                      -- Pin físico A7
      FMC_HPC0_LA27_P    : in std_logic;                      -- Pin físico A8
      FMC_HPC0_LA21_N    : out std_logic;                     -- Pin físico A10
      FMC_HPC0_LA21_P    : out std_logic_vector(7 downto 0)   -- Pin físico B10
   );
end ps2_rx;

architecture arch of ps2_rx is
   -- Declaración de señales internas
   type statetype is (idle, dps, load);
   signal state_reg, state_next : statetype;
   signal filter_reg, filter_next : std_logic_vector(7 downto 0);
   signal f_ps2c_reg, f_ps2c_next : std_logic;
   signal b_reg, b_next : std_logic_vector(10 downto 0);
   signal n_reg, n_next : unsigned(3 downto 0);
   signal fall_edge : std_logic;

begin
   -- Filtro y detección de flanco descendente para ps2c
   process(FMC_HPC0_LA23_N, FMC_HPC0_LA23_P)
   begin
      if FMC_HPC0_LA23_N = '1' then
         filter_reg <= (others => '0');
         f_ps2c_reg <= '0';
      elsif rising_edge(FMC_HPC0_LA23_P) then
         filter_reg <= filter_next;
         f_ps2c_reg <= f_ps2c_next;
      end if;
   end process;

   -- Lógica del filtro
   filter_next <= FMC_HPC0_LA27_N & filter_reg(7 downto 1); -- Desplazador
   f_ps2c_next <= '1' when filter_reg = "11111111" else
                  '0' when filter_reg = "00000000" else
                  f_ps2c_reg;
   fall_edge <= f_ps2c_reg and not f_ps2c_next;

   -- FSMD para extraer los datos de 8 bits
   process(FMC_HPC0_LA23_N, FMC_HPC0_LA23_P)
   begin
      if FMC_HPC0_LA23_N = '1' then
         state_reg <= idle;
         n_reg <= (others => '0');
         b_reg <= (others => '0');
      elsif rising_edge(FMC_HPC0_LA23_P) then
         state_reg <= state_next;
         n_reg <= n_next;
         b_reg <= b_next;
      end if;
   end process;

   -- Lógica del próximo estado
   process(state_reg, n_reg, b_reg, fall_edge, FMC_HPC0_LA27_P, FMC_HPC0_LA27_N)
   begin
      FMC_HPC0_LA21_N <= '0'; -- Estado por defecto
      state_next <= state_reg;
      n_next <= n_reg;
      b_next <= b_reg;

      case state_reg is
         when idle =>
            if fall_edge = '1' and FMC_HPC0_LA27_P = '1' then
               -- Inicio del bit
               b_next <= FMC_HPC0_LA27_N & b_reg(10 downto 1);
               n_next <= "1001"; -- Carga de 9 bits
               state_next <= dps;
            end if;

         when dps =>
            if fall_edge = '1' then
               b_next <= FMC_HPC0_LA27_N & b_reg(10 downto 1);
               if n_reg = 0 then
                  state_next <= load;
               else
                  n_next <= n_reg - 1;
               end if;
            end if;

         when load =>
            -- Extra clock para completar el último desplazamiento
            state_next <= idle;
            FMC_HPC0_LA21_N <= '1'; -- Señal de dato recibido
      end case;
   end process;

   -- Salida de datos
   FMC_HPC0_LA21_P <= b_reg(8 downto 1); -- Bits de datos finales
end arch;

