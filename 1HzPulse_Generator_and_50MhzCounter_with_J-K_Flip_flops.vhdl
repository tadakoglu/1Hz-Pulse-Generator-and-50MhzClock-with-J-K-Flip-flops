-----------------------50 MHZ'LÝK SAYAÇTAN 1 SANÝYELÝK (1HZ) DARBE ÜRETECÝ ELDE EDÝMÝ,PROJEYE ENTEGE EDÝLECEK KOMPONENT ------------------------------
-----------------------11253001 - TAYFUN ADAKOÐLU--------
library IEEE;  
use IEEE.STD_LOGIC_1164.ALL;  -- STD_LOGIC sýnýflarý için gerekli
entity saat is
	port (clk1 : in std_logic;
       	       clk : out std_logic
     	);
end saat;

architecture Mimari of saat is

signal count : integer :=1;
signal clk : std_logic :='0';

--Burada 50 Mhz darbe üreteci ile 1 Hz(1sn)'lik sayan bir darbe üreteci elde edilmiþtir. Frekans bölümlemesi..
--50Mhz'lik bir darbe üreteci için her 25 000 000 darbede bir sayacý 'toggle'lamalýyýz. Yani terslemeliyiz, a <= not a gibi


process(clk1) 
 begin
  if(clk1'event and clk1='1') then
   count <=count+1;
   if(count = 25000000) then
    clk <= not clk; -- sayacýmýzý tersliyoruz (toggle'luyoruz)
    count <=1;
   end if;
  end if;
end process;

end Mimari

---------------------JK FLÝP FLOPLAR ÝLE 4 BÝT'LÝK SAYAÇ GERÇEKLENÝMÝ - PROJENÝN KENDÝSÝ ------------------------------------------------------------------------------

library IEEE;  
 use IEEE.STD_LOGIC_1164.ALL;  -- STD_LOGIC sýnýflarý için gerekli
 use IEEE.STD_LOGIC_ARITH.ALL;  -- STD_LOGIC_VECTOR üzerinde sayýsal iþlem yapabilmemiz için gerekli alttaki alt kütüphane(IEEE.STD_LOGIC_UNSIGNED) ile birlikte kullanýlýr ( unsigned(A) + unsigned(B) gibi)
 use IEEE.STD_LOGIC_UNSIGNED.ALL;  -- STD_LOGIC_VECTOR üzerinde sayýsal iþlem yapabilmemiz için gerekli 

--11253001 - TAYFUN ADAKOÐLU

-- JK flip-flop bilgisayar mühendisliðinde yaygýn olduðundan tercih edilmiþtir. 
-- JK flip flop J ve K giriþleri sayaç iþlemlerinde yüksek voltaj (+5v) = 1 olarak alýnýr ki çýkýþlar saat darbesi olarak kullanýlabilsin.
-- Asenkron sayaçta sadece ilk ( en sol) flip flop'a saat darbesi verilir geri kalan flip floplarýn herbiri(burada 4 bit sayaç olduðundan geri kalan 3 tanesi) bir önceki flip flop'un çýkýþýndan beslenir. Senkron sayaçta ise her flip flop'a tek bir ortak saat darbesi üreteci baðlanýr.
 
entity jkc is  
 Port ( clock : in std_logic;  --buraya 50 mhz clock baðlayýn.
        reset : in std_logic;  
        count : out std_logic_vector(3 downto 0);
	clock1Saniye : in std_logic  -- buradan bir component vasýtasý ile 50 mhz to 1 hz(sn) dönüþümü yapýlacaktýr
    );  
 end jkc;
  
 architecture mimari of jkc is  

 COMPONENT saat -- Saniyelik darbe üreticimizi projemize entegre ettik
	port (clk1 : in std_logic;
       	       clk : out std_logic
     	);
 END COMPONENT;

 COMPONENT jkff  -- jk flip flop entity'mizi projemize aldýk
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
     port map (  -- burada bu projemizdeki 50Mhz'lik saat darbesi üretecini 50 mhz to 1 hz dönüþtürücü entity'mize gönderiyoruz.
       clk1  => clock,  -- bu projedeki saatimiz clock deðiþkenidir, clk1 proje'ye entegre edilen saat entity'si giriþidir.
       clk  => clock1Saniye  
      
     ); 

 d0 : jkff  
     port map (  -- burada 1. jk flip flopumuza ( en sol-saat baðlandý) bu projemizdeki sinyallerimizi haritalýyoruz
       reset  => reset,  
       clock  => clock1Saniye,  -- saniyelik saat darbesi üreticimizi baðladýk.
       j      => '1',  -- +5V baðlandý
       k      => '1',  -- +5V baðlandý     
       q      => temp(3)  
     );  

 d1 : jkff  
     port map (  ---- burada 2. jk flip flopumuza bu projemizdeki sinyallerimizi haritalýyoruz
       reset  => reset,  
       clock  => temp(3),  
       j      => '1',  -- +5V baðlandý
       k      => '1',  -- +5V baðlandý    
       q      => temp(2)  
     );  

 d2 : jkff  
     port map (  -- -- burada 3. jk flip flopumuza bu projemizdeki sinyallerimizi haritalýyoruz
       reset  => reset,  
       clock  => temp(2),  
       j      => '1',  -- +5V baðlandý
       k      => '1',  -- +5V baðlandý
       q      => temp(1)  
     );  

 d3 : jkff  
     port map (  ---- burada 4. jk flip flopumuza bu projemizdeki sinyallerimizi haritalýyoruz
       reset  => reset,  
       clock  => temp(1),  
       j      => '1',  -- +5V baðlandý
       k      => '1',  -- +5V baðlandý
       q      => temp(0)  
     );  

 count(3) <= temp(0);  
 count(2) <= temp(1);  
 count(1) <= temp(2);  
 count(0) <= temp(3);      
 end mimari;  




-------------------JK FLÝP FLOP ENTÝTY'SÝ, PROJEYE ENTEGE EDÝLECEK KOMPONENT -------------------------

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
