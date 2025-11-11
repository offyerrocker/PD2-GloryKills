-- these aren't currently used

function FPCameraPlayerBase:anim_execution_slap(...)

end
function FPCameraPlayerBase:anim_execution_punchthroat(...)

end
function FPCameraPlayerBase:anim_execution_grab(...)

end
function FPCameraPlayerBase:anim_execution_generic(s)
	GloryKills:Print("Animation callback:",s)
end
function FPCameraPlayerBase:anim_execution_kill(...)
	local player = managers.player:local_player()
	local mov_ext = alive(player) and player:movement()
	local state = mov_ext and mov_ext:current_state()
	if state then 
		mov_ext:change_state("standard")
	end
end

function FPCameraPlayerBase:anim_start_execution(...)
	GloryKills:Print("FPCameraPlayerBase:anim_start_execution()")
--	managers.player:local_player():movement():change_state("standard")
end

function FPCameraPlayerBase:anim_stop_execution(...)
	GloryKills:Print("FPCameraPlayerBase:anim_stop_execution()")
	managers.player:local_player():movement():change_state("standard")
end

--]]