Hooks:PostHook(PlayerMovement,"_setup_states","glorykills_registerstate",function(self)
	self._states.execution = PlayerStateExecution:new(self._unit)
end)