----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:38:18 05/15/2014 
-- Design Name: 
-- Module Name:    UC_slave - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: la UC incluye un contador de 2 bits para llevar la cuenta de las transferencias de bloque y una máquina de estados
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UC_MC is
    Port ( 	clk : in  STD_LOGIC;
			reset : in  STD_LOGIC;
			RE : in  STD_LOGIC; --RE y WE son las ordenes del MIPs
			WE : in  STD_LOGIC;
			hit : in  STD_LOGIC; --se activa si hay acierto
			cjtoDist : in STD_LOGIC;
			bus_TRDY : in  STD_LOGIC; --indica que la memoria no puede realizar la operación solicitada en este ciclo
			Bus_DevSel: in  STD_LOGIC; --indica que la memoria ha reconocido que la dirección está dentro de su rango
			palabraAddr: in STD_LOGIC_VECTOR (1 downto 0); -- Nueva (parte optativa 2) para comprobar que palabra busca la CPU
			MC_RE : out  STD_LOGIC; --RE y WE de la MC
            MC_WE : out  STD_LOGIC;
            MC_bus_Rd_Wr : out  STD_LOGIC; --1 para escritura en Memoria y 0 para lectura
            MC_tags_WE : out  STD_LOGIC; -- para escribir la etiqueta en la memoria de etiquetas
			reg_ADDR_ini_en : out STD_LOGIC; -- para actualizar el reg con la direccion (nuevo optativo 1 y 2)
			reg_Din_ini_en : out STD_LOGIC; -- optativa 1
            palabra : out  STD_LOGIC_VECTOR (1 downto 0);--indica la palabra actual dentro de una transferencia de bloque (1ª, 2ª...)
            mux_origen: out STD_LOGIC; -- Se utiliza para elegir si el origen de la dirección y el dato es el Mips (cuando vale 0) o la UC y el bus (cuando vale 1)
			mux_out: out STD_LOGIC; -- Nueva para la parte optativa 2, sera 1 sii se debe mandar el dato del Bus directamente al CPU
            ready : out  STD_LOGIC; -- indica si podemos procesar la orden actual del MIPS en este ciclo. En caso contrario habrá que detener el MIPs
            block_addr : out  STD_LOGIC; -- indica si la dirección a enviar es la de bloque (rm) o la de palabra (w)
			MC_send_addr : out  STD_LOGIC; --ordena que se envíen la dirección y las señales de control al bus
            MC_send_data : out  STD_LOGIC; --ordena que se envíen los datos
            Frame : out  STD_LOGIC; --indica que la operación no ha terminado
			Replace_block	: out  STD_LOGIC; -- indica que se ha reemplazado un bloque
			inc_rm : out STD_LOGIC; -- indica que ha habido un fallo de lectura
			inc_wm : out STD_LOGIC; -- indica que ha habido un fallo de escritura
			inc_wh : out STD_LOGIC -- indica que ha habido un acierto de escritura
           );
end UC_MC;

architecture Behavioral of UC_MC is


component counter_2bits is
		    Port ( clk : in  STD_LOGIC;
		           reset : in  STD_LOGIC;
		           count_enable : in  STD_LOGIC;
		           count : out  STD_LOGIC_VECTOR (1 downto 0)
					  );
end component;
-------------------------------------------------------------------------------------------------
-- poner en el siguiente type el nombre de vuestros estados
type state_type is (Inicio,esperarDEVSel_R, esperarDEVSel_W,transPalabras,terminarTrans,frame0,esperarTRDY_W); 
signal state, next_state : state_type; 
signal last_word: STD_LOGIC; --se activa cuando se está pidiendo la última palabra de un bloque
signal count_enable: STD_LOGIC; -- se activa si se ha recibido una palabra de un bloque para que se incremente el contador de palabras
signal palabra_UC : STD_LOGIC_VECTOR (1 downto 0);
signal palabra_buscada : STD_LOGIC; -- nueva para calcular mux_out: 1 sii la palabra traida del bus es la buscada
--signal reg_set_ini_en : STD_LOGIC; -- nueva para actualizar el tag (optativa 2)
begin


--el contador nos dice cuantas palabras hemos recibido. Se usa para saber cuando se termina la transferencia del bloque y para direccionar la palabra en la que se escribe el dato leido del bus en la MC
word_counter: counter_2bits port map (clk, reset, count_enable, palabra_UC); --indica la palabra actual dentro de una transferencia de bloque (1ª, 2ª...)

last_word <= '1' when palabra_UC="11" else '0';--se activa cuando estamos pidiendo la última palabra

palabra <= palabra_UC;

   SYNC_PROC: process (clk)
   begin
      if (clk'event and clk = '1') then
         if (reset = '1') then
            state <= Inicio;
         else
            state <= next_state;
         end if;        
      end if;
   end process;
 
 palabra_buscada <= '1' when palabra_UC=palabraAddr else '0'; -- nuevo

 
   -- Poned aquí el código de vuestra máquina de estados
   OUTPUT_DECODE: process (state, hit, cjtoDist, last_word, bus_TRDY, RE, WE, Bus_DevSel, palabra_buscada)
   begin
		-- Se comienza dando los valores por defecto, si no se asigna otro valor en un estado valdrán lo que se asigna aquí
		-- Así no hay que asignar valor a todas las señales en cada caso
		MC_WE <= '0';
		MC_bus_Rd_Wr <= '0';
		MC_tags_WE <= '0';
        MC_RE <= RE;
        ready <= '0';
        mux_origen <= '0';
		mux_out <= '0';  -- nueva señal para la parte optativa 2
        MC_send_addr <= '0';
        MC_send_data <= '0';
        next_state <= state;  
		count_enable <= '0';
		Frame <= '0';
		Replace_block <= '0';	
		block_addr <= '0';
		inc_rm <= '0';
		inc_wm <= '0';
		inc_wh <= '0';
		reg_Din_ini_en <= '0';
		reg_ADDR_ini_en <= '0';
			
        -- Estado INICIO:         
        if (state = Inicio and RE= '0' and WE= '0') then -- si no piden nada no hacemos nada
				next_state <= Inicio;
				ready <= '1';
		elsif (state = Inicio and RE='1' and hit='1') then
				next_state <= Inicio;
				ready<='1';
				MC_RE<='1';
				mux_origen<='0'; --estaba a 1 y creo que tiene que ser 0
		elsif (state = Inicio and RE='1' and hit='0') then
				if (Bus_DevSel='0') then
					next_state <= esperarDEVSel_R;
				else
					next_state <= transPalabras;
				end if;
				Block_addr<='1';
				Frame<='1';
				MC_send_addr<='1';
				MC_bus_Rd_Wr<='0';
				inc_rm <='1';
				reg_ADDR_ini_en<='1'; -- guardamos la direccion (optativo 2)
		elsif (state = Inicio and WE='1') then
				if (Bus_DevSel='0') then
					next_state <= esperarDEVSel_W;
				else
					next_state <= esperarTRDY_W;
				end if;
				Frame<='1';
				MC_bus_Rd_Wr<='1';
				MC_send_addr<='1';
				reg_ADDR_ini_en<='1';
				reg_Din_ini_en<='1';
				ready<='1';
				if (hit='1') then
					MC_WE<='1';
					inc_wh <='1';
				else 
					inc_wm<= '1';
				end if;
		-- LECTURA:	
		elsif (state = esperarDEVSel_R and Bus_DevSel='0') then
				next_state <= esperarDEVSel_R;
				Block_addr<='1';
				Frame<='1';
				MC_send_addr<='1';
		elsif (state = esperarDEVSel_R and Bus_DevSel='1') then
				next_state <= transPalabras;
				Frame<='1'; 
		elsif (state = transPalabras and Bus_TRDY='0') then
				next_state <= transPalabras;
				Frame<='1'; 
		elsif (state = transPalabras and Bus_TRDY='1' and palabra_buscada='0') then
				next_state <= transPalabras;
				Frame<='1'; 	
				MC_WE<='1';
				mux_origen<='1';
				count_enable<='1';
		elsif (state = transPalabras and Bus_TRDY='1' and last_word='1') then
				next_state <= frame0;
				Frame<='1'; 
				MC_WE<='1';
				mux_origen<='1';
				count_enable<='1';
				MC_tags_WE<='1';
				Replace_block<='1';
				mux_out<='1';
		elsif (state = transPalabras and Bus_TRDY='1' and palabra_buscada='1') then
				next_state <= terminarTrans;
				Frame<='1'; 	
				MC_WE<='1';
				mux_origen<='1';
				mux_out<='1';
				count_enable<='1';
				ready<='1';
		-- TERMINAR TRANSMISION (PALABRA YA ENVIADA)
		elsif (state = terminarTrans and Bus_TRDY='0') then
				next_state <= terminarTrans;
				Frame<='1'; 
				if (RE='0' and WE='0') then
					ready<='1';
				elsif (RE='1' and hit='1' and cjtoDist='1') then
					MC_RE<='1';
					ready<='1';
				-- en cualquier otro caso, ready=0
				end if;
		elsif (state = terminarTrans and Bus_TRDY='1') then
				MC_WE <= '1';
				mux_origen <= '1';
				count_enable <= '1';
				Frame<='1';
				if (RE='0' and WE='0') then
					ready<='1';
				end if;
				if (last_word='0') then
					next_state <= terminarTrans;
				else
					next_state <= frame0;
					MC_tags_WE<='1';
					Replace_block <= '1';
				end if;
		-- FRAME A 0:
		elsif (state = frame0 and RE='1' and hit='1') then
				next_state <= Inicio;
				ready<='1';
				MC_RE<='1';
				--mux_origen<='0';
				--Frame<='0'; -- lo hace por defecto
		elsif (state = frame0 and RE= '0' and WE= '0') then -- si no piden nada no hacemos nada
				next_state <= Inicio;
				ready <= '1';
				--Frame<=0; 
		elsif (state = frame0 and (WE='1' or hit='0')) then -- si no piden nada no hacemos nada
				next_state <= Inicio;
				ready <= '0';
				--Frame <=0
				
		-- ESCRITURA: 
		elsif (state = esperarDEVSel_W) then
				Frame<='1';
				MC_send_addr<='1';
				MC_bus_Rd_Wr<='1';
				if (Bus_DevSel='0') then
					next_state <= esperarDEVSel_W;
				else 
					next_state <= esperarTRDY_W;
				end if;
				if (RE='0' and WE='0') then
					ready<='1';
				elsif (RE='1' and hit='1') then
					MC_RE<='1';
					ready<='1';
				-- en cualquier otro caso, ready es 0
				end if;
		
		elsif (state = esperarTRDY_W) then -- NO ME FIO MUCHO DE ESTE, REVISAR
				Frame<='1';
				MC_bus_Rd_Wr<='1'; -- no se si es imprescindible
				if (Bus_TRDY='0') then
					next_state <= esperarTRDY_W;
				else 
					next_state <= frame0;
					MC_send_data <= '1';
				end if;
				if (RE='0' and WE='0') then
					ready<='1';
				elsif (RE='1' and hit='1') then
					MC_RE<='1';
					ready<='1';
				-- en cualquier otro caso, ready es 0
				end if;
		
		end if;
   end process;
 
   
end Behavioral;

