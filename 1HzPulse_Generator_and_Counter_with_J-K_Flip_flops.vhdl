-----------------------50 MHZ'L�K SAYA�TAN 1 SAN�YEL�K (1HZ) DARBE �RETEC� ELDE ED�M�,PROJEYE ENTEGE ED�LECEK KOMPONENT ------------------------------
-----------------------11253001 - TAYFUN ADAKO�LU--------
library IEEE;  
use IEEE.STD_LOGIC_1164.ALL;  -- STD_LOGIC s�n�flar� i�in gerekli
entity saat is
	port (clk1 : in std_logic;
       	       clk : out std_logic
     	);
end saat;

architecture Mimari of saat is

signal count : integer :=1;
signal clk : std_logic :='0';

--Burada 50 Mhz darbe �reteci ile 1 Hz(1sn)'lik sayan bir darbe �reteci elde edilmi�tir. Frekans b�l�mlemesi..
--50Mhz'lik bir darbe �reteci i�in her 25 000 000 darbede bir sayac� 'toggle'lamal�y�z. Yani terslemeliyiz, a <= not a gibi


process(clk1) 
 begin
  if(clk1'event and clk1='1') then
   count <=count+1;
   if(count = 25000000) then
    clk <= not clk; -- sayac�m�z� tersliyoruz (toggle'luyoruz)
    count <=1;
   end if;
  end if;
end process;

end Mimari

---------------------JK FL�P FLOPLAR �LE 4 B�T'L�K SAYA� GER�EKLEN�M� - PROJEN�N KEND�S� ------------------------------------------------------------------------------

library IEEE;  
 use IEEE.STD_LOGIC_1164.ALL;  -- STD_LOGIC s�n�flar� i�in gerekli
 use IEEE.STD_LOGIC_ARITH.ALL;  -- STD_LOGIC_VECTOR �zerinde say�sal i�lem yapabilmemiz i�in gerekli alttaki alt k�t�phane(IEEE.STD_LOGIC_UNSIGNED) ile birlikte kullan�l�r ( unsigned(A) + unsigned(B) gibi)
 use IEEE.STD_LOGIC_UNSIGNED.ALL;  -- STD_LOGIC_VECTOR �zerinde say�sal i�lem yapabilmemiz i�in gerekli 

--11253001 - TAYFUN ADAKO�LU

-- JK flip-flop bilgisayar m�hendisli�inde yayg�n oldu�undan tercih edilmi�tir. 
-- JK flip flop J ve K giri�leri saya� i�lemlerinde y�ksek voltaj (+5v) = 1 olarak al�n�r ki ��k��lar saat darbesi olarak kullan�labilsin.
-- Asenkron saya�ta sadece ilk ( en sol) flip flop'a saat darbesi verilir geri kalan flip floplar�n herbiri(burada 4 bit saya� oldu�undan geri kalan 3 tanesi) bir �nceki flip flop'un ��k���ndan beslenir. Senkron saya�ta ise her flip flop'a tek bir ortak saat darbesi �reteci ba�lan�r.
 
entity jkc is  
 Port ( clock : in std_logic;  --buraya 50 mhz clock ba�lay�n.
        reset : in std_logic;  
        count : out std_logic_vector(3 downto 0);
	clock1Saniye : in std_logic  -- buradan bir component vas�tas� ile 50 mhz to 1 hz(sn) d�n���m� yap�lacakt�r
    );  
 end jkc;
  
 architecture mimari of jkc is  

 COMPONENT saat -- Saniyelik darbe �reticimizi projemize entegre ettik
	port (clk1 : in std_logic;
       	       clk : out std_logic
     	);
 END COMPONENT;

 COMPONENT jkff  -- jk flip flop entity'mizi projemize ald�k
   PORT(  
     clock : in std_logic;  
     reset : in std_logic;  
     j     : in std_logic;  
     k     : in std_logic;  
     q     : out std_logic      
     );  
  END COMPONENT; 
  
 signal temp : std_logic_vector(3 downto 0) := "0000";  

 begin  

 dSaat : saat   
     port map (  -- burada bu projemizdeki 50Mhz'lik saat darbesi �retecini 50 mhz to 1 hz d�n��t�r�c� entity'mize g�nderiyoruz.
       clk1  => clock,  -- bu projedeki saatimiz clock de�i�kenidir, clk1 proje'ye entegre edilen saat entity'si giri�idir.
       clk  => clock1Saniye  
      
     ); 

 d0 : jkff  
     port map (  -- burada 1. jk flip flopumuza ( en sol-saat ba�land�) bu projemizdeki sinyallerimizi harital�yoruz
       reset  => reset,  
       clock  => clock1Saniye,  -- saniyelik saat darbesi �reticimizi ba�lad�k.
       j      => '1',  -- +5V ba�land�
       k      => '1',  -- +5V ba�land�     
       q      => temp(3)  
     );  

 d1 : jkff  
     port map (  ---- burada 2. jk flip flopumuza bu projemizdeki sinyallerimizi harital�yoruz
       reset  => reset,  
       clock  => temp(3),  
       j      => '1',  -- +5V ba�land�
       k      => '1',  -- +5V ba�land�    
       q      => temp(2)  
     );  

 d2 : jkff  
     port map (  -- -- burada 3. jk flip flopumuza bu projemizdeki sinyallerimizi harital�yoruz
       reset  => reset,  
       clock  => temp(2),  
       j      => '1',  -- +5V ba�land�
       k      => '1',  -- +5V ba�land�
       q      => temp(1)  
     );  

 d3 : jkff  
     port map (  ---- burada 4. jk flip flopumuza bu projemizdeki sinyallerimizi harital�yoruz
       reset  => reset,  
       clock  => temp(1),  
       j      => '1',  -- +5V ba�land�
       k      => '1',  -- +5V ba�land�
       q      => temp(0)  
     );  

 count(3) <= temp(0);  
 count(2) <= temp(1);  
 count(1) <= temp(2);  
 count(0) <= temp(3);      
 end mimari;  




-------------------JK FL�P FLOP ENT�TY'S�, PROJEYE ENTEGE ED�LECEK KOMPONENT -------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity jkff is
   port( j,k: in std_logic;
         reset: in std_logic;
         Clock_enable: in std_logic := '1';
         clock: in std_logic;
         q: out std_logic);
end jkff;

architecture Mimari of jkff is
   signal temp: std_logic;
begin
   process (clock) 
   begin
      if rising_edge(clock) then                 
         if reset='1' then   
            temp <= '0';
         elsif Clock_enable ='1' then
            if (j='0' and k='0') then
               temp <= temp;
         elsif j='0' and k='1') then
               temp <= '0';
         elsif (j='1' and k='0') then
               temp <= '1';
         elsif (j='1' and k='1') then
               temp <= not (temp);
         end if;
         end if;
      end if;
   end process;
   q <= temp;
end Mimari;