local RadioOpen = false
local RadioChannel = 'OFF'
local RadioVolume = 50
local text = ''
local colorbg = ''

lib.locale()

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if RadioOpen then
			drawTxt(0.880, 1.44, 1.0,1.0,0.35, '(' .. RadioChannel .. ' MHz)', 255, 255, 255, 255)
		end
	end
end)

RegisterNetEvent('radio:set')
AddEventHandler('radio:set', function()
	local input = lib.inputDialog(locale('setfreq'), {'1 - 250 MHz'})

	if not input then toggleRadio() end
	RadioChannel = tonumber(input[1])
	if RadioChannel == nil or RadioChannel < 1 or RadioChannel > 250 then
		RadioChannel = 'OFF'
		toggleRadio()
		local text, colorbg = locale('errorrange'), 'red'
		msgradio(text, colorbg)
		RadioOpen = false
	else
		if RadioChannel == nil or RadioChannel < 1 or RadioChannel < 11 then
			if ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'ambulance' or ESX.PlayerData.job.name == 'mechanic' then
				toggleRadio()
				exports['pma-voice']:setVoiceProperty('radioEnabled', true)
				exports['pma-voice']:setVoiceProperty('micClicks', true)
				exports['pma-voice']:setRadioChannel(RadioChannel)
				local text, colorbg = ' Freq. '..RadioChannel.. ' MHz ', 'green'
				msgradio(text, colorbg)
				RadioOpen = true
				--TriggerEvent('InteractSound_CL:PlayOnOne', 'police_radio', 0.10)
			else
				local text, colorbg = locale('chanperm'), 'red'
				RadioChannel = 'OFF'
				toggleRadio()
				msgradio(text, colorbg)
				RadioOpen = false
			end
		else
			toggleRadio()
			exports['pma-voice']:setVoiceProperty('radioEnabled', true)
			exports['pma-voice']:setVoiceProperty('micClicks', true)
			exports['pma-voice']:setRadioChannel(RadioChannel)
			--TriggerEvent('InteractSound_CL:PlayOnOne', 'police_radio', 0.10)
			local text, colorbg = ' Freq. '..RadioChannel.. ' MHz ', 'green'
			msgradio(text, colorbg)
			RadioOpen = true
		end
	end
end)

RegisterNetEvent('radio:volume')
AddEventHandler('radio:volume', function()
	local input = lib.inputDialog('Volume', {'0 - 100 %'})

	if not input then toggleRadio() end
	RadioVolume = tonumber(input[1])
	if RadioVolume == nil or RadioVolume < 0 or RadioVolume > 100 then
		RadioVolume = 50
		toggleRadio()
		local text, colorbg = locale('volerror'), 'red'
		msgradio(text, colorbg)
	else
		toggleRadio()
		exports['pma-voice']:setRadioVolume(RadioVolume)
		local text, colorbg = ' Vol. '..RadioVolume.. ' % ', 'green'
		msgradio(text, colorbg)
	end
end)

RegisterNetEvent('radio:leave')
AddEventHandler('radio:leave', function()
	exports['pma-voice']:setVoiceProperty('radioEnabled', false)
	exports['pma-voice']:setVoiceProperty('micClicks', false)
	exports["pma-voice"]:SetRadioChannel(0)
	exports["pma-voice"]:removePlayerFromRadio()
	toggleRadioAnimation(false)
	RadioChannel = 'OFF'
	RadioOpen = false
end)

RegisterNetEvent('radio:use')
AddEventHandler('radio:use', function()
    toggleRadio()
end)

RegisterNetEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function()
	exports['pma-voice']:setVoiceProperty('radioEnabled', false)
	exports['pma-voice']:setVoiceProperty('micClicks', false)
	exports["pma-voice"]:SetRadioChannel(0)
	exports["pma-voice"]:removePlayerFromRadio()
	RadioChannel = 'OFF'
	RadioOpen = false
end)

function LoadAnimDic(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(0)
        end
    end
end

function toggleRadioAnimation(pState)
	LoadAnimDic("cellphone@")
	if pState then
		TriggerEvent("attachItemRadio","radio01")
		TaskPlayAnim(PlayerPedId(), "cellphone@", "cellphone_text_read_base", 2.0, 3.0, -1, 49, 0, 0, 0, 0)
		radioProp = CreateObject(`prop_cs_hand_radio`, 1.0, 1.0, 1.0, 1, 1, 0)
		AttachEntityToEntity(radioProp, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.14, 0.01, -0.02, 110.0, 120.0, -15.0, 1, 0, 0, 0, 2, 1)
	else
		StopAnimTask(PlayerPedId(), "cellphone@", "cellphone_text_read_base", 1.0)
		ClearPedTasks(PlayerPedId())
		--if radioProp ~= 0 then
			DeleteObject(radioProp)
			radioProp = 0
		--end
	end
end

function toggleRadio()
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
				title = ' Freq. ' .. RadioChannel .. ' MHz ',
				arrow = true,
				event = 'radio:set',
			},
            {
				title = ' Vol. ' .. RadioVolume .. ' % ',
				arrow = true,
				event = 'radio:volume',
			},
		    {
				title = 'Disconnect channel',
				arrow = false,
				event = 'radio:leave',
			}
		}
	})
	lib.showContext('radio_menu')
end

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

function msgradio(text, colorbg)
    lib.showTextUI(text, {
        position = "top-center",
        icon = 'signal-bars',
        style = {
            borderRadius = 0,
            backgroundColor = colorbg,
            color = 'white'
        }
    })
    Citizen.Wait(5000)
    lib.hideTextUI()
end

RegisterCommand('toggleRadio', function()
    toggleRadio()
end, false)

RegisterKeyMapping('toggleRadio', 'Toggle Radio', 'keyboard', 'F10')