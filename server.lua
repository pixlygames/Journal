local QBCore = exports['qb-core']:GetCoreObject()

-- Store player settings in a simple table for this example
-- For persistence across restarts, use a database (e.g., player metadata or a dedicated table)
local PlayerSettings = {}

-- Track recent coupon submissions to prevent duplicates
local RecentCoupons = {}

-- Initialize player settings when they join
AddEventHandler('QBCore:Server:OnPlayerLoaded', function(player)
    -- Reverted to using the player object passed to the event
    if not player or not player.PlayerData or not player.PlayerData.source then
        -- print("[Journal Server] Error: Invalid player data in OnPlayerLoaded event.")
        return 
    end
    local src = player.PlayerData.source

    PlayerSettings[src] = PlayerSettings[src] or {}
    
    -- Set default if not already set (e.g., from DB load)
    if PlayerSettings[src]['ShowF2Prompt'] == nil then
         -- Check config first for the global default
        local configDefault = Config.Settings.ShowF2Prompt
        -- If config doesn't exist or setting isn't there, default to true
        PlayerSettings[src]['ShowF2Prompt'] = (configDefault ~= nil) and configDefault or true
        -- print(string.format("[Journal Server] Initialized ShowF2Prompt for player %d to %s", src, tostring(PlayerSettings[src]['ShowF2Prompt'])))
    end
end)

-- Remove player settings when they leave
AddEventHandler('playerDropped', function(reason)
    local src = source -- Use the globally available source ID
    if PlayerSettings and PlayerSettings[src] then
        PlayerSettings[src] = nil
        -- print(string.format("[Journal Server] Cleared settings for player %d", src))
    end
end)

-- QBCore Callback to get a setting for a player
QBCore.Functions.CreateCallback('journal:getSetting', function(source, cb, key)
    local src = source
    local value = nil
    if PlayerSettings[src] and PlayerSettings[src][key] ~= nil then
        value = PlayerSettings[src][key]
    else
        -- Fallback to config default if player setting doesn't exist
        local configDefault = Config.Settings[key]
        value = (configDefault ~= nil) and configDefault or nil 
        -- If falling back, store it for the player for consistency this session
        if value ~= nil and PlayerSettings[src] then 
             PlayerSettings[src][key] = value
        end
    end
    -- print(string.format("[Journal Server] GetSetting: Player %d, Key %s, Value %s", src, key, tostring(value)))
    cb(value)
end)

-- Server Event to update a setting for a player
RegisterNetEvent('journal:updateSetting', function(key, value)
    local src = source
    if PlayerSettings[src] then
        PlayerSettings[src][key] = value
        -- print(string.format("[Journal Server] UpdateSetting: Player %d, Key %s, NewValue %s", src, key, tostring(value)))
        -- TODO: Add database saving logic here if persistence is needed
        -- Example: UpdatePlayerMetadata(src, key, value)

        -- Optionally notify the specific client that the setting was updated (redundant if client updates state immediately)
        -- TriggerClientEvent('journal:settingUpdated', src, key, value)
    else
        -- print(string.format("[Journal Server] Error: Could not update setting '%s' for player %d - settings not found.", key, src))
    end
end)

-- Server-side callback for help requests
RegisterNetEvent('journal:submitHelpRequest')
AddEventHandler('journal:submitHelpRequest', function(message)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        local playerName = Player.PlayerData.name
        local citizenId = Player.PlayerData.citizenid
        local formattedMessage = string.format("Help Request from %s (CitizenID: %s):\n\n%s", playerName, citizenId, message)
        
        -- Send message to Discord webhook
        SendToDiscord(formattedMessage)
        
        -- Notify player
        TriggerClientEvent('journal:helpSubmitted', src)
    end
end)

-- Server-side callback for coupon submissions
RegisterNetEvent('journal:submitCoupon')
AddEventHandler('journal:submitCoupon', function(coupon)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        local playerName = Player.PlayerData.name
        local citizenId = Player.PlayerData.citizenid
        
        -- Create a unique key for this player + coupon
        local couponKey = citizenId .. ":" .. coupon
        
        -- Check if this is a duplicate submission within the cooldown period
        if RecentCoupons[couponKey] and (os.time() - RecentCoupons[couponKey]) < 30 then
            -- Silently ignore duplicate submissions within 30 seconds
            return
        end
        
        -- Record this submission with timestamp
        RecentCoupons[couponKey] = os.time()
        
        -- Clean up old entries (older than 5 minutes)
        local cleanup = os.time() - 300 -- 5 minutes
        for k, timestamp in pairs(RecentCoupons) do
            if timestamp < cleanup then
                RecentCoupons[k] = nil
            end
        end
        
        -- Format and send the message
        local formattedMessage = string.format("Coupon Applied by %s (CitizenID: %s):\n\nCoupon Code: %s", playerName, citizenId, coupon)
        
        -- Send message to Discord webhook
        SendToCashbackDiscord(formattedMessage)
        
        -- Notify player
        TriggerClientEvent('journal:couponSubmitted', src)
    end
end)

-- Function to send message to Discord webhook
function SendToDiscord(message)
    local embed = {
        {
            ["title"] = "Player Help Request",
            ["description"] = message,
            ["color"] = 65280, -- Green color
            ["footer"] = {
                ["text"] = "PixlyRP Support System"
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }
    
    -- Send to Discord webhook
    PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({username = "Help System", embeds = embed}), { ['Content-Type'] = 'application/json' })
end

-- Function to send message to Cashback Discord webhook
function SendToCashbackDiscord(message)
    local embed = {
        {
            ["title"] = "Player Coupon Submission",
            ["description"] = message,
            ["color"] = 16776960, -- Yellow color
            ["footer"] = {
                ["text"] = "PixlyRP Cashback System"
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }
    
    -- Send to Discord webhook
    PerformHttpRequest(Config.CashbackWebhook, function(err, text, headers) end, 'POST', json.encode({username = "Cashback System", embeds = embed}), { ['Content-Type'] = 'application/json' })
end

-- Function to save help request to database using various methods
function SaveHelpRequestToDatabase(citizenId, playerName, message)
    if not exports['oxmysql'] then
        print("oxmysql not found. Help request only logged to console.")
        return
    end
    
    -- First check if phone_messages table exists
    exports.oxmysql:execute("SHOW TABLES LIKE 'phone_messages'", {}, function(tableExists)
        if not tableExists or #tableExists == 0 then
            -- If phone_messages doesn't exist, try admin_messages
            exports.oxmysql:execute("SHOW TABLES LIKE 'admin_messages'", {}, function(adminTableExists)
                if not adminTableExists or #adminTableExists == 0 then
                    -- Create a custom help_requests table if neither exists
                    CreateHelpRequestsTable(citizenId, playerName, message)
                else
                    -- Try to insert into admin_messages
                    InsertIntoAdminMessages(citizenId, playerName, message)
                end
            end)
        else
            -- Try to understand the structure of phone_messages
            exports.oxmysql:execute("DESCRIBE phone_messages", {}, function(columns)
                if not columns or #columns == 0 then
                    print("Could not retrieve phone_messages structure")
                    return
                end
                
                local hasPhone = false
                local hasCitizenId = false
                local hasSender = false
                local hasMessage = false
                local columnsMap = {}
                
                for _, column in ipairs(columns) do
                    columnsMap[column.Field:lower()] = true
                    
                    if column.Field:lower() == "phone" then
                        hasPhone = true
                    elseif column.Field:lower() == "citizenid" then
                        hasCitizenId = true
                    elseif column.Field:lower() == "sender" then
                        hasSender = true
                    elseif column.Field:lower() == "message" then
                        hasMessage = true
                    end
                end
                
                -- Determine which structure we're dealing with
                if hasCitizenId and hasSender and hasMessage then
                    -- Standard QBCore phone structure
                    exports.oxmysql:insert("INSERT INTO `phone_messages` (`citizenid`, `sender`, `message`, `date`) VALUES (?, ?, ?, ?)", {
                        'admin',
                        'Help Request from ' .. playerName,
                        'CitizenID: ' .. citizenId .. '\nMessage: ' .. message,
                        os.date('%Y-%m-%d %H:%M:%S')
                    }, function(result)
                        if result and result > 0 then
                            print("Help request saved to phone_messages table")
                        else
                            print("Failed to save help request to phone_messages table")
                        end
                    end)
                elseif hasPhone and hasMessage then
                    -- Alternative structure
                    exports.oxmysql:insert("INSERT INTO `phone_messages` (`phone`, `message`, `date`) VALUES (?, ?, ?)", {
                        'admin',
                        'Help Request from ' .. playerName .. ' [' .. citizenId .. ']: ' .. message,
                        os.date('%Y-%m-%d %H:%M:%S')
                    }, function(result)
                        if result and result > 0 then
                            print("Help request saved to phone_messages table (alt structure)")
                        else
                            print("Failed to save help request to phone_messages table")
                        end
                    end)
                else
                    -- Unknown structure, create our own table
                    CreateHelpRequestsTable(citizenId, playerName, message)
                end
            end)
        end
    end)
end

-- Create a help_requests table if other options fail
function CreateHelpRequestsTable(citizenId, playerName, message)
    exports.oxmysql:execute("CREATE TABLE IF NOT EXISTS `help_requests` (`id` INT AUTO_INCREMENT PRIMARY KEY, `citizenid` VARCHAR(50), `name` VARCHAR(100), `message` TEXT, `date` DATETIME, `status` VARCHAR(20) DEFAULT 'pending')", {}, function(success)
        if success then
            exports.oxmysql:insert("INSERT INTO `help_requests` (`citizenid`, `name`, `message`, `date`) VALUES (?, ?, ?, ?)", {
                citizenId,
                playerName,
                message,
                os.date('%Y-%m-%d %H:%M:%S')
            }, function(result)
                if result and result > 0 then
                    print("Help request saved to custom help_requests table")
                else
                    print("Failed to save help request to custom help_requests table")
                end
            end)
        else
            print("Failed to create help_requests table. Help request only logged to console.")
        end
    end)
end

-- Try to insert into admin_messages
function InsertIntoAdminMessages(citizenId, playerName, message)
    exports.oxmysql:execute("DESCRIBE admin_messages", {}, function(columns)
        if not columns or #columns == 0 then
            print("Could not retrieve admin_messages structure")
            return
        end
        
        local columnsMap = {}
        for _, column in ipairs(columns) do
            columnsMap[column.Field:lower()] = true
        end
        
        -- Attempt to insert with a generic structure that should work for most admin message tables
        if columnsMap.message then
            local query = "INSERT INTO `admin_messages` ("
            local params = {}
            local values = "VALUES ("
            
            if columnsMap.citizenid then
                query = query .. "`citizenid`, "
                values = values .. "?, "
                table.insert(params, citizenId)
            end
            
            if columnsMap.sender or columnsMap.from then
                query = query .. "`" .. (columnsMap.sender and "sender" or "from") .. "`, "
                values = values .. "?, "
                table.insert(params, playerName)
            end
            
            query = query .. "`message`, "
            values = values .. "?, "
            table.insert(params, "Help Request: " .. message)
            
            if columnsMap.date or columnsMap.timestamp then
                query = query .. "`" .. (columnsMap.date and "date" or "timestamp") .. "`, "
                values = values .. "?, "
                table.insert(params, os.date('%Y-%m-%d %H:%M:%S'))
            end
            
            -- Remove trailing commas
            query = query:sub(1, -3) .. ") "
            values = values:sub(1, -3) .. ")"
            
            exports.oxmysql:insert(query .. values, params, function(result)
                if result and result > 0 then
                    print("Help request saved to admin_messages table")
                else
                    print("Failed to save help request to admin_messages table. Query: " .. query .. values)
                    CreateHelpRequestsTable(citizenId, playerName, message)
                end
            end)
        else
            CreateHelpRequestsTable(citizenId, playerName, message)
        end
    end)
end

-- Notify admins in-game
RegisterNetEvent('journal:submitHelpRequest')
AddEventHandler('journal:submitHelpRequest', function(message)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        local playerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
        local admins = QBCore.Functions.GetPlayers()
        
        for i=1, #admins, 1 do
            local admin = QBCore.Functions.GetPlayer(admins[i])
            if admin and (admin.PlayerData.permission == "admin" or admin.PlayerData.permission == "god") then
                TriggerClientEvent('QBCore:Notify', admins[i], "Help request from " .. playerName, "error")
            end
        end
    end
end)