----------------------------------------------------------------------------
--! @file 			pbleddim.vhd
--! @brief 			a short description what can be found in the file
--! @details 		detailed description
--! @author 		Selman Ergunay
--! @date 			07.10.2020
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
----------------------------------------------------------------------------
entity pbleddim is
	generic(
		CNT_NBITS	: natural := 8);
	port(
		iClk		: in std_logic;
		iRst        : in std_logic;
		iPushButton	: in std_logic;
		oLed		: out std_logic);

end entity pbleddim;

architecture rtl of pbleddim is

	constant C_TICK_LIMIT		: integer := 120;
	constant C_DEB_CNT_LIMIT	: integer := 2000;
	constant C_PWM_CNT_LIMIT    : integer := 100;

	signal pb_reg     : std_logic := '0';
	signal pb_reg_d   : std_logic := '0';
	signal pb_rising  : std_logic := '0';
	signal pb_pressed : std_logic := '0';
	signal deb_cnt_en : std_logic := '0';
	signal tick_10us  : std_logic := '0';
	signal pwm_out    : std_logic := '0';
	signal tick_cnt   : unsigned(7 downto 0) := (others=>'0');
	signal deb_cnt    : unsigned(10 downto 0) := (others=>'0');
	signal pwm_cnt    : unsigned(6 downto 0) := (others=>'0');
	signal pwm_active : unsigned(6 downto 0) := (others=>'0');
----------------------------------------------------------------------------
begin

	--! Counts sys clock (12 MHz) limit at 120
	TICK_10us_CNT_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1' or tick_cnt = C_TICK_LIMIT-1 then
				 tick_cnt <= (others=>'0');
			else
				 tick_cnt <= tick_cnt + 1;
			end if;
		end if;
	end process TICK_10us_CNT_PROC;

	-- Creates tick at each 10us
	tick_10us <= '1' when tick_cnt = C_TICK_LIMIT-1 else
				 '0';

	--! Push button input is registered
	PUSHBUTTON_INREG_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1'then
				pb_reg   <= '0';
				pb_reg_d <= '0';
			else
				pb_reg   <= iPushButton;
				pb_reg_d <= pb_reg;
			end if;
		end if;
	end process PUSHBUTTON_INREG_PROC;

	-- Tick for rising edge of pushbutton
	pb_rising <= pb_reg and not pb_reg_d;

	--! Counter enable reg, active when pushbutton in rising.
	DEB_CNT_EN_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1' or deb_cnt = C_DEB_CNT_LIMIT-1 then
				deb_cnt_en <= '0';
			elsif pb_rising = '1' then
				deb_cnt_en <= '1';
			end if;
		end if;
	end process DEB_CNT_EN_PROC;

	--! Counter for debouncing, counts with 10us tick,  limit at 2000 =
	--! stops at 20 ms
	DEBOUNCER_CNT_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1' or deb_cnt = C_DEB_CNT_LIMIT-1 then
				deb_cnt <= (others=>'0');
			elsif deb_cnt_en = '1' and tick_10us = '1' then
				deb_cnt <= deb_cnt + 1;
			end if;
		end if;
	end process DEBOUNCER_CNT_PROC;

	--! After 20 ms, if pushbutton input is still H, then pb is pressed.
	pb_pressed <= '1' when deb_cnt = C_DEB_CNT_LIMIT-1 and pb_reg = '1' else
				  '0';

	--! For each press, increase pwm_active number to increase the brightness.
	PWM_ACTIVE_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1' or pwm_active > 100 then
				pwm_active <= (others=>'0');
			elsif pb_pressed = '1' then
				pwm_active <= pwm_active + 25;
			end if;
		end if;
	end process PWM_ACTIVE_PROC;

	--! PWM counter counts with 10 us tick and until 100.
	--! Thus, pwm_active represents brightness percentage.
	PWM_CNT_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1' or pwm_cnt = C_PWM_CNT_LIMIT-1 then
				pwm_cnt <= (others=>'0');
			elsif tick_10us = '1' then
				pwm_cnt <= pwm_cnt + 1;
			end if;
		end if;
	end process PWM_CNT_PROC;

	pwm_out <= '1' when pwm_cnt < pwm_active else
			   '0';

	--! Output buffer for oLed, connected to pwm_out
	OLED_OBUF_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1'then
				oLed <= '0';
			else
				oLed <= pwm_out;
			end if;
		end if;
	end process OLED_OBUF_PROC;

----------------------------------------------------------------------------
end architecture rtl;
----------------------------------------------------------------------------
