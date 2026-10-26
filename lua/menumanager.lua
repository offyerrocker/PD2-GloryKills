GloryKills = {
	
	fp_unit = nil, -- the fp unit
	unit = nil, -- the 3p unit
	head_obj = nil, -- object
	delayed_events = {},
	_character_visual_state = {}
}
GloryKills.HUSK_NAMES = {
	wild = "units/pd2_dlc_wild/characters/npc_criminals_wild_1/player_criminal_wild_husk",
	joy = "units/pd2_dlc_joy/characters/npc_criminals_joy_1/player_criminal_joy_husk"
}
GloryKills.ALLOWED_PLAYER_STATES = {
	standard = true,
	carry = true,
	execution = false, -- custom obviously
	
	empty = false,
	mask_off = false,
	bleed_out = false,
	fatal = false,
	arrested = false,
	tased = false,
	incapacitated = false,
	clean = false,
	civilian = false,
	bipod = false,
	driving = false,
	jerry2 = false,
	jerry1 = false,
	player_turret = false
}
GloryKills._execution_types_by_melee = { --lookup table for the execution variant, by melee id
	fireaxe = "axe",
	beardy = "axe",
	
	rambo = "knife",
	chef = "knife",
	fairbair = "knife",
	kabartanto = "knife",
	kabar = "knife",
	toothbrush = "knife",
	kampfmesser = "knife",
	gerber = "knife",
	becker = "knife",
	bayonet = "knife",
	x46 = "knife",
	bowie = "knife",
	switchblade = "knife",
	scoutknife = "knife",
	pugio = "knife",
	shawn = "knife",
	ballistic = "knife",
	wing = "knife",
	grip = "knife",
	
	cleaver = "hatchet",
	meat_cleaver = "hatchet",
	bullseye = "hatchet",
	oxide = "hatchet",
	scalper = "hatchet"
	
}

GloryKills._execution_anim_conditions = { -- vars used for both enemy death and player execution
	axe = {
		front = {
			"front_axe_var1"
		},
		rear = {
			"rear_axe_var1"
		}
	},
	hatchet = {
		front = {
			"front_hatchet_var1"
		},
		rear = {
			"rear_hatchet_var1"
		}
	},
	knife = {
		front = {
			"front_knife_var1"
		},
		rear = {
			"rear_knife_var1"
		}
	},
	machete = {
		front = {
--			"front_hand_var1",
		},
		rear = {
--			"rear_hand_var1"
		}
	},
	bats = { -- inconsistent plural case, i know. it's just to distinguish "bat" from "baton" and make it more searchable
		front = {},
		rear = {}
	},
	baton = {
		front = {},
		rear = {}
	},
	daggers = {
		front = {},
		rear = {}
	},
	spears = {
		front = {},
		rear = {}
	},
	uniques = {
		front = {},
		rear = {}
	}
}

GloryKills.HIDDEN_POSITION = Vector3(0,0,-10000)

function GloryKills:get_execution_variant(params)
	local variant = params.variant
	local from_behind = params.from_behind
	local conditions = self._execution_anim_conditions[variant]
	if conditions then
		if from_behind and #conditions.rear > 0 then
			return conditions.rear[math.random(#conditions.rear)]
		else
			-- assume that front is the "default" (if from_behind is false or not specified) and that there are always front anims defined
			return conditions.front[math.random(#conditions.front)]
		end
	end
	
	-- ruh roh rhaggy! fallback to defaults
	if from_behind then
		return "rear_hand_var1"
	else
		return "front_hand_var1"
	end
end

--[[ playbonk's original notes on melee types
local axes = {"fireaxe","beardy"}
local knives = {"rambo","chef","fairbair","kabartanto","kabar","toothbrush","kampfmesser","gerber","becker","bayonet","x46","bowie","switchblade","scoutknife","pugio","shawn","ballistic","wing","grip"}
local machetes = nil --for machetes and small axes
local bats = nil --bats and shit like the ruler will be here
local batons = nil --batons and the morningstar will be here
local daggers = nil --stabby stab knives and things like syringe and kunai will be here, including fairbair and switchblade
local spears = nil --mainly for the flag and the pitchfork

local uniques = nil --briefcase, money bundle, roaming frothing madness of a chainsaw, sledgehammer, katana, great sword, sai, probably the axes should be here too later

--]]

function GloryKills:get_execution_type_by_melee(melee_id)
	return self._execution_types_by_melee[melee_id]
end

-- copied this from third person mod. thanks hoppip
function GloryKills:spawn_third_unit(unit,character_name,visual_seed)

	local SETTING_IMMERSIVE_FIRST_PERSON = true
	local SETTING_CUSTOM_WEAPONS = false
	local SETTING_START_IN_THIRD_PERSON = false
	
	local unit_ids = Idstring("unit")
	
	
	local player = unit or managers.player:local_player()
	if not player then
		return
	end
	local player_peer = player:network():peer()
	local player_movement = player:movement()
	local pos = player_movement:m_pos()
	local rot = player_movement:m_head_rot()
	local char_id = player_peer:character_id() -- returns "locked" in some cases? not sure why, so this will be the fallback
	
	--[[
	-- get ai name for this character
	local char_name = managers.criminals:character_name_by_peer_id(player_peer:id())
	for _,data in pairs(tweak_data.criminals.characters) do 
		if data.name == CriminalsManager.convert_new_to_old_character_workname(char_name) then
			char_id = data.static_data.ai_character_id
			break
		end
	end
	local unit_name = self.HUSK_NAMES[char_id] or tweak_data.blackmarket.characters[char_id].npc_unit .. "_husk"
	--]]
	
	-- get the 3p unit
	local unit_name = self.HUSK_NAMES[char_id] or tweak_data.blackmarket.characters[char_id].npc_unit:gsub("(.+)/npc_", "%1/player_") .. "_husk"
	local unit_name_ids = Idstring(unit_name)

	if not DB:has(unit_ids, unit_name_ids) then
		self.fp_unit = nil
		self.unit = nil
		return
	end

	self.fp_unit = player
	self.unit = alive(self.unit) and self.unit or World:spawn_unit(unit_name_ids, GloryKills.HIDDEN_POSITION, rot)
	self.head_obj = self.unit:get_object(Idstring("Head"))
	Network:detach_unit(self.unit)

	-- The third person unit should be destroyed whenever the first person unit is destroyed
	player:base().pre_destroy = function (_self, ...)
		if alive(self.unit) then
			World:delete_unit(self.unit)
		end
		PlayerBase.pre_destroy(_self, ...)
	end

	local unit_base = self.unit:base()
	local unit_movement = self.unit:movement()
	local unit_inventory = self.unit:inventory()
	local unit_sound = self.unit:sound()

	-- Hook some functions
	unit_base.pre_destroy = function (self, unit)
		self._unit:movement():pre_destroy(unit)
		self._unit:inventory():pre_destroy(self._unit)
		UnitBase.pre_destroy(self, unit)
	end

	-- No contours
	self.unit:contour().add = function () end

	-- No revive SO
	unit_movement._register_revive_SO = function () end
	unit_movement.set_need_assistance = function (self, need_assistance) self._need_assistance = need_assistance end
	unit_movement.set_need_revive = function (self, need_revive) self._need_revive = need_revive end

	local look_vec_modified = Vector3()
	unit_movement.update = function (_self, ...)
	--[[
		HuskPlayerMovement.update(_self, ...)
		if alive(self.fp_unit) then
			-- correct aiming direction so that lasers are approximately the same in first and third person
			mvector3.set(look_vec_modified, self.fp_unit:camera():forward())
			mvector3.rotate_with(look_vec_modified, Rotation(self.fp_unit:camera():rotation():z(), 1))
			_self:set_look_dir_instant(look_vec_modified)
		end
	--]]
	end

--	unit_movement.play_redirect = function(self,redirect_name,at_time)
--		if not foobar then GloryKills:Print("play_redirect",redirect_name,debug.traceback()) end
--	end

	unit_movement.play_state = function(self,state_name,at_time)
--		if not foobar then GloryKills:Print("play_state",state_name,debug.traceback()) end
	end

	unit_movement.sync_action_walk_nav_point = function (_self, pos, speed, action)
		_self._movement_path = _self._movement_path or {}
		_self._movement_history = _self._movement_history or {}

		local state = alive(self.fp_unit) and self.fp_unit:movement():current_state()
		if not state then
			return
		end

		local path_len = #_self._movement_path
		pos = pos or path_len > 0 and _self._movement_path[path_len].pos or mvector3.copy(_self:m_pos())

		local type = state._state_data.on_zipline and "zipline" or (not state._gnd_ray or state._is_jumping) and "air" or "ground"

		local node = {
			pos = pos,
			speed = speed or 1,
			type = type,
			action = {action}
		}
		table.insert(_self._movement_path, node)
		table.insert(_self._movement_history, node)
		local len = #_self._movement_history
		if len > 1 then
			_self:_determine_node_action(#_self._movement_history, node)
		end
		for i = 1, #_self._movement_history - tweak_data.network.player_path_history, 1 do
			table.remove(_self._movement_history, 1)
		end
	end

	local hide_vec = Vector3(0, 0, -10000)
	unit_movement.set_position = function (_self, pos)
		if false then -- if alive(self.fp_unit) and self.fp_unit:camera():first_person() then
			_self._unit:set_position(hide_vec)
		else
			-- partial fix for movement sync, not perfect as it overrides some movement animations like jumping
			pos = alive(self.fp_unit) and self.fp_unit:movement():m_pos() or pos
			_self._unit:set_position(pos)
			mvector3.set(_self._m_pos, pos)
		end
	end

	unit_movement.set_head_visibility = function (_self, visible)
		_self._obj_visibilities = _self._obj_visibilities or {}
		local char_name = managers.criminals:character_name_by_unit(_self._unit)
		local new_char_name = managers.criminals.convert_old_to_new_character_workname(char_name)
		-- Disable head and hair objects - many thanks for being inconsistent with naming your objects, Overkill
		local try_names = { "g_vest_neck", "g_head", "g_head_%s", "g_%s_mask_off", "g_%s_mask_on", "g_hair", "g_%s_hair", "g_hair_mask_on", "g_hair_mask_off" }
		local obj, key
		for _, v in ipairs(try_names) do
			obj = char_name and _self._unit:get_object(Idstring(v:format(char_name))) or new_char_name and _self._unit:get_object(Idstring(v:format(new_char_name)))
			if obj then
				key = obj:name():key()
				_self._obj_visibilities[key] = _self._obj_visibilities[key] or obj:visibility()
				obj:set_visibility(visible and _self._obj_visibilities[key])
			end
		end
		_self._mask_visibility = _self._mask_visibility or _self._unit:inventory()._mask_visibility
		_self._unit:inventory():set_mask_visibility(visible and _self._mask_visibility)
	end

	unit_inventory.set_mask_visibility = function (self, state)
		HuskPlayerInventory.set_mask_visibility(self, not SETTING_CUSTOM_WEAPONS and state)
	end

	-- adjust weapon switch to support custom weapons
	local default_weaps = { "wpn_fps_pis_g17_npc", "wpn_fps_ass_amcar_npc" }
	unit_inventory._perform_switch_equipped_weapon = function (_self, weap_index, blueprint_string, cosmetics_string, peer)
		self._checked_weapons = self._checked_weapons or {}
		if not self._checked_weapons[weap_index] then
			local equipped = self.fp_unit:inventory():equipped_unit()
			local checked_weap = {
				name = equipped:base()._factory_id and equipped:base()._factory_id .. "_npc" or "wpn_fps_ass_amcar_npc",
				cosmetics_string = cosmetics_string or _self:cosmetics_string_from_peer(peer, checked_weap.name),
				blueprint_string = blueprint_string or equipped:blueprint_to_string()
			}

			local factory_weapon = tweak_data.weapon.factory[checked_weap.name]
			if not factory_weapon or factory_weapon.custom and not SETTING_CUSTOM_WEAPONS then
				local weapon = tweak_data.weapon[managers.weapon_factory:get_weapon_id_by_factory_id(equipped:base()._factory_id or "wpn_fps_ass_amcar_npc")]
				local based_on = weapon and weapon.based_on and tweak_data.weapon[weapon.based_on]
				local based_on_name = based_on and tweak_data.upgrades.definitions[weapon.based_on] and tweak_data.upgrades.definitions[weapon.based_on].factory_id
				local new_name = based_on_name and based_on.use_data.selection_index == weapon.use_data.selection_index and (based_on_name .. "_npc") or weapon and default_weaps[weapon.use_data.selection_index] or default_weaps[1]

				--ThirdPerson:log("Replaced custom weapon " .. checked_weap.name .. " with " .. new_name)

				checked_weap.name = new_name
				checked_weap.blueprint_string = managers.weapon_factory:blueprint_to_string(checked_weap.name, managers.weapon_factory:get_default_blueprint_by_factory_id(checked_weap.name))
				checked_weap.cosmetics_string = "nil-1-0"
			end

			self._checked_weapons[weap_index] = checked_weap
		end

		local checked_weap = self._checked_weapons[weap_index]
		if checked_weap then
			_self:add_unit_by_factory_name(checked_weap.name, true, true, checked_weap.blueprint_string, checked_weap.cosmetics_string)
		end
	end

	-- We don't want our third person unit to make any sound, so we're plugging empty functions here
	unit_sound.say = function () end
	unit_sound.play = function () end
	unit_sound._play = function () end

	-- Setup some stuff
	unit_inventory:set_melee_weapon(player_peer:melee_id(), true)

	self.unit:damage():run_sequence_simple(managers.blackmarket:character_sequence_by_character_id(player_peer:character_id(), player_peer:id()))

	unit_movement:set_character_anim_variables()
	if SETTING_IMMERSIVE_FIRST_PERSON then
		unit_movement:set_head_visibility(false)
	end
	
	local level_data = managers.job and managers.job:current_level_data()
	if level_data and level_data.player_sequence then
		self.unit:damage():run_sequence_simple(level_data.player_sequence)
	end

	-- Call missed events
	local handler = managers.network and managers.network._handlers and managers.network._handlers.unit
	if handler then
		for _, v in ipairs(self.delayed_events) do
			if handler[v.func] then
				handler[v.func](handler, self.unit, unpack(v.params))
			end
		end
		self.delayed_events = {}
	end

	--[[
	if SETTING_START_IN_THIRD_PERSON then
		player:camera():set_third_person()
	else
		player:camera()._toggled_fp = true
	end
	--]]

	-- Unregister from groupai manager so it doesnt count as an actual criminal
	managers.groupai:state():unregister_criminal(self.unit)
	
	
	
	
	
	local bm_mgr = managers.blackmarket
-- for whatever reason, the outfit string parses incorrectly for me, and honestly it's unnecessary work anyway
--	local loadout = managers.blackmarket:unpack_henchman_loadout_string(outfit_string)
--	local player_style = loadout and loadout.player_style or managers.blackmarket:get_default_player_style()
--	local suit_variation = loadout and loadout.suit_variation or "default"
--	local glove_id = loadout and loadout.glove_id or managers.blackmarket:get_default_glove_id()
	local visual_state = {
		armor_skin = tostring(bm_mgr:equipped_armor_skin() or "none"),
		armor_id = tostring(bm_mgr:equipped_armor(true) or "level_1"),
		visual_seed = visual_seed,
		player_style = tostring(bm_mgr:equipped_player_style()),
		suit_variation = tostring(bm_mgr:get_suit_variation()),
		glove_id = tostring(bm_mgr:equipped_glove_id()),
		mask_id = tostring(bm_mgr:equipped_mask().mask_id)
	}
	self:upd_visual_state(character_name,visual_state)
end

function GloryKills.set_viewmodel_visible(state,visible)
	local fp = state._camera_unit
	fp:set_visible(visible)
	if not visible then
		fp:base():hide_weapon()
	else
		fp:base():show_weapon()
	end
	for unit_id, unit_entry in pairs(fp:spawn_manager():spawned_units()) do
		if alive(unit_entry.unit) then
			unit_entry.unit:set_visible(visible)
		end
	end
end

function GloryKills:Print(...)
	if _G.Print then _G.Print(...) end
end

function GloryKills:upd_visual_state(character_name,visual_state) -- based on CriminalsManager:update_character_visual_state() and CriminalsManager.set_character_visual_state()
-- the reason for replacing it is so that this doesn't interfere with the character data
	local unit = self.unit
	
	local ids_unit = Idstring("unit")
	local _prev_visual_state = self._character_visual_state
	visual_state = visual_state or {}
	
	local visual_seed = visual_state.visual_seed or _prev_visual_state.visual_seed or CriminalsManager.get_new_visual_seed()
	local mask_id = visual_state.mask_id or _prev_visual_state.mask_id
	local armor_id = visual_state.armor_id or _prev_visual_state.armor_id or "level_1"
	local armor_skin = visual_state.armor_skin or _prev_visual_state.armor_skin or "none"
	local deployable_id = false

	if visual_state.deployable_id ~= nil then
		deployable_id = visual_state.deployable_id
	elseif _prev_visual_state.deployable_id then
		deployable_id = _prev_visual_state.deployable_id
	end
	
	local crim_mgr = managers.criminals
	
	local player_style = crim_mgr:active_player_style() or managers.blackmarket:get_default_player_style()
	local suit_variation = nil
	local user_player_style = visual_state.player_style or _prev_visual_state.player_style or managers.blackmarket:get_default_player_style()

	if not crim_mgr:is_active_player_style_locked() and user_player_style ~= managers.blackmarket:get_default_player_style() then
		player_style = user_player_style
		suit_variation = visual_state.suit_variation or _prev_visual_state.suit_variation or "default"
	end

	local glove_id = visual_state.glove_id or _prev_visual_state.glove_id or managers.blackmarket:get_default_glove_id()
	local character_visual_state = {
		is_local_peer = false,
		visual_seed = visual_seed,
		player_style = player_style,
		suit_variation = suit_variation,
		glove_id = glove_id,
		mask_id = mask_id,
		armor_id = armor_id,
		armor_skin = armor_skin,
		deployable_id = deployable_id
	}
	self._character_visual_state = character_visual_state


	if player_style then
		local unit_name = tweak_data.blackmarket:get_player_style_value(player_style, character_name, "third_unit")

		if unit_name then
			managers.dyn_resource:load(ids_unit, Idstring(unit_name), managers.dyn_resource.DYN_RESOURCES_PACKAGE, nil)
--			crim_mgr:safe_load_asset(character, unit_name, "player_style")
		end
	end

	if glove_id then
		local unit_name = tweak_data.blackmarket:get_glove_value(glove_id, character_name, "unit", player_style, suit_variation)

		if unit_name then
			managers.dyn_resource:load(ids_unit, Idstring(unit_name), managers.dyn_resource.DYN_RESOURCES_PACKAGE, nil)
--			crim_mgr:safe_load_asset(character, unit_name, "glove_id")
		end
	end

	if deployable_id then
		local deployable_tweak_data = tweak_data.equipments[deployable_id]
		local style_name = deployable_tweak_data.visual_style

		if style_name then
			local unit_name = tweak_data.blackmarket:get_player_style_value(style_name, character_name, "third_unit")

			if unit_name then
				managers.dyn_resource:load(ids_unit, Idstring(unit_name), managers.dyn_resource.DYN_RESOURCES_PACKAGE, nil)
--				crim_mgr:safe_load_asset(character, unit_name, "deployable_id")
			end
		end
	end

	CriminalsManager.set_character_visual_state(unit, character_name, character_visual_state)
--[[
	self._character_visual_state = {
		is_local_peer = false,
		visual_seed = visual_seed,
		player_style = user_player_style,
		suit_variation = suit_variation,
		glove_id = glove_id,
		mask_id = mask_id,
		armor_id = armor_id,
		armor_skin = armor_skin,
		deployable_id = deployable_id
	}
--]]
end


---------- sounds/effects callbacks

function GloryKills.get_equipped_melee_sound_event(event_type,variation)
	if not event_type then return end
	
-- based on PlayerStandard:_play_melee_sound()
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	
	--log("Execution equipped sound callback, weapon is ", melee_entry, " sound id is ", sound_id, " variation is ", variation )

	local melee_tweak_data = tweak_data.blackmarket.melee_weapons[melee_entry]
	
	local post_event = melee_tweak_data.sounds and melee_tweak_data.sounds[event_type]
	if not post_event then
		return
	end


	if type(post_event) == "table" then
		post_event = variation and post_event[variation] or post_event[1]
	end
	
	return post_event
	
--	self._unit:sound():play(post_event, nil, false)
end

function GloryKills.callback_play_sound_melee(unit,event_type)
	local event = GloryKills.get_equipped_melee_sound_event(event_type)
	GloryKills.callback_play_sound_gen(unit,event)
end

function GloryKills.callback_play_sound_gen(unit,event)
	if event and alive(unit) then
		local snd_ext = unit:sound()
		if snd_ext then
			snd_ext:play(event,nil,false)
		end
	end
end

function GloryKills.callback_play_effect(unit,...)
	local settings = {
		auto_parent = true -- if true, automatically uses the orientation object as the effect parent as a fallback (ie if parent parameter is not supplied, or if supplied parent is not found)
--		inherit_rotation = true, -- if true, uses the parent object rotation as the effect rotation (adds the user-supplied rotation, if supplied)
--		inherit_position = true, -- if true, uses the parent object rotation as the effect rotation (adds the user-supplied position, if supplied)
--		ignore_parent = false -- if true, spawn position/rotation can still be inherited from parent, but the effect itself is not force parented
	}
	
	local handlers = { -- [key] : [function]
		position = GloryKills.GetVector3FromParameters,
		effect = function(args)
			return tostring(args[1]) -- first argument
		end,
		normal = GloryKills.GetVector3FromParameters,
		rotation = GloryKills.GetRotationFromParameters,
		parent = function(args) return GloryKills.GetObjectFromParameters(args,unit) end,
		auto_parent = function(args)
			local state = GloryKills.GetBooleanFromParameters(args[1])
			if state ~= nil then
				settings.auto_parent = state
			end
			return nil -- we don't want this function to actually give any value to the constructor parameters
		end
		--[[
		inherit_rotation = function(args)
			local state = GloryKills.GetBooleanFromParameters(args[1])
			if state ~= nil then
				settings.inherit_rotation = state
			end
			--Print("inherit rotation?",state,type(state))
			return nil
		end,
		inherit_position = function(args)
			local state = GloryKills.GetBooleanFromParameters(args[1])
			if state ~= nil then
				settings.inherit_position = state
			end
			return nil
		end,
		ignore_parent = function(args)
			local state = GloryKills.GetBooleanFromParameters(args[1])
			if state ~= nil then
				settings.ignore_parent = state
			end
			return nil
		end
		--]]
	}
	
	local arguments = {} -- final arguments to effect spawner call
	
	local mode,parameters -- individual variables to hand to each handler for any given mode (eg. the caller specifies "position" and gives three values; use the position handler to create the final position value from those three values)
	for i,value in ipairs({...}) do
		if handlers[value] then
			-- new mode;
			-- handle previous mode first
			if mode and handlers[mode] then -- don't fulfil previous mode if this is the first mode in the list
				arguments[mode] = handlers[mode](parameters)
			end
			
			mode = value
			parameters = {}
		else
			table.insert(parameters,#parameters+1,value)
		end
		-- collect all values for this mode
		-- then execute the previous callback when a new mode begins
	end
	
	if mode and handlers[mode] then
		arguments[mode] = handlers[mode](parameters)
	end
	
	local effect_name = arguments.effect
	assert(effect_name,"GloryKills: Invalid effect " .. type(effect_name) .. " [" .. tostring(effect_name) .. "]")
	
	arguments.effect = Idstring(effect_name)
	--assert(arguments.position,"GloryKills: Invalid position " .. type(arguments.position) .. " [" .. tostring(arguments.position) .. "]")
	
	-- fallback effect parent
	if settings.auto_parent and not arguments.parent then
		arguments.parent = unit:orientation_object()
	end
	
	
	
	-- rotation and position are already local, added to parent's if provided
	--[[
	local parent = arguments.parent
	if not settings.ignore_parent then
		parent = parent or unit:orientation_object()
	end
	
	
	if parent then
		local rot_1 = parent:rotation()
		local pos_1 = parent:position()
		
		
		if settings.inherit_rotation and arguments.rotation then
			local rot_2 = arguments.rotation 
			arguments.rotation = Rotation(rot_1:yaw() + rot_2:yaw(),rot_1:pitch() + rot_2:pitch(),rot_1:roll() + rot_2:roll())
		end
		
		if arguments.position then
			if settings.inherit_position and not arguments.parent then
				mvector3.add(arguments.position,pos_1)
			end
			
			-- rotate after translation offset;
			-- todo specify which object to rotate with - camera, specified rotation from xml, or parent object)
			--mvector3.rotate_with(arguments.position,rot_1)
		end
	end
	--]]
	
--	_G.foo1 = arguments
--	GloryKills:Print("cb Play effect")
	
	local effect_id = World:effect_manager():spawn(arguments)
	if effect_id ~= -1 then
		GloryKills:Print("GloryKills: spawned effect #" .. tostring(effect_id) .. ": [" .. tostring(effect_name) .. "] at",arguments.position,arguments.rotation)
	else
		GloryKills:Print("GloryKills: failed to spawn effect (is it loaded?): [" .. tostring(effect_name) .. "]")
	end
end



-- deserialize constructor arguments from one or more strings
function GloryKills.DeserializeArgs(args)
	local tbl
	if #args == 1 then
		local s = args[1]
		-- assume it's formatted as a single string like (3.1415,69420,0.1)
		-- remove leading/trailing parentheses characters ()
		s = string.gsub(s,"^%(","")
		s = string.gsub(s,"%)$","")
		tbl = string.split(s,",")
	else
		tbl = {}
	end
	
	for i,v in ipairs(args) do 
		tbl[i] = tonumber(v)
	end
	
	return tbl
end

-- helper functions for the effect spawner
function GloryKills.GetVector3FromParameters(args)
	local tbl = GloryKills.DeserializeArgs(args)
	return Vector3(unpack(tbl))
end

function GloryKills.GetRotationFromParameters(args)
	local tbl = GloryKills.DeserializeArgs(args)
	return Rotation(unpack(tbl))
end

function GloryKills.GetBooleanFromParameters(args)
	-- set on true or false; ignore others as invalid
	local state
	if raw_state == "true" then
		state = true
	elseif raw_state == "false" then
		state = false
	end
	return state
end

-- from this unit, get the first applicable object in the provided list
function GloryKills.GetObjectFromParameters(args,unit)

	-- todo check if objects can be parented to other objects;
	-- if so, needs a loop to check the tree instead, or a flag to toggle this behavior
			
	for i,v in ipairs(args) do 
		local object = unit:get_object(Idstring(tostring(v)))
		if object then
			return object
		end
	end
	--return unit:orientation_object()
end
