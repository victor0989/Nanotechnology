library ieee;
use ieee.std_logic_1164.all;

entity sram_ctrl is
   port(
      FMC_HPC1_LA10_N       : in std_logic;                      -- Pin físico E22
      FMC_HPC1_LA10_P       : in std_logic;                      -- Pin físico F22
      FMC_HPC1_LA09_N       : in std_logic;                      -- Pin físico F20
      FMC_HPC1_LA09_P       : in std_logic_vector(17 downto 0);  -- Pin físico G20
      FMC_HPC1_LA14_N       : out std_logic;                     -- Pin físico D21
      FMC_HPC1_LA14_P       : out std_logic_vector(15 downto 0); -- Pin físico D20
      FMC_HPC1_LA06_N       : out std_logic_vector(17 downto 0); -- Pin físico H22
      FMC_HPC1_LA06_P       : out std_logic;                     -- Pin físico H21
      FMC_HPC1_LA12_N       : inout std_logic_vector(15 downto 0) -- Pin físico D19
   );
end sram_ctrl;

architecture arch of sram_ctrl is
   type state_type is (idle, rd1, rd2, wr1, wr2);
   signal state_reg, state_next : state_type;
   signal data_f2s_reg, data_f2s_next : std_logic_vector(15 downto 0);
   signal data_s2f_reg, data_s2f_next : std_logic_vector(15 downto 0);
   signal addr_reg, addr_next         : std_logic_vector(17 downto 0);
   signal we_buf, oe_buf, tri_buf     : std_logic;
   signal we_reg, oe_reg, tri_reg     : std_logic;

   -- Añadimos señales internas para reflejar las salidas
   signal FMC_HPC1_LA06_P_int : std_logic; -- Señal interna para lectura
   signal FMC_HPC1_LA06_N_int : std_logic_vector(17 downto 0); -- Señal interna para lectura
begin
   -- Asignación de las señales internas a las salidas
   FMC_HPC1_LA06_P <= FMC_HPC1_LA06_P_int;
   FMC_HPC1_LA06_N <= FMC_HPC1_LA06_N_int;

   -- Registro de estado y datos
   process(FMC_HPC1_LA10_N, FMC_HPC1_LA10_P)
   begin
      if FMC_HPC1_LA10_N = '1' then
         state_reg <= idle;
         addr_reg <= (others => '0');
         data_f2s_reg <= (others => '0');
         data_s2f_reg <= (others => '0');
         tri_reg <= '1';
         we_reg <= '1';
         oe_reg <= '1';
      elsif rising_edge(FMC_HPC1_LA10_P) then
         state_reg <= state_next;
         addr_reg <= addr_next;
         data_f2s_reg <= data_f2s_next;
         data_s2f_reg <= data_s2f_next;
         tri_reg <= tri_buf;
         we_reg <= we_buf;
         oe_reg <= oe_buf;
      end if;
   end process;

   -- Lógica del siguiente estado
   process(state_reg, FMC_HPC1_LA09_N, FMC_HPC1_LA09_P, FMC_HPC1_LA12_N, addr_reg, data_f2s_reg, data_s2f_reg, FMC_HPC1_LA06_P_int)
   begin
      addr_next <= addr_reg;
      data_f2s_next <= data_f2s_reg;
      data_s2f_next <= data_s2f_reg;

      case state_reg is
         when idle =>
            if FMC_HPC1_LA09_N = '0' then
               state_next <= idle;
            else
               addr_next <= FMC_HPC1_LA09_P;
               if FMC_HPC1_LA06_P_int = '0' then -- Escritura (ahora usamos la señal interna)
                  state_next <= wr1;
                  data_f2s_next <= FMC_HPC1_LA06_N_int;
               else -- Lectura
                  state_next <= rd1;
               end if;
            end if;

         when wr1 =>
            state_next <= wr2;

         when wr2 =>
            state_next <= rd2;

         when rd2 =>
            data_s2f_next <= FMC_HPC1_LA12_N;
            state_next <= idle;
      end case;
   end process;

   -- Lógica para las señales de control (look-ahead output)
   process(state_next)
   begin
      tri_buf <= '1';
      we_buf <= '1';
      oe_buf <= '1';
      case state_next is
         when idle =>
            tri_buf <= '1';
         when wr1 =>
            tri_buf <= '0';
            we_buf <= '0';
         when wr2 =>
            tri_buf <= '0';
         when rd1 =>
            oe_buf <= '0';
         when rd2 =>
            oe_buf <= '0';
      end case;
   end process;

   -- Asignaciones a SRAM
   FMC_HPC1_LA14_N <= oe_reg;
   FMC_HPC1_LA14_P <= std_logic_vector(data_s2f_reg);
   FMC_HPC1_LA06_N_int <= addr_reg;
   FMC_HPC1_LA06_P_int <= we_reg;
   FMC_HPC1_LA12_N <= data_f2s_reg when tri_reg = '0' else (others => 'Z');
end arch;
