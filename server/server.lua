
local requirejob = Config.requirejob
local QBCore = exports['qbr-core']:GetCoreObject()

RegisterServerEvent("qbr-telegram:server:GetTelegrams")
AddEventHandler("qbr-telegram:server::GetTelegrams", function(source)
	local src = source
	if requirejob then 
		-- Reserved for Pony Express Job
	else 
		local Player =  QBCore.Functions.GetPlayer(src)
		local recipient = Player
		local recipientid = Player.PlayerData.citizenid
			exports.oxmysql:fetch("SELECT * FROM telegrams WHERE recipient=@recipient AND recipientid=@recipientid ORDER BY id DESC", { ['@recipient'] = recipient, ['@recipientid'] = recipientid }, function(result)
			TriggerClientEvent("qbr-telegram:client:ReturnMessages", src, result)
			end)
	end
end)

RegisterServerEvent("qbr-telegram:server::SendMessage")
AddEventHandler("qbr-telegram:server::SendMessage", function(firstname, lastname, message, players)
	local src = source
	if requirejob then 
		-- Reserved for Pony Express Job
	else
		local Player =  QBCore.Functions.GetPlayer(src)
		local sender = GetPlayerName(src)
		exports.oxmysql:fetch("SELECT identifier, characterid FROM characters WHERE firstname=@firstname AND lastname=@lastname", { ['@firstname'] = firstname, ['@lastname'] = lastname}, function(result)
			if result[1] then 
				local recipient = result[1].identifier 
				local recipientid = result[1].characterid

				local paramaters = { ['@sender'] = sender, ['@recipient'] = recipient, ['@recipientid'] = recipientid, ['@message'] = message }
					exports.oxmysql:execute("INSERT INTO telegrams (sender, recipient, recipientid, message) VALUES (@sender, @recipient, @recipientid, @message)",  paramaters, function(count)
						if count > 0 then 
							for k, v in pairs(players) do
								local reciever = QBCore.Functions.GetPlayer(v)
									if GetPlayerName() == firstname .. " " .. lastname then 
										TriggerClientEvent('QBCore:Notify', v, 'You have received a telegram.', 'success')
									end
							end
						else 
							TriggerClientEvent('QBCore:Notify', src, 'We are unable to process your Telegram right now. Please try again later.', 'error')
						end
					end)
				TriggerClientEvent('QBCore:Notify', src, 'Your telegram has been posted.', 'success')
			else 
				TriggerClientEvent('QBCore:Notify', src, 'Unable to process Telegram. Invalid first or lastname.', 'error')
			end
		end)
	end
end)

RegisterServerEvent("qbr-telegram:server::DeleteMessage")
AddEventHandler("qbr-telegram:server::DeleteMessage", function(id)
	local src = source
	exports.oxmysql:execute('DELETE FROM telegrams WHERE id = ?', {id})
		if count > 0 then 
			TriggerEvent("qbr-telegram:server:GetTelegrams", src)
		else
			TriggerClientEvent('QBCore:Notify', src, 'We are unable to delete your Telegram right now. Please try again later.', 'error')
		end
end)