local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Discord Webhook URL (replace with your actual Webhook URL)
local webhookUrl = "YOUR_DISCORD_WEBHOOK_URL_HERE"

-- Allowed GUI names (replace with your own game GUI names)
local allowedGUIs = {"MainMenu", "Shop", "Inventory", "Leaderboard"}

-- Function to send logs to Discord
local function sendToDiscord(message)
    local data = {
        content = message
    }
    local jsonData = HttpService:JSONEncode(data)
    
    -- Send POST request to Discord webhook
    local success, errorMessage = pcall(function()
        HttpService:PostAsync(webhookUrl, jsonData)
    end)
    
    if not success then
        warn("Failed to send log to Discord: " .. errorMessage)
    end
end

-- Monitor player actions for suspicious behavior
local function monitorPlayer(player)
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        local rootPart = character:WaitForChild("HumanoidRootPart")

        -- Speed check
        while humanoid and rootPart do
            task.wait(1)
            if rootPart.Velocity.Magnitude > 50 then -- Adjust speed limit based on game design
                player:Kick("Speed hacking detected!")
                sendToDiscord("Player " .. player.Name .. " was banned for speed hacking.")
            end
        end
    end)

    -- GUI injection detection
    player.PlayerGui.ChildAdded:Connect(function(gui)
        if not table.find(allowedGUIs, gui.Name) then
            player:Kick("Unauthorized GUI detected!")
            sendToDiscord("Player " .. player.Name .. " was banned for unauthorized GUI injection.")
        end
    end)
end

-- Monitor all players joining
Players.PlayerAdded:Connect(monitorPlayer)
