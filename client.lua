local RadioOpen = false
local RadioChannel = '(OFF)'
local RadioVolume = 50

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if RadioOpen then
			drawTxt(0.880, 1.44, 1.0,1.0,0.35, '(' .. RadioChannel .. ' MHz)', 255, 255, 255, 255)
		end
	end
end)

local function LoadAnimDic(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(0)
        end
    end
end

local function toggleRadioAnimation(pState)
	LoadAnimDic("cellphone@")
	if pState then
		TriggerEvent("attachItemRadio","radio01")
		TaskPlayAnim(PlayerPedId(), "cellphone@", "cellphone_text_read_base", 2.0, 3.0, -1, 49, 0, 0, 0, 0)
		radioProp = CreateObject(`prop_cs_hand_radio`, 1.0, 1.0, 1.0, 1, 1, 0)
		AttachEntityToEntity(radioProp, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.14, 0.01, -0.02, 110.0, 120.0, -15.0, 1, 0, 0, 0, 2, 1)
	else
		StopAnimTask(PlayerPedId(), "cellphone@", "cellphone_text_read_base", 1.0)
		ClearPedTasks(PlayerPedId())
		if radioProp ~= 0 then
			DeleteObject(radioProp)
			radioProp = 0
		end
	end
end

local function toggleRadio()
	toggleRadioAnimation(false)
    toggleRadioAnimation(true)
	lib.registerContext({
		id = 'radio_menu',
		title = 'Radio',
		onExit = function()
			toggleRadioAnimation(false)
		end,
		options = {
			{
				title = 'Set frequency: ' .. RadioChannel .. ' MHz',
			},
			{
				title = 'Set frequency',
				description = '1 to 250 MHz',
				arrow = true,
				event = 'radio:set',
			},
			{
				title = 'Set volume',
				description = '0 to 100 %',
				arrow = true,
				event = 'radio:volume',
			},
		   {
				title = 'Exit channel',
				arrow = false,
				event = 'radio:leave',
			}
		}
	})
	lib.showContext('radio_menu')
end

AddEventHandler('radio:set', function()
	local input = lib.inputDialog('Set frequency', {'1 to 250 MHz'})

	if not input then toggleRadio() end
	RadioChannel = tonumber(input[1])
	if RadioChannel == nil or RadioChannel < 1 or RadioChannel > 250 then
		ESX.ShowNotification('The frequency range is 1 to 250 Mhz', "error")
		toggleRadioAnimation(false)
		RadioChannel = '(OFF)'
		RadioOpen = false
	else
		if RadioChannel == nil or RadioChannel < 1 or RadioChannel < 11 then
			if ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'ambulance' or ESX.PlayerData.job.name == 'mechanic' then
				toggleRadio()
				exports['pma-voice']:setVoiceProperty('radioEnabled', true)
				exports['pma-voice']:setVoiceProperty('micClicks', true)
				exports['pma-voice']:setRadioChannel(RadioChannel)
				ESX.ShowNotification('Set: ' .. RadioChannel .. ' MHz')
				RadioOpen = true
				--TriggerEvent('InteractSound_CL:PlayOnOne', 'police_radio', 0.10)
			else
				ESX.ShowNotification('Channels 1 to 10 MHz require permissions', "error")
				toggleRadioAnimation(false)
				RadioChannel = '(OFF)'
				RadioOpen = false
			end
		else
			toggleRadio()
			exports['pma-voice']:setVoiceProperty('radioEnabled', true)
			exports['pma-voice']:setVoiceProperty('micClicks', true)
			exports['pma-voice']:setRadioChannel(RadioChannel)
			--TriggerEvent('InteractSound_CL:PlayOnOne', 'police_radio', 0.10)
			ESX.ShowNotification('Set: ' .. RadioChannel .. ' MHz')
			RadioOpen = true
		end
	end
end)

AddEventHandler('radio:volume', function()
	local input = lib.inputDialog('Set volume', {'od 0 do 100 %'})

	if not input then toggleRadio() end
	RadioVolume = tonumber(input[1])
	if RadioVolume == nil or RadioVolume < 0 or RadioVolume > 100 then
		ESX.ShowNotification('The volume range is 0 to 100 %', "error")
		toggleRadio()
		RadioVolume = 50
	else
		toggleRadio()
		exports['pma-voice']:setRadioVolume(RadioVolume)
		ESX.ShowNotification('Set: ' .. RadioVolume .. ' %')
	end
end)

AddEventHandler('radio:leave', function()
	exports['pma-voice']:setVoiceProperty('radioEnabled', false)
	exports['pma-voice']:setVoiceProperty('micClicks', false)
	exports["pma-voice"]:SetRadioChannel(0)
	exports["pma-voice"]:removePlayerFromRadio()
	toggleRadioAnimation(false)
	RadioChannel = '(OFF)'
	RadioOpen = false
end)

RegisterNetEvent('radio:use', function()
    toggleRadio()
end)

RegisterNetEvent('esx:onPlayerDeath', function()
	exports['pma-voice']:setVoiceProperty('radioEnabled', false)
	exports['pma-voice']:setVoiceProperty('micClicks', false)
	exports["pma-voice"]:SetRadioChannel(0)
	exports["pma-voice"]:removePlayerFromRadio()
	RadioChannel = '(OFF)'
	RadioOpen = false
end)

function drawTxt(x,y ,width,height,scale, text, r,g,b,a)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end
