function FPCameraPlayerBase:anim_execution_slap(...)

end
function FPCameraPlayerBase:anim_execution_punchthroat(...)

end
function FPCameraPlayerBase:anim_execution_grab(...)

end
function FPCameraPlayerBase:anim_execution_kill(...)
	local player = managers.player:local_player()
	local mov_ext = alive(player) and player:movement()
	local state = mov_ext and mov_ext:current_state()
	if state then 
		if alive(state._state_data.execution_unit) then
			--state._state_data.execution_unit:anim_data().ragdoll = true
		end
		mov_ext:change_state("standard")
	end
end

function FPCameraPlayerBase:anim_start_execution(...)
	Print("FPCameraPlayerBase:anim_start_execution()")
--	managers.player:local_player():movement():change_state("standard")
end

function FPCameraPlayerBase:anim_stop_execution(...)
	Print("FPCameraPlayerBase:anim_stop_execution()")
	managers.player:local_player():movement():change_state("standard")
end

--]]