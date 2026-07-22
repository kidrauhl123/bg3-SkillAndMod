-- Each root is tried with the generated mod-qualified name first, then the
-- bare UUID fallback used by some Script Extender builds.
local ITEMS = {
    {
        tag = "[ZGLN]",
        label = "Zhuge Repeating Crossbow",
        templates = {
            "ZGLN_ZhugeRepeatingCrossbow_da292a90-af3a-4b82-a881-d09ccb9dbbe7",
            "da292a90-af3a-4b82-a881-d09ccb9dbbe7"
        }
    },
    {
        tag = "[ZABI]",
        label = "Sha Bi",
        templates = {
            "ZGLN_WhatDagger_66b59457-e857-4760-9105-75c0befe0b73",
            "66b59457-e857-4760-9105-75c0befe0b73"
        }
    }
}

local function ResolveHost(host)
    if host ~= nil and host ~= "" then
        return host
    end

    local okHost, detectedHost = pcall(Osi.GetHostCharacter)
    if okHost and detectedHost ~= nil and detectedHost ~= "" then
        return detectedHost
    end

    return nil
end

local function HasItem(item, host)
    for _, template in ipairs(item.templates) do
        local okQuery, first, second = pcall(Osi.TemplateIsInInventory, template, host)
        if okQuery then
            if first == true then
                return true
            end

            local count = second or first
            if tonumber(count) ~= nil and tonumber(count) > 0 then
                return true
            end
        end
    end

    return false
end

local GrantAll

local function RetryAll(host, itemIndex)
    Ext.Timer.WaitFor(1000, function()
        GrantAll(host, itemIndex or 1)
    end)
end

local function TryItem(item, host, templateIndex, onDone, itemIndex)
    if HasItem(item, host) then
        onDone()
        return
    end

    local index = templateIndex or 1
    local template = item.templates[index]
    if template == nil then
        RetryAll(host, itemIndex)
        return
    end

    local okAdd = pcall(Osi.TemplateAddTo, template, host, 1, 1)
    if not okAdd then
        if index < #item.templates then
            TryItem(item, host, index + 1, onDone, itemIndex)
        else
            RetryAll(host, itemIndex)
        end
        return
    end

    Ext.Timer.WaitFor(500, function()
        if HasItem(item, host) then
            _P(item.tag .. " " .. item.label .. " added to the host inventory using " .. template)
            onDone()
        elseif index < #item.templates then
            TryItem(item, host, index + 1, onDone, itemIndex)
        else
            RetryAll(host, itemIndex)
        end
    end)
end

GrantAll = function(host, itemIndex)
    local resolvedHost = ResolveHost(host)
    if resolvedHost == nil then
        RetryAll(nil, itemIndex)
        return
    end

    local index = itemIndex or 1
    local item = ITEMS[index]
    if item == nil then
        return
    end

    TryItem(item, resolvedHost, 1, function()
        Ext.Timer.WaitFor(250, function()
            GrantAll(resolvedHost, index + 1)
        end)
    end, index)
end

local grantQueued = false

local function QueueGrant(reason, delay)
    if grantQueued then
        return
    end

    grantQueued = true
    _P("[ZGLN] " .. reason .. " rescue trigger")
    Ext.Timer.WaitFor(delay or 1000, function()
        grantQueued = false
        GrantAll(nil, 1)
    end)
end

Ext.Events.SessionLoaded:Subscribe(function()
    QueueGrant("SessionLoaded", 2000)
end)

-- Some older saves expose the host character only after gameplay starts.
Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function()
    QueueGrant("LevelGameplayStarted", 1000)
end)
