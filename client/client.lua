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

RegisterNetEvent('qbr-telegram:viewtelegrams')
AddEventHandler('qbr-telegram:viewtelegrams', function()
    TriggerServerEvent("qbr-telegram:server:GetTelegrams")
    print('triggered telegrams')
end)

Citizen.CreateThread(function()
    for k,v in pairs(Config.Mailboxes) do
        if Config.Mailboxes[k].location == "desk" then
            exports['qbr-prompts']:createPrompt(v.name, v.coords, 0xF3830D8E, 'View your Telegrams', {
                type = 'client',
                event = 'qbr-telegram:viewtelegrams',
                args = { false, true, false },
            })
        elseif Config.Mailboxes[k].location == "pobox" then
            exports['qbr-prompts']:createPrompt(v.name, v.coords, 0xF3830D8E, 'View your Telegrams', {
                type = 'client',
                event = 'qbr-telegram:viewtelegrams',
                args = { false, true, false },
            })
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
    TriggerServerEvent("qbr-telegram:server:DeleteMessage", telegrams[index].id)
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
            
            TriggerServerEvent("qbr-telegram:server:SendMessage", firstname, lastname, message, GetPlayerServerIds())
           
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