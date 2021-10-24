local telegrams = {}
local index = 1
local menu = false

RegisterNetEvent("qbr-telegram:client:ReturnMessages")
AddEventHandler("qbr-telegram:client:ReturnMessages", function(data)
    index = 1
    telegrams = data

    if next(telegrams) == nil then
        SetNuiFocus(true, true)
        SendNUIMessage({ message = "No telegrams to display." })
    else
        SetNuiFocus(true, true)
        SendNUIMessage({ sender = telegrams[index].sender, message = telegrams[index].message })
    end
end)

Citizen.CreateThread(function()
    while true do
    local InRange = false
    local PlayerPed = PlayerPedId()
    local PlayerPos = GetEntityCoords(PlayerPed)
        for key, loc in pairs(Config.POBoxes) do
            local dist = #(PlayerPos - vector3(loc["x"], loc["y"], loc["z"]))
            if dist < 2 then
                InRange = true
                Citizen.InvokeNative(0x2A32FAA57B937173, -1795314153, 2, loc["x"], loc["y"] + 0.5, loc["z"] - 1, 0, 0, 0, 0, 0, 0, 1.3, 1.3, 2.0, 93, 0, 0, 155, 0, 0, 2, 0, 0, 0, 0)            --end
                if dist < 1 then
                        DrawText3Ds(loc["x"], loc["y"], loc["z"] + 0.15, '~g~E~w~ - Press E to view your telegrams')
                    if IsControlJustPressed(0, 0xCEFD9220) then -- E
                        TriggerServerEvent("qbr-telegram:server::GetMessages")
                    end
                end
            if not inRange then
                Citizen.Wait(1000)
            end
                Citizen.Wait(3)            
            end
        end
    end
end)

function CloseTelegram()
    index = 1
    menu = false
    SetNuiFocus(false, false)
    SendNUIMessage({})
end

RegisterNUICallback('back', function()
    if index > 1 then
        index = index - 1
        SendNUIMessage({ sender = telegrams[index].sender, message = telegrams[index].message })
    end
end)

RegisterNUICallback('next', function()
    if index < #telegrams then
        index = index + 1
        SendNUIMessage({ sender = telegrams[index].sender, message = telegrams[index].message })
    end
end)

RegisterNUICallback('close', function()
    CloseTelegram()
end)

RegisterNUICallback('new', function()
    CloseTelegram()
    GetFirstname()
end)

RegisterNUICallback('delete', function()
    TriggerServerEvent("qbr-telegram:server::DeleteMessage", telegrams[index].id)
end)

function GetFirstname()
    AddTextEntry("FMMC_KEY_TIP8", "Recipient's Firstname: ")
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 30)

    while (UpdateOnscreenKeyboard() == 0) do
        Wait(0);
    end

    while (UpdateOnscreenKeyboard() == 2) do
        Wait(0);
        break
    end

    while (UpdateOnscreenKeyboard() == 1) do
        Wait(0)
        if (GetOnscreenKeyboardResult()) then
            local firstname = GetOnscreenKeyboardResult()

            GetLastname(firstname)

            break
        end
    end
end

function GetLastname(firstname)
    AddTextEntry("FMMC_KEY_TIP8", "Recipient's Lastname: ")
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 30)

    while (UpdateOnscreenKeyboard() == 0) do
        Wait(0);
    end

    while (UpdateOnscreenKeyboard() == 2) do
        Wait(0);
        break
    end

    while (UpdateOnscreenKeyboard() == 1) do
        Wait(0)
        if (GetOnscreenKeyboardResult()) then
            local lastname = GetOnscreenKeyboardResult()

            GetMessage(firstname, lastname)

            break
        end
    end
end

function GetMessage(firstname, lastname)
    AddTextEntry("FMMC_KEY_TIP8", "Message: ")
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 150)

    while (UpdateOnscreenKeyboard() == 0) do
        Wait(0);
    end

    while (UpdateOnscreenKeyboard() == 2) do
        Wait(0);
        break
    end

    while (UpdateOnscreenKeyboard() == 1) do
        Wait(0)
        if (GetOnscreenKeyboardResult()) then
            local message = GetOnscreenKeyboardResult()

            print(firstname, lastname, message)
            
            TriggerServerEvent("qbr-telegram:server::SendMessage", firstname, lastname, message, GetPlayerServerIds())
           
            break
        end
    end
end

function GetPlayerServerIds()
    local players = {}

    for i = 0, 31 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, GetPlayerServerId(i))
        end
    end

    return players
end
