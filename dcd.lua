local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local PRINTER_NAME = "货币打印机" -- 根据实际游戏中的名称修改
local SEARCH_RADIUS = 500 -- 搜索半径
local TELEPORT_DELAY = 5 -- 服务器切换延迟(秒)
local BASE_GAME_ID =nsjxjcn
function findPrinter()
    local printers = workspace:FindFirstChild(PRINTER_NAME, true)
    if printers then
        return printers
    end
    return nil
end
function teleportTo(target)
    if not target or not target:IsA("BasePart") then return end
    
    local humanoid = Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        Character:SetPrimaryPartCFrame(CFrame.new(target.Position + Vector3.new(0, 3, 0)))
        wait(1)
        firetouchinterest(Character.HumanoidRootPart, target, 0) -- 开始接触
        wait(0.1)
        firetouchinterest(Character.HumanoidRootPart, target, 1) -- 结束接触
    end
end

-- 切换服务器
function switchServer()
    local servers = {}
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..BASE_GAME_ID.."/servers/Public?sortOrder=Asc&limit=100"))
    end)
    
    if success and result and result.data then
        for _, server in pairs(result.data) do
            if server.playing and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end
    end
    
    if #servers > 0 then
        local randomServer = servers[math.random(1, #servers)]
        TeleportService:TeleportToPlaceInstance(BASE_GAME_ID, randomServer, LocalPlayer)
    else
        -- 如果没有找到其他服务器，等待后重试
        wait(TELEPORT_DELAY)
        switchServer()
    end
end

-- 主循环
while true do
    local printer = findPrinter()
    
    if printer then
        print("找到货币打印机，正在前往...")
        teleportTo(printer)
        wait(3) -- 等待拾取完成
        
        -- 检查是否成功拾取
        if not findPrinter() then
            print("成功拾取货币打印机，准备切换服务器...")
            wait(TELEPORT_DELAY)
            switchServer()
            break -- 脚本会在新服务器重新执行
        else
            print("拾取失败，准备切换服务器...")
            wait(TELEPORT_DELAY)
            switchServer()
            break
        end
    else
        print("当前服务器未找到货币打印机，准备切换服务器...")
        wait(TELEPORT_DELAY)
        switchServer()
        break
    end
end
