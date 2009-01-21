function RegisterBetaServer()
	RunConsoleCommand( "sv_tags", "newadmin" )
end
timer.Simple( 1, RegisterBetaServer )