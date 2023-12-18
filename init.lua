local NextSongMod = {
    lastRadioStation = "",
    lastSongIndex = 1,
    stationCName = ""
}

local NextSongRadioStations = require("NextSongRadioStations")
local MapOfStationNames = require("MapOfStationNames")
local MapOfSongs = require("MapOfSongs")

registerForEvent("onInit", function()
    -- ObserveAfter("GameObject", "AudioSwitch;GameObjectCNameCNameCName", function (selfObject, switchName, switchValue, emitterName)
    -- This block is here only for debugging things when needed
    -- end)

      -- Block for debugging
    -- ObserveAfter("VehicleRadioPopupGameController", "SetTrackName", function(selfObject, name)
    --     if name then
    --         print("Song name: " .. GetLocalizedItemNameByCName(name))
    --     end
    -- end)

    -- Method triggered when a radio device starts playing a station.
    -- Trigerred when turned on or when the player gets close to a radio device that is on
    ObserveBefore("Radio", "PlayGivenStation", function(this)
        -- Get radio station CName and set the last station to it
        local radioStationName = this:GetDevicePS():GetActiveRadioStation();
        local stationEventName = RadioStationDataProvider.GetStationName(radioStationName);
        -- Set the station name to be able to change songs
        NextSongMod.lastRadioStation = stationEventName
    end)
end)

registerHotkey("next_song_hotkey", "Next Song", function()
    -- Get the vehicle the player is in
    local playerVehicle = GetMountedVehicle(GetPlayer())
    if playerVehicle then
        -- Get the station CName and add it to the last radio station played
        local stationCName = playerVehicle:GetRadioReceiverStationName()
        local songCName = playerVehicle:GetRadioReceiverTrackName()
        if stationCName then
            if MapOfStationNames[stationCName.value] then
                -- Set the last radio station name to be the one the vehicle is playing
                NextSongMod.lastRadioStation = MapOfStationNames[stationCName.value]
            end
        end
        -- This block is for mapping song names to their localized text
        -- if songCName then
        --     print("Vechicle songCName: " .. GetLocalizedTextByKey(songCName))
        --     local songsFile = io.open("songs.txt", "a+")
        --     if songsFile then
        --         local songIndex = 1
        --         if NextSongMod.lastSongIndex == 1 then
        --         else
        --             songIndex = NextSongMod.lastSongIndex
        --         end
        --         local radioStationContent2 = NextSongRadioStations[NextSongMod.lastRadioStation]
        --         songsFile:write("[\"" .. GetLocalizedTextByKey(songCName) .. "\"] = \"" .. radioStationContent2[songIndex] .. "\"," .. "\n")
        --         songsFile:close()
        --         print("Type: " .. type(NextSongMod.lastRadioStation))
        --     end
        -- end
    end

    -- Handle Pocket Radio
    local playerPocketRadio = GetPlayer():GetPocketRadio()
    -- If the radio pocket is playing
    if playerPocketRadio and playerPocketRadio:IsActive() then
        local stationLongName = playerPocketRadio:GetStationName()
        if stationLongName then
            local stationName = MapOfStationNames[stationLongName.value]
            -- Set the last radio station name to be that of the pocket radio
            NextSongMod.lastRadioStation = stationName
        end
    end

    -- Get the radio station list of songs and check if there is a list of songs for it
    local radioStationContent = (type(NextSongMod.lastRadioStation) == "string" and NextSongRadioStations[NextSongMod.lastRadioStation] or NextSongRadioStations[NextSongMod.lastRadioStation.value])
    if radioStationContent then
        -- Set the next song number to play
        NextSongMod.lastSongIndex = NextSongMod.lastSongIndex + 1
        if NextSongMod.lastSongIndex == #radioStationContent + 1 then
            NextSongMod.lastSongIndex = 1
        end
        -- Print the requested song name in the console
        for key, value in pairs(MapOfSongs) do
            if value == radioStationContent[NextSongMod.lastSongIndex] then
                print("Getting song: " .. key)
            end
        end
        -- Request the next song from the station
        Game.GetAudioSystem():RequestSongOnRadioStation(NextSongMod.lastRadioStation, radioStationContent[NextSongMod.lastSongIndex])
    end
end)

registerHotkey("previous_song_hotkey", "Previous Song", function()
    -- Get the vehicle the player is in
    local playerVehicle = GetMountedVehicle(GetPlayer())
    if playerVehicle then
        -- Get the station CName and add it to the last radio station played
        local stationCName = playerVehicle:GetRadioReceiverStationName()
        if stationCName then
            if MapOfStationNames[stationCName.value] then
                NextSongMod.lastRadioStation = MapOfStationNames[stationCName.value]
            end
        end
    end
     -- Handle Pocket Radio
     local playerPocketRadio = GetPlayer():GetPocketRadio()
     -- If the radio pocket is playing
     if playerPocketRadio and  playerPocketRadio:IsActive() then
         local stationLongName = playerPocketRadio:GetStationName()
         if stationLongName then
             local stationName = MapOfStationNames[stationLongName.value]
             NextSongMod.lastRadioStation = stationName
         end
     end
 
     -- Get the radio station list of songs and check if there is a list of songs for it
     local radioStationContent = (type(NextSongMod.lastRadioStation) == "string" and NextSongRadioStations[NextSongMod.lastRadioStation] or NextSongRadioStations[NextSongMod.lastRadioStation.value])
    if radioStationContent then
        -- Set the next song number to play
        NextSongMod.lastSongIndex = NextSongMod.lastSongIndex - 1
        if NextSongMod.lastSongIndex == 0 then
            NextSongMod.lastSongIndex = #radioStationContent
        end
        -- Print the requested song in the console
        for key, value in pairs(MapOfSongs) do
            if value == radioStationContent[NextSongMod.lastSongIndex] then
                print("Getting song: " .. key)
            end
        end
        -- Request the next song from the station
        Game.GetAudioSystem():RequestSongOnRadioStation(NextSongMod.lastRadioStation, radioStationContent[NextSongMod.lastSongIndex])
    end
end)

return NextSongMod