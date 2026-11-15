-- Inventario autoritativo do jogador. Nesta etapa os dados ficam em memoria.
local Players = game:GetService("Players")

local InventoryService = {}
local inventories = {}
local requestRemote
local updateRemote
local SLOT_COUNT = 20

local function makeStarterInventory()
    local slots = table.create(SLOT_COUNT)
    for index = 1, SLOT_COUNT do
        slots[index] = false
    end
    slots[1] = {
        id = "DZ_FLASHLIGHT",
        name = "Lanterna DZ-01",
        category = "Equipamento",
        quantity = 1,
        description = "Lanterna tática de exploração. A tecla F liga ou desliga a iluminação.",
    }
    return slots
end

local function sendInventory(player)
    local slots = inventories[player.UserId]
    if slots then
        updateRemote:FireClient(player, slots, player:GetAttribute("DZ_EquippedItem"))
    end
end

local function onPlayerAdded(player)
    inventories[player.UserId] = makeStarterInventory()
    player:SetAttribute("DZ_EquippedItem", nil)
    task.defer(sendInventory, player)
end

function InventoryService.Init(remotes)
    requestRemote = remotes.InventoryRequest
    updateRemote = remotes.InventoryUpdate

    requestRemote.OnServerEvent:Connect(function(player, action, slotIndex)
        local slots = inventories[player.UserId]
        if not slots then
            return
        end

        if action == "Request" then
            sendInventory(player)
            return
        end

        if action == "Equip" then
            if typeof(slotIndex) ~= "number" or slotIndex % 1 ~= 0 or slotIndex < 1 or slotIndex > SLOT_COUNT then
                return
            end

            local item = slots[slotIndex]
            if not item then
                return
            end

            player:SetAttribute("DZ_EquippedItem", item.id)
            sendInventory(player)
        elseif action == "Unequip" then
            player:SetAttribute("DZ_EquippedItem", nil)
            sendInventory(player)
        end
    end)

    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(function(player)
        inventories[player.UserId] = nil
    end)

    for _, player in Players:GetPlayers() do
        onPlayerAdded(player)
    end
end

return InventoryService
