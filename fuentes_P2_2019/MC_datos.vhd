----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:38:16 04/08/2014 
-- Design Name: 
-- Module Name:    
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: La memoria cache está compuesta de 4 bloques de 4 datos con: emplazamiento directo, escritura directa, y la politica convencional en fallo de escritura (fetch on write miss). 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all; -- se usa para convertir std_logic a enteros


entity MC_datos is port (
			CLK : in std_logic;
			reset : in  STD_LOGIC;
			--Interfaz con el MIPS
			ADDR : in std_logic_vector (31 downto 0); --Dir 
			Din : in std_logic_vector (31 downto 0);
			RE : in std_logic;		-- read enable		
			WE : in  STD_LOGIC; 
			ready : out  std_logic;  -- indica si podemos hacer la operación solicitada en el ciclo actual
			Dout : out std_logic_vector (31 downto 0); --dato que se envía al Mips
			--Interfaz con el bus
			MC_Bus_Din : in std_logic_vector (31 downto 0);--para leer datos del bus
			Bus_TRDY : in  STD_LOGIC; --indica que el esclavo (la memoriade datos)  no puede realizar la operación solicitada en este ciclo
			Bus_DevSel: in  STD_LOGIC; --indica que la memoria ha reconocido que la dirección está dentro de su rango
			MC_send_addr : out  STD_LOGIC; --ordena que se envíen la dirección y las señales de control al bus
			MC_send_data : out  STD_LOGIC; --ordena que se envíen los datos
			MC_frame : out  STD_LOGIC; --indica que la operación no ha terminado
			MC_Bus_ADDR : out std_logic_vector (31 downto 0); --Dir 
			MC_Bus_data_out : out std_logic_vector (31 downto 0);--para enviar datos por el bus
			MC_bus_Rd_Wr : out  STD_LOGIC --'0' para lectura,  '1' para escritura
			 );
end MC_datos;

architecture Behavioral of MC_datos is

component UC_MC is
    Port ( 	clk : in  STD_LOGIC;
			reset : in  STD_LOGIC;
			RE : in  STD_LOGIC; --RE y WE son las ordenes del MIPs
			WE : in  STD_LOGIC;
			hit : in  STD_LOGIC; --se activa si hay acierto
			bus_TRDY : in  STD_LOGIC; --indica que la memoria no puede realizar la operación solicitada en este ciclo
			Bus_DevSel: in  STD_LOGIC; --indica que la memoria ha reconocido que la dirección está dentro de su rango
			MC_RE : out  STD_LOGIC; --RE y WE de la MC
            MC_WE : out  STD_LOGIC;
            MC_bus_Rd_Wr : out  STD_LOGIC; --1 para escritura en Memoria y 0 para lectura
            MC_tags_WE : out  STD_LOGIC; -- para escribir la etiqueta en la memoria de etiquetas
			reg_ADDR_ini_en : out STD_LOGIC; -- para actualizar el reg con la dir (nuevo optativo 1 y 2)
			reg_Din_ini_en : out STD_LOGIC; -- para actualizar el reg con el dato entrante de CPU (nuevo optativo 1)
            palabra : out  STD_LOGIC_VECTOR (1 downto 0);--indica la palabra actual dentro de una transferencia de bloque (1ª, 2ª...)
			palabraAddr: in STD_LOGIC_VECTOR (1 downto 0); -- Nueva (parte optativa 2) para comprobar que palabra busca la CPU
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
end component;

component reg4 is
    Port (  Din : in  STD_LOGIC_VECTOR (3 downto 0);
            clk : in  STD_LOGIC;
			reset : in  STD_LOGIC;
            load : in  STD_LOGIC;
            Dout :out  STD_LOGIC_VECTOR (3 downto 0));
end component;		

-- Nuevo parte optativa 2 (para reg_set_ini)
component reg32 is
    Port (  Din : in  STD_LOGIC_VECTOR (31 downto 0);
            clk : in  STD_LOGIC;
			reset : in  STD_LOGIC;
            load : in  STD_LOGIC;
            Dout :out  STD_LOGIC_VECTOR (31 downto 0));
end component;	


component counter is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           count_enable : in  STD_LOGIC;
           load : in  STD_LOGIC;
           D_in  : in  STD_LOGIC_VECTOR (7 downto 0);
		   count : out  STD_LOGIC_VECTOR (7 downto 0));
end component;	  

-- definimos la memoria de contenidos de la cache de datos como un array de 16 palabras de 32 bits
type Ram_MC_data is array(0 to 15) of std_logic_vector(31 downto 0);
signal MC_data : Ram_MC_data := (  		X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", -- posiciones 0,1,2,3,4,5,6,7
									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000");									
-- definimos la memoria de etiquetas de la cache de datos como un array de 4 palabras de 26 bits
type Ram_MC_Tags is array(0 to 3) of std_logic_vector(25 downto 0);
signal MC_Tags : Ram_MC_Tags := (  		"00000000000000000000000000", "00000000000000000000000000", "00000000000000000000000000", "00000000000000000000000000");												
signal valid_bits_in, valid_bits_out, mask: std_logic_vector(3 downto 0); -- se usa para saber si un bloque tiene info válida. Cada bit representa un bloque.									
signal dir_cjto: std_logic_vector(1 downto 0); -- se usa para elegir el cjto al que se accede en la cache de datos. 
signal dir_palabra: std_logic_vector(1 downto 0); -- se usa para elegir la dato solicitada de un determinado bloque. 
signal internal_MC_bus_Rd_Wr, mux_origen, MC_WE, MC_RE, MC_Tags_WE, hit, valid_bit, replace_block, block_addr: std_logic;
signal palabra_UC: std_logic_vector(1 downto 0); --se usa al traer un bloque nuevo a la MC (va cambiando de valor para traer todas las palabras)
signal dir_MC: std_logic_vector(3 downto 0); -- se usa para leer/escribir las datos almacenas en al MC. 
signal MC_Din, MC_Dout: std_logic_vector (31 downto 0);
signal MC_Tags_Dout: std_logic_vector(25 downto 0); 
signal rm, wm, wh: std_logic_vector(7 downto 0); 
signal inc_rm, inc_wm, inc_wh : std_logic;
signal mux_out : std_logic; -- Nueva señal para optativo2
signal palabraAddr : std_logic_vector (1 downto 0);-- Nueva señal para optativo2
signal reg_ADDR_ini_en : std_logic; -- para actualizar el reg con el set (nuevo optativo 2)
signal reg_ADDR_out : std_logic_vector (31 downto 0); -- salida del registro reg_ADDR
signal reg_set_out : std_logic_vector (1 downto 0); -- parte de reg_ADDR_out (por claridad)
signal reg_Din_ini_en : std_logic; -- para actualizar el reg con el set (nuevo optativo 2)
signal reg_Din_ini_out : std_logic_vector (31 downto 0); -- salida del registro reg_Din
signal clk_inv : std_logic; -- clk invertido para optativo 1
begin
 -------------------------------------------------------------------------------------------------- 
 -----MC_data: memoria RAM que almacena los 4 bloques de 4 datos que puede guardar la Cache
 -- dir palabra puede venir de la entrada (cuando se busca un dato solicitado por el Mips) o de la Unidad de control, UC, (cuando se está escribiendo un bloque nuevo 
 -------------------------------------------------------------------------------------------------- 
 dir_palabra <= ADDR(3 downto 2) when (mux_origen='0') else palabra_UC;
 ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --------------------------------------------------------- CAMBIO OPTATIVO 1: BUFFER DATOS Y ADDR  --------------------------------------------------------------------------
	----------------------------------- Registro de 32b -----------------------------------
	-- A ciclo cambiado (not clk) para que muestre los datos en el mismo ciclo en que se introducen:
 clk_inv <= not clk;
 reg_Din_ini: reg32 port map(	Din => Din, clk => clk_inv, reset => reset, load => reg_Din_ini_en, Dout => reg_Din_ini_out);
 
 
--------------------------------------------------------- CAMBIO OPTATIVO 2: ADELANTO ENVIO --------------------------------------------------------------------------------
	----------------------------------- Registro de 32b -----------------------------------
	reg_ADDR_ini: reg32 port map(	Din => ADDR, clk => clk_inv, reset => reset, load => reg_ADDR_ini_en, Dout => reg_ADDR_out);
	-- Añadimos un mux a la salida, que permita mandar a la CPU directamente el bus en funcion de una nueva señal mux_out originada en la UC_MC:
	reg_set_out <= reg_ADDR_out (5 downto 4); -- direccion del set del principio 
    dir_cjto <= ADDR(5 downto 4) when (mux_origen='0') else reg_set_out; -- Cambiado para elegir entre la direccion de cpu o el registro
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 dir_MC <= dir_cjto&dir_palabra; --para direccionar una dato hay que especificar el cjto y la palabra.
 -- la entrada de datos de la MC puede venir del Mips (acceso normal) o del bus (gestión de fallos)
 MC_Din <= Din when (mux_origen='0') else MC_bus_Din;
 memoria_cache_D: process (CLK)
    begin
        if (CLK'event and CLK = '1') then
            if (MC_WE = '1') then -- sólo se escribe si WE_MC_I vale 1
                MC_data(conv_integer(dir_MC)) <= MC_Din;
				-- report saca un mensaje en la consola del simulador.  Nos imforma sobre qué dato se ha escrito, dónde y cuándo
				report "Simulation time : " & time'IMAGE(now) & ".  Data written: " & integer'image(to_integer(unsigned(MC_Din))) & ", in dir_MC = " & integer'image(to_integer(unsigned(dir_MC)));
            end if;
        end if;
    end process;
	

	
-------------------------------------------------------------------------------------------------- 
-----MC_Tags: memoria RAM que almacena las 4 etiquetas
-------------------------------------------------------------------------------------------------- 
----------------------------------- Nuevo optativa 2 ----------------------------------------------------------------------
 -- Linea antigua: MC_Dout <= MC_data(conv_integer(dir_MC)) when (MC_RE='1') else "00000000000000000000000000000000"; --sólo se lee si RE_MC vale 1
	MC_Dout <= MC_data(conv_integer(dir_MC)) when (MC_RE='1' and mux_out='0') else MC_Bus_Din when mux_out='1' else "00000000000000000000000000000000"; --sólo se lee si RE_MC vale 1

---------------------------------------------------------------------------------------------------------------------------
-- NOTA CAMBIOS OPTATIVO 2:
-- A continuacion he cambiado todas las señales dir_cjto por reg_set_out, para que utilice la direccion del conjunto del principio
-- en caso de entrar en el estado "TerminarTransmision" de la parte optativa 2
---------------------------------------------------------------------------------------------------------------------------
memoria_cache_tags: process (CLK)
    begin
        if (CLK'event and CLK = '1') then
            if (MC_Tags_WE = '1') then -- sólo se escribe si MC_Tags_WE vale 1
                MC_Tags(conv_integer(reg_set_out)) <= ADDR(31 downto 6);
				-- report saca un mensaje en la consola del simulador. Nos imforma sobre qué etiqeta se ha escrito, dónde y cuándo
				report "Simulation time : " & time'IMAGE(now) & ".  Tag written: " & integer'image(to_integer(unsigned(ADDR(31 downto 6)))) & ", in dir_MC = " & integer'image(to_integer(unsigned(dir_cjto)));
            end if;
        end if;
    end process;
    MC_Tags_Dout <= MC_Tags(conv_integer(dir_cjto)) when (RE='1' or WE='1') else "00000000000000000000000000"; --sólo se lee si RE_MC vale 1
-------------------------------------------------------------------------------------------------- 
-- registro de validez. Al resetear los bits de validez se ponen a 0 así evitamos falsos positivos por basura en las memorias
-- en el bit de validez se escribe a la vez que en la memoria de etiquetas. Hay que poner a 1 el bit que toque y mantener los demás, para eso usamos una mascara generada por un decodificador
-------------------------------------------------------------------------------------------------- 
mask			<= 	"0001" when reg_set_out="00" else
						"0010" when reg_set_out="01" else
						"0100" when reg_set_out="10" else
						"1000" when reg_set_out="11" else
						"0000";
valid_bits_in <= valid_bits_out OR mask;
bits_validez: reg4 port map(	Din => valid_bits_in, clk => clk, reset => reset, load => MC_tags_WE, Dout => valid_bits_out);

-------------------------------------------------------------------------------------------------- 
valid_bit <= 			valid_bits_out(0) when dir_cjto="00" else
						valid_bits_out(1) when dir_cjto="01" else
						valid_bits_out(2) when dir_cjto="10" else
						valid_bits_out(3) when dir_cjto="11" else
						'0';
-------------------------------------------------------------------------------------------------- 
-- Señal de hit: se activa cuando la etiqueta coincide y el bit de valido es 1
hit <= '1' when ((MC_Tags_Dout= ADDR(31 downto 6)) AND (valid_bit='1'))else '0'; --comparador que compara el tag almacenado en MC con el de la dirección y si es el mismo y el bloque tiene el bit de válido activo devuelve un 1
--reg_set_ini <= ADDR(5 downto 4) when reg_ADDR_ini_en ='1';
-------------------------------------------------------------------------------------------------- 

------------------------------------- Nuevo ------------------------------------------------------
palabraAddr <= ADDR(3 downto 2); -- Nuevo optativo 2: la UC necesita tener la direccion de la palabra 
--------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------- 
-----MC_UC: unidad de control
-------------------------------------------------------------------------------------------------- 
Unidad_Control: UC_MC port map (	clk => clk, reset=> reset, RE => RE, WE => WE, hit => hit, bus_TRDY => bus_TRDY, 
									bus_DevSel => bus_DevSel, MC_RE => MC_RE, MC_WE => MC_WE, Replace_block => Replace_block, MC_bus_Rd_Wr => internal_MC_bus_Rd_Wr, 
									MC_tags_WE=> MC_tags_WE, palabra => palabra_UC, palabraAddr => palabraAddr, mux_origen => mux_origen, mux_out => mux_out, ready => ready, MC_send_addr=> MC_send_addr, 
									block_addr => block_addr, MC_send_data => MC_send_data, Frame => MC_Frame,reg_ADDR_ini_en=>reg_ADDR_ini_en,
									inc_rm => inc_rm, inc_wm => inc_wm, inc_wh => inc_wh );  
--------------------------------------------------------------------------------------------------
----------- Contadores de eventos
-------------------------------------------------------------------------------------------------- 
cont_rm: counter port map (clk => clk, reset => reset, count_enable => inc_rm , load=> '0', D_in => "00000000", count => rm);
cont_wm: counter port map (clk => clk, reset => reset, count_enable => inc_wm , load=> '0', D_in => "00000000", count => wm);
cont_wh: counter port map (clk => clk, reset => reset, count_enable => inc_wh , load=> '0', D_in => "00000000", count => wh);									
--------------------------------------------------------------------------------------------------
----------- Salidas para el bus
-------------------------------------------------------------------------------------------------- 
MC_bus_Rd_Wr <= internal_MC_bus_Rd_Wr;
--Si es escritura se manda la dirección de la palabra y si es un fallo de lectura la dirección del bloque que causó el fallo
MC_Bus_ADDR <= 	reg_ADDR_out(31 downto 2)&"00" when block_addr ='0' else 
				reg_ADDR_out(31 downto 4)&"0000"; 
--------------------------------------------------------------------------------------------------				
-- CAMBIO OP 1:
MC_Bus_data_out <= reg_Din_ini_out; -- se usa para mandar el dato a escribir
--------------------------------------------------------------------------------------------------
----------- Salidas para el Mips
-------------------------------------------------------------------------------------------------- 
Dout <= MC_Dout; -- se usa para mandar el dato al Mips


end Behavioral;
