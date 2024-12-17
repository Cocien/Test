-- myaddon.lua
_addon.name = 'Chatter'
_addon.author = 'Cocien'
_addon.version = '1.0'
_addon.commands = {'chat', 'ch'}



require('logger')
local packets = require('packets')

-- Message IDs
local message_ids = {
    melee_miss = 15, -- Message ID for a melee miss
    skillup = 38     -- Message ID for a skill up
}

-- Custom message placeholders
local function get_custom_miss_message()
    -- Customize this message for when YOU miss a melee hit
    return 'Oops! You missed your target!'
end

local function get_custom_skillup_message(skill_level)
    -- Customize this message for when YOU get a skillup
    return 'Great job! Your skill level has increased to ' .. skill_level .. '!'
end

-- Track misses and skillups
local fudo = {}  -- Track Fudo misses for the player

windower.register_event('action', function(act)
    local player = windower.ffxi.get_player()
    if not player then return end

    -- Process actions where the player is the actor
    if act.actor_id == player.id then
        for _, target in pairs(act.targets) do
            for _, action in pairs(target.actions) do
                -- Check for skillup message
                if action.message == message_ids.skillup then
                    local skill_level = action.param  -- New skill level
                    local message = get_custom_skillup_message(skill_level)
                    windower.chat.input('/p ' .. message)  -- Send to party chat
                end

                -- Check for melee miss message
                if action.message == message_ids.melee_miss then
                    local message = get_custom_miss_message()
                    windower.chat.input('/p ' .. message)  -- Send to party chat
                end

                -- Specific handling for Tachi: Fudo misses
                if action.message == 188 and act.param == 79 then  -- Tachi: Fudo Miss
                    local misses = fudo[player.name] or 0
                    fudo[player.name] = misses + 1
                    windower.chat.input('/p %s whiffs Fudo...%s':format(player.name, misses > 0 and ' again' or ''))  -- Send Fudo miss message
                end
            end
        end
    end
end)

-- Command to reset or check the data
windower.register_event('addon command', function(arg)
    if arg == 'r' then
        windower.send_command('lua r <addon_name>')  -- Reset command, replace <addon_name> with the actual addon name
        return
    end

    -- Display Fudo misses
    local whiffs = fudo[player.name] or 0
    if whiffs > 0 then
        windower.chat.input('/p Oh, and %s missed Fudo %s times in total.':format(player.name, whiffs))
    end
end)
