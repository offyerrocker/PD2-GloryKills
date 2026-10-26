Hooks:PostHook(HuskPlayerMovement,"init","init_execution_spawn_melee_prop",function(self,unit)
	self._execution_anim_props = {}
	--self._custom_anim_effects = {}
end)

function HuskPlayerMovement:anim_execution_spawn_melee_prop(unit, attachment_point, called_prop_nickname)
	local animation_prop_align_obj = self._unit:get_object(Idstring(attachment_point))
			
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local third_unit_name = tweak_data.blackmarket.melee_weapons[melee_entry].third_unit
	
	GloryKills:Print ("anim_execution_spawn_melee_prop: equipped melee is", melee_entry, "unit is", third_unit_name )
	
	if animation_prop_align_obj and third_unit_name then
		self:_unspawn_execution_melee_prop(called_prop_nickname)
		local animation_prop = World:spawn_unit(Idstring(third_unit_name), animation_prop_align_obj:position(), animation_prop_align_obj:rotation())
		self._unit:link(animation_prop_align_obj:name(), animation_prop, animation_prop:orientation_object():name())
		self._execution_anim_props[called_prop_nickname] = animation_prop
	end
end

function HuskPlayerMovement:_unspawn_execution_melee_prop(called_prop_nickname)
	--log("_unspawn_execution_melee_prop called")
	if called_prop_nickname then
		local animation_prop = self._execution_anim_props[called_prop_nickname]
		self._execution_anim_props[called_prop_nickname] = nil
		if animation_prop and alive(animation_prop) then
			animation_prop:unlink()
			World:delete_unit(animation_prop)
			return true
		end
	end
end

function HuskPlayerMovement:anim_clbk_unspawn_execution_melee_prop(unit, called_prop_nickname)
	--log("anim_clbk_spawn_animation_prop called")
	self:_unspawn_execution_melee_prop(called_prop_nickname)
end

function HuskPlayerMovement:play_execution_sound(unit, sound_type, variation)
-- based on PlayerStandard:_play_melee_sound()
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	
	--log("Execution equipped sound callback, weapon is ", melee_entry, " sound id is ", sound_id, " variation is ", variation )

	local melee_tweak_data = tweak_data.blackmarket.melee_weapons[melee_entry]
	
	local post_event = melee_tweak_data.sounds and melee_tweak_data.sounds[sound_type]
	if not post_event then
		return
	end


	if type(post_event) == "table" then
		post_event = post_event[variation] or post_event[1]
	end

	self._unit:sound():play(post_event, nil, false)
end


-- custom functions from GloryKills, not vanilla
function HuskPlayerMovement:play_execution_effect(unit,...)
	GloryKills:Print("HuskPlayerMovement:play_execution_effect() ",unit,...)
	return GloryKills.callback_play_effect(unit,...)
end


function HuskPlayerMovement:play_execution_sound_melee(unit,event_type,...)
	GloryKills:Print("HuskPlayerMovement:play_execution_sound_melee() ",unit,event_type,...)
	return GloryKills.callback_play_sound_melee(unit,event_type,...)
end

function HuskPlayerMovement:play_execution_sound_gen(unit,event,...)
	GloryKills:Print("HuskPlayerMovement:play_execution_sound_gen() ",unit,event,...)
	return GloryKills.callback_play_sound_gen(unit,event,...)
end



-- these aren't being triggered from the anim, idk why
function HuskPlayerMovement:anim_execution_slap(...)

end
function HuskPlayerMovement:anim_execution_punch(...)

end
function HuskPlayerMovement:anim_execution_grab(...)

end
function HuskPlayerMovement:anim_execution_generic(s)
--	Print("Animation callback:",s)
end

function HuskPlayerMovement:anim_execution_kill(...)
end

function HuskPlayerMovement:anim_start_execution(...)
--	Print("HuskPlayerMovement:anim_start_execution()")
end

function HuskPlayerMovement:anim_stop_execution(...)
--	Print("HuskPlayerMovement:anim_stop_execution()")
	local player = managers.player:local_player()
	local mov_ext = alive(player) and player:movement()
	local state = mov_ext and mov_ext:current_state()
	if state then 
		if state.on_execution_complete then
			state:on_execution_complete()
		end
	end
end

