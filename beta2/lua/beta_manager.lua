function RegisterBetaServer()
	RunConsoleCommand( "sv_tags", "newadmin" )
end
hook.Add( "PlayerInitialSpawn", "SetBeta", RegisterBetaServer )