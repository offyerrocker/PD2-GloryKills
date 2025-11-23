Hooks:PostHook(HuskPlayerMovement,"init","init_execution_spawn_melee_prop",function(self,unit)
	self._execution_anim_props = {}
	--self._custom_anim_effects = {}
end)

local axes = {"fireaxe","beardy"}
local knives = {"rambo","chef","fairbair","kabartanto","kabar","toothbrush","kampfmesser","gerber","becker","bayonet","x46","bowie","switchblade","scoutknife","pugio","shawn","ballistic","wing","grip"}
local machetes = nil --for machetes and small axes
local bats = nil --bats and shit like the ruler will be here
local batons = nil --batons and the morningstar will be here
local daggers = nil --stabby stab knives and things like syringe and kunai will be here, including fairbair and switchblade
local spears = nil --mainly for the flag and the pitchfork

local uniques = nil --briefcase, money bundle, roaming frothing madness of a chainsaw, sledgehammer, katana, great sword, sai, probably the axes should be here too later

function HuskPlayerMovement:anim_execution_spawn_melee_prop(unit, attachment_point, called_prop_nickname)	

	local animation_prop_align_obj = self._unit:get_object(Idstring(attachment_point))
			
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local unit_name = tweak_data.blackmarket.melee_weapons[melee_entry].third_unit
	
	log ("anim_execution_spawn_melee_prop: equipped melee is", melee_entry, "unit is", unit_name )
	
	for k,v in ipairs(axes) do 
		if v == melee_entry then
			if animation_prop_align_obj then
				self:_unspawn_execution_melee_prop(called_prop_nickname)
				local animation_prop = World:spawn_unit(Idstring(unit_name), animation_prop_align_obj:position(), animation_prop_align_obj:rotation())
				self._unit:link(animation_prop_align_obj:name(), animation_prop, animation_prop:orientation_object():name())
				self._execution_anim_props[called_prop_nickname] = animation_prop
			end
		end
	end
	
	for k,v in ipairs(knives) do 
		if v == melee_entry then
			if animation_prop_align_obj then
				self:_unspawn_execution_melee_prop(called_prop_nickname)
				local animation_prop = World:spawn_unit(Idstring(unit_name), animation_prop_align_obj:position(), animation_prop_align_obj:rotation())
				self._unit:link(animation_prop_align_obj:name(), animation_prop, animation_prop:orientation_object():name())
				self._execution_anim_props[called_prop_nickname] = animation_prop
			end
		end
	end
end

function HuskPlayerMovement:_unspawn_execution_melee_prop(called_prop_nickname)
	--log("_unspawn_execution_melee_prop called")
	if called_prop_nickname then
		local animation_prop = self._execution_anim_props[called_prop_nickname]
		if animation_prop and alive(animation_prop) then
			animation_prop:unlink()
			World:delete_unit(animation_prop)
		end
		self._execution_anim_props[called_prop_nickname] = nil
	end
end

function HuskPlayerMovement:anim_clbk_unspawn_execution_melee_prop(unit, called_prop_nickname)
	--log("anim_clbk_spawn_animation_prop called")
	self:_unspawn_execution_melee_prop(called_prop_nickname)
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

function HuskPlayerMovement:play_execution_sound_equipped(unit, sound_id, variation)

	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	
	log("Execution equipped sound callback, weapon is ", melee_entry, " sound id is ", sound_id, " variation is ", variation )

	local melee_tweak_data = tweak_data.blackmarket.melee_weapons[melee_entry]
	
	if not tweak_data.sounds or not tweak_data.sounds[sound_id] then
		return
	end

	local post_event = tweak_data.sounds[sound_id]

	if type(post_event) == "table" then
		post_event = post_event[variation] or post_event[1]
	end

	self._unit:sound():play(post_event, nil, false)
end


function HuskPlayerMovement:play_execution_sound(unit, sound_id, variation)

	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	
	local melee_entry = "weapon"
	
	log("Execution sound callback, weapon is ", melee_entry, " sound id is ", sound_id, " variation is ", variation )

	
	local melee_tweak_data = tweak_data.blackmarket.melee_weapons[melee_entry]

	if not tweak_data.sounds or not tweak_data.sounds[sound_id] then
		return
	end

	local post_event = tweak_data.sounds[sound_id]

	if type(post_event) == "table" then
		post_event = post_event[variation] or post_event[1]
	end

	self._unit:sound():play(post_event, nil, false)
end
--]]