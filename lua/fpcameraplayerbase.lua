function FPCameraPlayerBase:anim_start_execution(...)
	Print("FPCameraPlayerBase:anim_start_execution()")
--	managers.player:local_player():movement():change_state("standard")
end

function FPCameraPlayerBase:anim_stop_execution(...)
	Print("FPCameraPlayerBase:anim_stop_execution()")
	managers.player:local_player():movement():change_state("standard")
end