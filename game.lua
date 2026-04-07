Hooks:PostHook(PlayerManager, "activate_temporary_upgrade", "activencd", function (self, category, upgrade)
    if upgrade == "armor_break_invulnerable" then
        _sbar:setactive("active")
        _sbar:setactive("cd")
    end
end)

Hooks:PostHook(PlayerDamage, "update", "yoooo", function (self)
    _sbar:setupd("armor",
        self:get_real_armor() or 0.5,
        self:_max_armor() or 1)
end)

Hooks:PostHook(PlayerStandard, "_start_action_reload", "googoogaagaa", function(self)
    _sbar:setactive("reload", -(TimerManager:game():time() - self._state_data.reload_expire_t))
end)

Hooks:PostHook(PlayerStandard, "update", "bruh", function(self)
    local weapon = self._equipped_unit:base()
    _sbar:setupd("ammo",
        weapon:get_ammo_remaining_in_clip() or 0.5,
        weapon:get_ammo_max_per_clip() or 1)
end)---@diagnostic disable: undefined-global, undefined-field -- yooo idgaf xd

Hooks:PostHook(PlayerManager, "activate_temporary_upgrade", "activencd", function (self, category, upgrade)
    if upgrade == "armor_break_invulnerable" then
        _sbar:setactive("active")
        _sbar:setactive("cd")
    end
end)

Hooks:PostHook(PlayerDamage, "update", "yoooo", function (self)
    _sbar:setupd("armor",
        self:get_real_armor() or 0.5,
        self:_max_armor() or 1)
end)

-- Hooks:PostHook(PlayerStandard, "_start_action_reload", function(self)
--     _sbar:setactive("reload")
-- end)
