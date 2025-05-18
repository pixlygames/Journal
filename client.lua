local QBCore = exports['qb-core']:GetCoreObject()
local journalOpen = false
local playerLoaded = false
local showPrompt = true -- Renamed from showStoreButtonPrompt, will be controlled by ShowF2Prompt setting
local isButtonVisible = false
local isPauseMenuActive = false -- Track pause menu state

-- Define NUI message and visibility functions first
local function SendButtonNUIMessage(data)
    SendNUIMessage(data)
end

local function UpdateButtonVisibility()
    -- Check main conditions first
    local shouldShowBasedOnState = playerLoaded and showPrompt and not journalOpen and not isPauseMenuActive
    
    -- Ensure playerLoaded is true before proceeding (safety check)
    if not playerLoaded then 
        -- print("[Journal Client Debug] UpdateButtonVisibility called but player not loaded yet.") -- DEBUG
        return 
    end
    -- print(string.format("[Journal Client Debug] UpdateButtonVisibility Called. playerLoaded: %s, showPrompt: %s, journalOpen: %s, isPauseMenu: %s", tostring(playerLoaded), tostring(showPrompt), tostring(journalOpen), tostring(isPauseMenuActive))) -- DEBUG
    -- print("[Journal Client Debug] Should show button? " .. tostring(shouldShowBasedOnState) .. ", Is button currently visible? " .. tostring(isButtonVisible)) -- DEBUG
    
    if shouldShowBasedOnState and not isButtonVisible then
        -- print("[Journal Client Debug] Sending showButton NUI message") -- DEBUG
        SendButtonNUIMessage({ action = "showButton" })
        isButtonVisible = true
    elseif not shouldShowBasedOnState and isButtonVisible then
        -- print("[Journal Client Debug] Sending hideButton NUI message") -- DEBUG
        SendButtonNUIMessage({ action = "hideButton" })
        isButtonVisible = false
    end
end

-- Wait for player to be loaded AND have control before doing anything else
Citizen.CreateThread(function()
    -- print("[Journal Client Debug] Starting load check loop...") -- DEBUG
    while not playerLoaded do
        local playerPed = PlayerPedId()
        local playerData = QBCore.Functions.GetPlayerData()
        
        -- Check if player data is loaded AND player has control
        if playerData and playerData.citizenid and playerPed ~= 0 and IsEntityVisible(playerPed) and IsPlayerControlOn(PlayerId()) then -- Added more checks
            -- print("[Journal Client Debug] Player Data Loaded and Control On.") -- DEBUG
            playerLoaded = true
            InitializeJournal() -- Call initialization now
            break
        else
            -- print("[Journal Client Debug] Waiting for load/control...") -- DEBUG (Can spam console)
        end
        Citizen.Wait(500) -- Check every 500ms
    end
    -- print("[Journal Client Debug] Load check loop finished.") -- DEBUG
end)

-- Thread to handle Pause Menu state
Citizen.CreateThread(function()
    while true do
        local currentlyPaused = IsPauseMenuActive()
        if currentlyPaused ~= isPauseMenuActive then
            -- print(string.format("[Journal Client Debug] Pause Menu state changed: %s", tostring(currentlyPaused))) -- DEBUG
            isPauseMenuActive = currentlyPaused
            UpdateButtonVisibility() -- Update button visibility when pause menu state changes
        end
        Citizen.Wait(250) -- Check pause menu state periodically
    end
end)

-- Function to initialize everything after player is confirmed loaded and screen faded
function InitializeJournal()
    -- print("[Journal Client Debug] Initializing Journal Script...") -- DEBUG
    -- Initialize showPrompt from settings
    QBCore.Functions.TriggerCallback('journal:getSetting', function(settingValue)
        -- print(string.format("[Journal Client Debug] Received Setting 'ShowF2Prompt': %s", tostring(settingValue))) -- DEBUG
        if settingValue ~= nil then
            showPrompt = settingValue
        else
            -- print("[Journal Client Debug] Warning: Received nil setting, using config default.") -- DEBUG
            showPrompt = Config.Settings.ShowF2Prompt 
        end
        -- First visibility update after loading and getting setting
        UpdateButtonVisibility()
    end, 'ShowF2Prompt') -- Use the correct setting key

    -- Register key mapping only after player loaded
    if Config.EnableKeyMapping then
        -- print("[Journal Client Debug] Registering F2 Key Mapping") -- DEBUG
        RegisterKeyMapping('togglejournal', 'Toggle Journal', 'keyboard', 'F2') -- Corrected label
        RegisterCommand('togglejournal', function()
            -- print("[Journal Client Debug] F2 Key Pressed - Executing togglejournal command") -- DEBUG
            -- Don't allow toggling if pause menu is active
            if isPauseMenuActive then return end 
            ToggleJournal()
        end, false)
    end
end

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    -- print("[Journal Client Debug] Player Unloaded Event Triggered") -- DEBUG
    playerLoaded = false
    isButtonVisible = false -- Ensure button is marked as hidden
    SendButtonNUIMessage({ action = "hideButton" }) -- Explicitly hide on unload
end)

-- Function to toggle journal visibility
function ToggleJournal()
    if not playerLoaded or isPauseMenuActive then return end -- Don't toggle if player isn't loaded or menu is open
    -- print("[Journal Client Debug] ToggleJournal Function Called. Current state journalOpen: " .. tostring(journalOpen)) -- DEBUG
    journalOpen = not journalOpen
    
    if journalOpen then
        -- print("[Journal Client Debug] Attempting to open journal UI and set focus") -- DEBUG
        SendNUIMessage({
            action = "open"
        })
        SetNuiFocus(true, true)
    else
        -- print("[Journal Client Debug] Attempting to close journal UI and remove focus") -- DEBUG
        SendNUIMessage({
            action = "close"
        })
        SetNuiFocus(false, false)
    end
    -- Update button visibility after journal state changes
    -- print("[Journal Client Debug] Waiting before UpdateButtonVisibility after toggle...") -- DEBUG
    Wait(100) -- Short delay to ensure focus changes apply
    UpdateButtonVisibility()
end

-- Register NUI callbacks
RegisterNUICallback('close', function(data, cb)
    ToggleJournal()
    cb('ok')
end)

-- Callback for setting waypoints
RegisterNUICallback('setWaypoint', function(data, cb)
    local missionId = data.missionId
    for _, mission in ipairs(Config.Missions) do
        if mission.id == missionId and mission.waypoint then -- Check if waypoint exists
            SetNewWaypoint(mission.waypoint.x, mission.waypoint.y)
            QBCore.Functions.Notify('Waypoint set to mission location', 'success')
            break
        end
    end
    cb('ok')
end)

-- Callback for submitting help requests
RegisterNUICallback('submitHelp', function(data, cb)
    local message = data.message
    TriggerServerEvent('journal:submitHelpRequest', message)
    cb('ok')
end)

-- Callback for submitting coupon codes
RegisterNUICallback('submitCoupon', function(data, cb)
    local coupon = data.coupon
    TriggerServerEvent('journal:submitCoupon', coupon)
    cb('ok')
end)

-- Callback for toggling Button prompt visibility from settings UI
RegisterNUICallback('togglePrompt', function(data, cb)
    if type(data.showPrompt) == 'boolean' then
        showPrompt = data.showPrompt -- Use the correct local variable
        -- Persist the setting change
        TriggerServerEvent('journal:updateSetting', 'ShowF2Prompt', showPrompt) -- Use the correct setting key
        UpdateButtonVisibility()
    else
        -- print("[Journal Client Debug] Error: Invalid data received for togglePrompt.") -- DEBUG
    end
    cb('ok')
end)

-- Load journal data
RegisterNUICallback('loadData', function(data, cb)
    -- Need to fetch the latest setting value when loading data for the settings page
    QBCore.Functions.TriggerCallback('journal:getSetting', function(settingValue)
        local currentShowPromptSetting = settingValue
        if currentShowPromptSetting == nil then 
            currentShowPromptSetting = Config.Settings.ShowF2Prompt -- Use default if not set
        end

        local journalData = {
            missions = Config.Missions,
            howToPlay = Config.HowToPlay,
            store = Config.Store,
            announcements = Config.Announcements,
            categories = Config.Categories,
            settings = { ShowF2Prompt = currentShowPromptSetting }, -- Pass current setting state using correct key
            webpageSettings = Config.WebpageSettings
        }
        cb(journalData)
    end, 'ShowF2Prompt') -- Use the correct setting key
end)

-- Event handler for successful help submission
RegisterNetEvent('journal:helpSubmitted')
AddEventHandler('journal:helpSubmitted', function()
    QBCore.Functions.Notify('Your help request has been submitted', 'success')
end)

-- Event handler for successful coupon submission
RegisterNetEvent('journal:couponSubmitted')
AddEventHandler('journal:couponSubmitted', function()
    QBCore.Functions.Notify('Your coupon code has been applied', 'success')
end)