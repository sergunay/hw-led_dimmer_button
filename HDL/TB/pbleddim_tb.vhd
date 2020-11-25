--*****************************************************************************
-- Company			EPFL-LSM
-- Project Name		Medusa
--*****************************************************************************
-- Doxygen labels
--! @file 			pbleddim_tb.vhd
--! @brief 			a short description what can be found in the file
--! @details 		detailed description
--! @author 		Selman Ergünay
--! @date 			06.10.2020
--*****************************************************************************
-- Naming Conventions:
--   active low signals:                    "*_n"
--   clock signals:                         "clk", "clk_div#", "clk_#x"
--   reset signals:                         "rst", "rst_n"
--   generics:                              "C_* -all UPPERCASE"
--   state machine current/next state:      "*_cs" / "*_ns"
--   pipelined or register delay signals:   "*_d#"
--   counter signals:                       "*cnt*"
--	 data valid signals						"*_vld"
--   internal version of output port:       "*_i"
--   ports:                                 "- Names begin with Uppercase"
--   processes:                             "*_PROC"
--   component instantiations:              "<ENTITY_>I_<#|FUNC>"
--*****************************************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

entity pbleddim_tb is
end entity;

------------------------------------------------------------------------
architecture tb of pbleddim_tb is
------------------------------------------------------------------------
	component pbleddim
		generic(
			CNT_NBITS	: natural := 8);
		port(
			iClk		: in std_logic;
			iRst        : in std_logic;
			iPushButton	: in std_logic;
			oLed		: out std_logic);
	end component;
------------------------------------------------------------------------

	-- Simulation constants
	constant C_CLK_PER			: time 		:= 83.33 ns;

	constant C_CNT_NBITS		: natural 	:= 8;

	-- Simulation control signals
	signal sim_clk				: std_logic := '0';
	signal sim_rst				: std_logic := '0';
	signal sim_stop				: boolean 	:= FALSE;		-- stop simulation?
	signal sim_pushbutton		: std_logic := '0';

	signal phy_led				: std_logic := '0';

------------------------------------------------------------------------
begin
------------------------------------------------------------------------

	DUV: pbleddim
		generic map(
			CNT_NBITS	=> C_CNT_NBITS)
		port map(
			iClk		=> sim_clk,
			iRst 		=> sim_rst,
			iPushButton	=> sim_pushbutton,
			oLed		=> phy_led);

----------------------------------------------------------------------------
	--! @brief 100MHz system clock generation
	CLK_STIM : sim_clk 	<= not sim_clk after C_CLK_PER/2 when not sim_stop;
----------------------------------------------------------------------------

	INFO_PROC: process
           variable l : line;
        begin
           write (l, string'("Hello world!"));
           writeline (output, l);
           wait;
        end process;


	STIM_PROC: process

		procedure init is
		begin
			sim_rst 			<= '1';
			wait for 400 ns;
			sim_rst				<= '0';
		end procedure init;

		procedure press_pbutton is
		begin
			for i in 1 to 16 loop
				sim_pushbutton		<= '1';
				wait for 500 us;
				sim_pushbutton 		<= '0';
				wait for 500 us;
			end loop;
			sim_pushbutton 		<= '1';
		end procedure press_pbutton;

	begin
		init;
		wait for 5 ms;
		press_pbutton;
		wait for 100 ms;
		press_pbutton;
		wait for 100 ms;
		press_pbutton;
		wait for 100 ms;
		press_pbutton;
		wait for 100 ms;
		press_pbutton;
		wait for 100 ms;
		sim_stop 	<= True;
		wait;
	end process STIM_PROC;

----------------------------------------------------------------------------
end tb;
----------------------------------------------------------------------------
