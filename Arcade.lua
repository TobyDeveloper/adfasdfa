local NonArcades = {
    "Rainbow Ball Chair",
    "Golden Fountain",
    "Jukebox",
    "Lavish Table and Chairs",
    "Couch"
}
local ArcadeWaitTime = 1 -- Time between tp in seconds
local LoopWaitTime = 1 -- Time between when the last arcade tp and then restarting again
local FloorWaitTime = 2.5  -- Time for waiting for every single furniture to load in, if not loaded it will skip it
local TaskLoops = 2 -- How many times u want it to loop all the tasks
local TimeBeforeTask = 1 -- Time between teleporting and doing tasks at / to the arcade
local TimeBetweenTasks = 0.1 -- Time that it waits before doing the next task (it loops)

local ArcadeEmpire = {}
ArcadeEmpire.Furniture = {}
ArcadeEmpire.Loop = {}

function ArcadeEmpire.Furniture.IsArcade(Furniture)
    for _, NonArcade in pairs(NonArcades) do
        if Furniture.Name == NonArcade then return false end
    end

    return true
end

function ArcadeEmpire.Furniture.Position(Furniture)
    for _, Object in (Furniture:GetDescendants()) do
        if Object:IsA("BasePart") then return Object.Position end
    end
end

function ArcadeEmpire.Furniture.Tasks(Furniture)
    local FurnitureTasks = {}
    local Tasks = {
        "Broken",
        "Full",
        "Dirty"
    }

    for _, Object in (Furniture:GetChildren()) do
        for _, Task in (Tasks) do
            if Object:IsA("IntValue") and Object.Name == Task then
                table.insert(FurnitureTasks, Task)
            end
        end
    end
    
    return FurnitureTasks
end

function ArcadeEmpire.Furniture.Interact(Arcade, Task)
    local args = {
        [1] = Arcade,
        [2] = Task
    }
    
    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("FurnitureInteract"):FireServer(unpack(args))
end

function ArcadeEmpire.Furniture.Interacts(Arcade)
    local Tasks = ArcadeEmpire.Furniture.Tasks(Arcade)
    wait(TimeBeforeTask)

    for _, Task in (Tasks) do
        ArcadeEmpire.Furniture.Interact(Arcade, Task)
        wait(TimeBetweenTasks)
    end

    ArcadeEmpire.Furniture.Interact(Arcade, "Collect")
end

function ArcadeEmpire.Store()
    local Stores = game:GetService("Workspace").StoreModels:GetChildren()
    for _, Store in pairs(Stores) do
        if Store.Owner.Value == game:GetService("Players").LocalPlayer.Name then return Store end
    end
end

function ArcadeEmpire.Teleport(TargetPosition)
    local Player = game:GetService("Players").LocalPlayer
    if Player then else return false end

    local Char = Player.Character
    if Char then else return false end

    local HumRootPart = game.Players.LocalPlayer.Character.HumanoidRootPart

    if HumRootPart then
        HumRootPart.CFrame = CFrame.new(TargetPosition)

        return true else return false
    end
end

function ArcadeEmpire.IsLastFloor(FloorNumber)
    if FloorNumber == #ArcadeEmpire.Store().FloorTiles:GetChildren() then return true else return false end 
end

function ArcadeEmpire.Loop.All()
    for FloorNumber, Floor in (ArcadeEmpire.Store().FloorTiles:GetChildren()) do
        local FirstFloorTilePosition = Floor:GetChildren()[1].Position
        ArcadeEmpire.Teleport(Vector3.new(FirstFloorTilePosition.X, FirstFloorTilePosition.Y + 5, FirstFloorTilePosition.Z))
        wait(FloorWaitTime)
        ArcadeEmpire.Loop.Furniture()
        if ArcadeEmpire.IsLastFloor(FloorNumber) then return true end
    end
end

function ArcadeEmpire.Loop.Furniture()
    local store = ArcadeEmpire.Store()
    local Furnitures = workspace.StoreModels[store.Name].Furniture

    for _, Furniture in (Furnitures:GetChildren()) do
        if ArcadeEmpire.Furniture.IsArcade(Furniture) and ArcadeEmpire.Furniture.Position(Furniture) ~= nil then
            if ArcadeEmpire.Teleport(ArcadeEmpire.Furniture.Position(Furniture)) then end
            ArcadeEmpire.Furniture.Interacts(Furniture)
            wait(ArcadeWaitTime)
        end
    end

    return true
end
return ArcadeEmpire
