	
-- custom functions from GloryKills, not vanilla
function CopMovement:callback_play_effect(unit,...)
	GloryKills:Print("CopMovement:callback_play_effect() ",unit,...)
	return GloryKills.callback_play_effect(unit,...)
end

function CopMovement:callback_play_sound(unit,event,...)
	GloryKills:Print("CopMovement:callback_play_sound() ",unit,event,...)
	return GloryKills.callback_play_sound(unit,event,...)
end
