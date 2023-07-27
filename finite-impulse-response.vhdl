library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity filter256 is port(
  clock : in std_logic;
  datain : in std_logic_vector(23 downto 0);
  dataout : out std_logic_vector(23 downto 0));
end filter256;

architecture Behavioral of filter256 is
  signal i : integer := 0;
  type statelist is(filters, shift, waits);
  signal state : statelist := filters;
  type taplist is array(255 downto 0) of signed(23 downto 0);
  signal tap : taplist := (others => (others => '0'));
  signal filter : signed(43 downto 0) := (others => '0');
  type koeflist is array(255 downto 0) of signed(19 downto 0);
  signalkoef : koeflist:=(
    "00000000000000000000”,”00000000000000000000”,”00000000000000000000”,”11111111111111111111”,”11111111111111111111”,”111
    11111111111111110”,”11111111111111111111”,”00000000000000000000”,”00000000000000000001”,”00000000000000000100”,”000000
    00000000001000”,”00000000000000001110”,”00000000000000010101”,”00000000000000011111”,”00000000000000101010”,”000000000
    00000110111”,”00000000000001000111”,”00000000000001011000”,”00000000000001101100”,”00000000000010000010”,”000000000000
    10011010”,”00000000000010110011”,”00000000000011001110”,”00000000000011101010”,”00000000000100001000”,”000000000001001
    00110”,”00000000000101000100”,”00000000000101100010”,”00000000000110000000”,”00000000000110011100”,”000000000001101101
    11”,”00000000000111001111”,”00000000000111100101”,”00000000000111110111”,”00000000001000000100”,”00000000001000001101”,
    ”00000000001000010001”,”00000000001000001110”,”00000000001000000101”,”00000000000111110100”,”00000000000111011011”,”000
    00000000110111010”,”00000000000110010001”,”00000000000101011110”,”00000000000100100001”,”00000000000011011011”,”000000
    00000010001011”,”00000000000000110000”,”11111111111111001101”,”11111111111101011111”,”11111111111011100111”,”111111111
    11001100110”,”11111111110111011100”,”11111111110101001010”,”11111111110010110000”,”11111111110000010000”,”111111111011
    01101010”,”11111111101011000000”,”11111111101000010010”,”11111111100101100001”,”11111111100010110001”,”111111111000000
    00001”,”11111111011101010100”,”11111111011010101011”,”11111111011000001000”,”11111111010101101101”,”111111110100110111
    00”,”11111111010001010110”,”11111111001111011111”,”11111111001101111000”,”11111111001100100011”,”11111111001011100010”,
    ”11111111001010110111”,”11111111001010100101”,”11111111001010101100”,”11111111001011010000”,”11111111001100010001”,”111
    11111001101110010”,”11111111001111110011”,”11111111010010010111”,”11111111010101011111”,”11111111011001001100”,”111111
    11011101011111”,”11111111100010011000”,”11111111100111111000”,”11111111101110000000”,”11111111110100101111”,”111111111
    11100000110”,”00000000000100000011”,”00000000001100101000”,”00000000010101110011”,”00000000011111100011”,”000000001010
    01110110”,”00000000110100101100”,”00000001000000000001”,”00000001001011110101”,”00000001011000000101”,”000000011001001
    01111”,”00000001110001110000”,”00000001111111000110”,”00000010001100101100”,”00000010011010100001”,”000000101010001000
    01”,”00000010110110100111”,”00000011000100110010”,”00000011010010111101”,”00000011100001000100”,”00000011101111000100”,
    ”00000011111100111001”,”00000100001010011110”,”00000100010111110001”,”00000100100100101101”,”00000100110001001111”,”000
    00100111101010011”,”00000101001000110101”,”00000101010011110010”,”00000101011110000111”,”00000101100111110001”,”000001
    01110000101100”,”00000101111000110111”,”00000110000000001110”,”00000110000110101111”,”00000110001100011000”,”000001100
    10001001000”,”00000110010100111101”,”00000110010111110110”,”00000110011001110001”,”00000110011010101111”,”000001100110
    10101111”,”00000110011001110001”,”00000110010111110110”,”00000110010100111101”,”00000110010001001000”,”000001100011000
    11000”,”00000110000110101111”,”00000110000000001110”,”00000101111000110111”,”00000101110000101100”,”000001011001111100
    01”,”00000101011110000111”,”00000101010011110010”,”00000101001000110101”,”00000100111101010011”,”00000100110001001111”,
    ”00000100100100101101”,”00000100010111110001”,”00000100001010011110”,”00000011111100111001”,”00000011101111000100”,”000
    00011100001000100”,”00000011010010111101”,”00000011000100110010”,”00000010110110100111”,”00000010101000100001”,”000000
    10011010100001”,”00000010001100101100”,”00000001111111000110”,”00000001110001110000”,”00000001100100101111”,”000000010
    11000000101”,”00000001001011110101”,”00000001000000000001”,”00000000110100101100”,”00000000101001110110”,”000000000111
    11100011”,”00000000010101110011”,”00000000001100101000”,”00000000000100000011”,”11111111111100000110”,”111111111101001
    01111”,”11111111101110000000”,”11111111100111111000”,”11111111100010011000”,”11111111011101011111”,”111111110110010011
    00”,”11111111010101011111”,”11111111010010010111”,”11111111001111110011”,”11111111001101110010”,”11111111001100010001”,
    ”11111111001011010000”,”11111111001010101100”,”11111111001010100101”,”11111111001010110111”,”11111111001011100010”,”111
    11111001100100011”,”11111111001101111000”,”11111111001111011111”,”11111111010001010110”,”11111111010011011100”,”111111
    11010101101101”,”11111111011000001000”,”11111111011010101011”,”11111111011101010100”,”11111111100000000001”,”111111111
    00010110001”,”11111111100101100001”,”11111111101000010010”,”11111111101011000000”,”11111111101101101010”,”111111111100
    00010000”,”11111111110010110000”,”11111111110101001010”,”11111111110111011100”,”11111111111001100110”,”111111111110111
    00111”,”11111111111101011111”,”11111111111111001101”,”00000000000000110000”,”00000000000010001011”,”000000000000110110
    11”,”00000000000100100001”,”00000000000101011110”,”00000000000110010001”,”00000000000110111010”,”00000000000111011011”,
    ”00000000000111110100”,”00000000001000000101”,”00000000001000001110”,”00000000001000010001”,”00000000001000001101”,”000
    00000001000000100”,”00000000000111110111”,”00000000000111100101”,”00000000000111001111”,”00000000000110110111”,”000000
    00000110011100”,”00000000000110000000”,”00000000000101100010”,”00000000000101000100”,”00000000000100100110”,”000000000
    00100001000”,”00000000000011101010”,”00000000000011001110”,”00000000000010110011”,”00000000000010011010”,”000000000000
    10000010”,”00000000000001101100”,”00000000000001011000”,”00000000000001000111”,”00000000000000110111”,”000000000000001
    01010”,”00000000000000011111”,”00000000000000010101”,”00000000000000001110”,”00000000000000001000”,”000000000000000001
    00”,”00000000000000000001”,”00000000000000000000”,”11111111111111111111”,”11111111111111111110”,”11111111111111111111”,
    ”11111111111111111111”,”00000000000000000000”,”00000000000000000000”,”0000000000000000000};
  begin
    proseskoefisien:process(i, clock, state, koef)
    begin
      if rising_edge(clock) then
        case state is
        when filters => 
          if i < 256 then
            if i = 0 then
              i <= i + 1;
              filter <= koef(i) * tap(i);
            elsif i = 255 then
              state <= shift;
              filter <= filter + koef(i) * tap(i);
            else
              i <= i + 1;
              filter <= filter + koef(i) * tap(i);
            end if;
          end if;
        when shift => 
          if i > 0 or i = 0 then
            if i = 0 then
              state <= waits;
              tap(i) <= signed(datain);
              dataout <= std_logic_vector(filter(43 downto 20));
            else
              tap(i) <= tap(i - 1);
              i <= i - 1;
            end if;
          end if;
        when waits =>
          if i < 488 then
            if i = 487 then
              i <= 0;
              state <= filters;
            else
              i <= i + 1;
            end if;
          end if;
        when others => state <= filters;
      end case;
    end if;
  end process;
end Behavioral;
