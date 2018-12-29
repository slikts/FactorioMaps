


fm = {}
require "generateMap"
require "autorun"


function exit()
    function NOT_AN_ERROR() SERIOUSLY_THIS_IS_NOT_AN_ERROR() end
    function SERIOUSLY_THIS_IS_NOT_AN_ERROR() PLEASE_DONT_REPORT_THIS_AS_AN_ERROR() end
    function PLEASE_DONT_REPORT_THIS_AS_AN_ERROR() exit_game() end

    NOT_AN_ERROR()
end


script.on_event(defines.events.on_tick, function(event)

    if fm.autorun then

        event.player_index = game.connected_players[1].index

        if nil == fm.tmp then
            -- freeze all entities. Eventually, stuff will run out of power, but for just 2 ticks, it should be fine.
            for key, entity in pairs(game.connected_players[1].surface.find_entities_filtered({invert=true, name="hidden-electric-energy-interface"})) do
                entity.active = false
            end
            fm.tmp = true
        end
    
        if fm.ticks == nil then
        
            fm.topfolder = "FactorioMaps/" .. (fm.autorun.name or "")
            fm.autorun.tick = game.tick

            hour = math.ceil(fm.autorun.tick / 60 / 60 / 60)
            exists = true
            fm.autorun.filePath = tostring(hour)
            i = 1
            while exists do
                exists = false
                if fm.autorun.mapInfo.maps ~= nil then
                    for _, map in pairs(fm.autorun.mapInfo.maps) do
                        if map.path == fm.autorun.filePath then
                            exists = true
                            break
                        end
                    end
                end
                if exists then
                    fm.autorun.filePath = tostring(hour) .. "-" .. tostring(i)
                    i = i + 1
                end
            end


            
            -- remove no path sign and ghost entities
            for key, entity in pairs(game.players[event.player_index].surface.find_entities_filtered({type={"flying-text","entity-ghost","tile-ghost"}})) do
                entity.destroy()
            end

            --spawn a bunch of hidden energy sources on lamps
            for _, t in pairs(game.players[event.player_index].surface.find_entities_filtered{type="lamp"}) do
                local control = t.get_control_behavior()
                if t.energy > 1 and (control and not control.disabled) or (not control) then
                    game.players[event.player_index].surface.create_entity{name="hidden-electric-energy-interface", position=t.position}
                end
            end

            -- freeze all entities. Eventually, stuff will run out of power, but for just 2 ticks, it should be fine.
            --game.pause()
            for key, entity in pairs(game.players[event.player_index].surface.find_entities_filtered({invert=true, name="hidden-electric-energy-interface"})) do
                entity.active = false
            end
            
            
            latest = ""
            if fm.autorun.day then
                latest = latest .. "\"" .. fm.autorun.name:sub(1, -2) .. "\" " .. fm.autorun.filePath .. " " .. game.players[event.player_index].surface.name .. " day\n"
            end
            if fm.autorun.night then
                latest = latest .. "\"" .. fm.autorun.name:sub(1, -2) .. "\" " .. fm.autorun.filePath .. " " .. game.players[event.player_index].surface.name .. " night\n"
            end
            game.write_file(fm.topfolder .. "latest.txt", latest, false, event.player_index)


            if fm.autorun.day then
                game.players[event.player_index].surface.daytime = 0
                fm.subfolder = "day"
                fm.generateMap(event)
            end
            
            fm.ticks = 1

        elseif fm.ticks < 2 then
            
            if fm.autorun.day then
                game.write_file(fm.topfolder .. "/Images/" .. fm.autorun.filePath .. "/" .. game.players[event.player_index].surface.name .. "/day/done.txt", "", false, event.player_index)
            end
    
            -- remove no path sign
            for key, entity in pairs(game.players[event.player_index].surface.find_entities_filtered({type="flying-text"})) do
                entity.destroy()
            end

            if fm.autorun.night then
                game.players[event.player_index].surface.daytime = 0.5
                fm.subfolder = "night"
                fm.generateMap(event)
            end
    
            fm.ticks = 2
    
        elseif fm.ticks < 3 then
            
            if fm.autorun.night then
                game.write_file(fm.topfolder .. "/Images/" .. fm.autorun.filePath .. "/" .. game.players[event.player_index].surface.name .. "/night/done.txt", "", false, event.player_index)
            end
            
            game.write_file(fm.topfolder .. "/Images/" .. fm.autorun.filePath .. "/" .. game.players[event.player_index].surface.name .. "/done.txt", "", false, event.player_index)
           
            
            -- unfreeze all entities
            for key, entity in pairs(game.players[event.player_index].surface.find_entities_filtered({})) do
                entity.active = true
            end

            fm.subfolder = nil
            fm.topfolder = nil
    
            fm.ticks = 3

        end

    
    elseif fm.ticks == nil then
        -- give instructions on how to use mod and a warning to disable it.
    
        event.player_index = game.connected_players[1].index
        fm.ticks = 1

        --game.pause()
        game.players[event.player_index].character.active = false
        
        local main = game.players[event.player_index].gui.center.add{type = "frame", caption = "How To Use FactorioMaps", direction = "vertical"}
        local topLine = main.add{type = "flow", direction = "horizontal"}
        topLine.add{type = "label", caption = "To use FactorioMaps, check out"}
        topLine.add{type = "label", caption = "https://git.io/factoriomaps."}.style.font = "default-bold"
        --topLine.add{type = "label", name = "main-end", caption = "."}.style
        main.add{type = "label", caption = "You can leave the mod disabled while you play.\nThe scripts will automagically enable it when it needs it!"}.style.single_line = false
        main.style.align = "right"
    
        local buttonContainer = main.add{type = "flow", direction = "horizontal"}
        local button = buttonContainer.add{type = "button", caption = "Back to main menu"}
        buttonContainer.style.horizontally_stretchable = true
        buttonContainer.style.align = "right"
        script.on_event(defines.events.on_gui_click, function(event)

            if event.element == button then
                main.destroy()
                exit()
            end

        end)
        
    end
end)
