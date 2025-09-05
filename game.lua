---@diagnostic disable: undefined-global, undefined-field -- yooo idgaf xd

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