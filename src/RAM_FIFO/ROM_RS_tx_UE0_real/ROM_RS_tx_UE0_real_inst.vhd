	component ROM_RS_tx_UE0_real is
		port (
			address : in  std_logic_vector(10 downto 0) := (others => 'X'); -- address
			clock   : in  std_logic                     := 'X';             -- clk
			q       : out std_logic_vector(17 downto 0)                     -- dataout
		);
	end component ROM_RS_tx_UE0_real;

	u0 : component ROM_RS_tx_UE0_real
		port map (
			address => CONNECTED_TO_address, --  rom_input.address
			clock   => CONNECTED_TO_clock,   --           .clk
			q       => CONNECTED_TO_q        -- rom_output.dataout
		);

