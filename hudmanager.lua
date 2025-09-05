---@diagnostic disable: undefined-global, undefined-field -- yooo idgaf

_G._sbar = _sbar or {
    tweak_data = {
        global = {
            animation_speed = 1, -- breaks timers for now
        },
        panels = {
            [1] = {
                xywh = {
                    x = 0.45,
                    y = 0.56,
                    w = 0.10,
                    h = 0.0095
                },
                color = Color(0.5, 0, 0, 0)
            },
            [2] = {
                xywh = {
                    x = 0.45,
                    y = 0.56,
                    w = 0.10,
                    h = 0.0095
                },
                color = Color(0.5, 0, 0, 0)
            },
            [3] = {
                xywh = {
                    x = 0.45,
                    y = 0.56,
                    w = 0.10,
                    h = 0.0095
                },
                color = Color(0.5, 0, 0, 0)
            }
        },
        statuses = {
            reload = {
                type = "timer",
                duration = 1,
                color = Color(0.3, 0, 0, 1),
                offsets = {x = 2, y = 2, w = 0},
                panel_id = 2
            },
            -- ammo = {
            --     type = "ratio",
            --     color = Color(0.1, 1, 1, 1),
            --     offsets = {x = 0, y = 0, w = 0},
            --     panel_id = 2
            -- },

            active = {
                type = "timer",
                duration = 2,
                color = Color(0.3, 1, 1, 1),
                offsets = {x = 2, y = 2, w = 0},
                panel_id = 1
            },
            cd = {
                type = "timer",
                duration = 15,
                color = Color(0.3, 1, 0, 0),
                offsets = {x = 2, y = 2, w = 0},
                panel_id = 1,
                number = true
            },

            armor = {
                type = "ratio",
                color = Color(0.1, 1, 1, 1),
                offsets = {x = 0, y = 0, w = 0},
                panel_id = 3
            }
        }
    }
}

function _sbar:init()
    local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
    if not hud or not hud.panel then return end

    self._panels = {}
    local td = self.tweak_data

    for id, pdata in pairs(td.panels) do
        local panel = hud.panel:panel({
            name = "_sbar_panel_" .. id,
            x = hud.panel:w() * pdata.xywh.x,
            y = hud.panel:h() * pdata.xywh.y,
            w = hud.panel:w() * pdata.xywh.w,
            h = hud.panel:h() * pdata.xywh.h,
            alpha = 0
        })

        panel:rect({
            name = "_sbar_bg",
            color = pdata.color or Color(0.5, 0, 0, 0),
            halign = "grow",
            valign = "grow"
        })

        self._panels[id] = panel
    end

    for name, status in pairs(td.statuses) do
        self:start(name, status)
    end
end

function _sbar:start(name, status)
    local panel = self._panels[status.panel_id]
    if not panel then return end

    local offx = (status.offsets and status.offsets.x) or 0
    local offy = (status.offsets and status.offsets.y) or 0

    local rect = panel:rect({
        name = "_sbar_" .. name,
        x = offx,
        y = offy,
        w = 0,
        h = panel:h() - (offy * 2),
        color = status.color
    })

    status._rect = rect
    status._panel = panel

    if status.number then
        local txt = panel:text({
            name = "_sbar_" .. name .. "_text",
            text = "",
            font = tweak_data.hud.medium_font,
            font_size = panel:h() * 0.9,
            color = Color.white,
            align = "left",
            vertical = "center",
            w = panel:w(),
            h = panel:h()
        })
        status._text = txt
    end
end

function _sbar:setactive(name, duration_override)
    local status = self.tweak_data.statuses[name]
    if not status or status.type ~= "timer" then return end
    local rect = status._rect
    local panel = status._panel
    if not rect or not panel then return end

    local txt = status._text
    local speed = self.tweak_data.global.animation_speed or 1

    rect:stop()
    rect:set_w(panel:w() - 4)

    rect:animate(function(o)
        local duration = (duration_override or status.duration) / speed
        local start_time = TimerManager:game():time()

        over(duration, function(t)
            local w = math.lerp(panel:w() - ((status.offsets.y * 2) or 0) - (status.offsets.w or 0), 0, t)
            o:set_w(w)

            if txt then
                local remaining = math.max(0, duration - (TimerManager:game():time() - start_time))
                txt:set_text(string.format("%.1f", remaining))
                txt:set_x(o:right() - 2)
                txt:set_center_y(o:center_y())
            end
        end)

        o:set_w(0)
        if txt then
            txt:set_text("")
        end
        self:update_panels()
    end)

    self:update_panels()
end

function _sbar:setupd(name, cur, max)
    local status = self.tweak_data.statuses[name]
    if not status or status.type ~= "ratio" then return end
    local rect = status._rect
    local panel = status._panel
    if not rect or not panel then return end

    local ratio = (max > 0) and math.clamp(cur / max, 0, 1) or 0
    local target_w = panel:w() * ratio
    local speed = self.tweak_data.global.animation_speed or 1

    rect:stop()
    local start_w = rect:w()

    rect:animate(function(o)
        over(0.15 / speed, function(t)
            local w = math.lerp(start_w, target_w, t)
            o:set_w(w)
        end)
        o:set_w(target_w)
        _sbar:update_panels()
    end)

    self:update_panels()
end

function _sbar:is_status_active(status, panel)
    if not status or not status._rect or not panel then
        return false
    end

    if status.type == "timer" then
        return status._rect:w() > 0.1

    elseif status.type == "ratio" then
        local w = status._rect:w()
        return w < panel:w() - 1
    end

    return false
end

function _sbar:update_panels()
    if not self._panels then return end

    local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
    if not hud or not hud.panel then return end

    local td = self.tweak_data
    local spacing = hud.panel:h() * 0.005
    local visible_count = 0
    local speed = td.global.animation_speed or 1

    for id, panel in pairs(self._panels) do
        local pdata = td.panels[id]
        local xywh = pdata.xywh
        local base_y = hud.panel:h() * xywh.y
        local panel_h = hud.panel:h() * xywh.h

        local active = false
        for _, status in pairs(td.statuses) do
            if status.panel_id == id and self:is_status_active(status, panel) then
                active = true
                break
            end
        end

        if active then
            visible_count = visible_count + 1
            local target_y = base_y + (visible_count - 1) * (panel_h + spacing)

            if panel:alpha() < 1 or panel:y() ~= target_y then
                panel:stop()
                panel:animate(function(o)
                    local start_a = o:alpha()
                    local start_y = o:y()
                    local start_h = o:h()
                    over(0.25 / speed, function(t)
                        o:set_alpha(math.lerp(start_a, 1, t))
                        o:set_y(math.lerp(start_y, target_y, t))
                        o:set_h(math.lerp(start_h, panel_h, t))
                    end)
                    o:set_alpha(1)
                    o:set_y(target_y)
                    o:set_h(panel_h)
                end)
            end
        else
            if panel:alpha() > 0 then
                panel:stop()
                panel:animate(function(o)
                    local start_a = o:alpha()
                    local start_h = o:h()
                    over(0.25 / speed, function(t)
                        o:set_alpha(math.lerp(start_a, 0, t))
                        o:set_h(math.lerp(start_h, 0, t))
                    end)
                    o:set_alpha(0)
                    o:set_h(0)
                end)
            end
        end
    end
end

local _init_finalize = HUDManager["init_finalize"]
function HUDManager:init_finalize(...)
    _init_finalize(self, ...)
    _sbar:init()
end

local _update = HUDManager["update"]
function HUDManager:update(...)
    _update(self, ...)
    _sbar:update_panels()
end