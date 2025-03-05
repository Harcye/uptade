script_name('Autoupdate script')
script_author("FORMYS")
script_description('Автообновление')

require "lib.moonloader"

local dlstatus = require('moonloader').download_status
local inicfg = require 'inicfg'
local keys = require "vkeys"
local ingui = require 'imgui'
local encoding = require 'encoding'

encoding.default = 'CP1251'
local u8 = encoding.UTF8

local update_state = false
local script_vers = 6
local script_vers_text = "4"

local update_url = "https://raw.githubusercontent.com/Harcye/uptade/refs/heads/main/update.ini"
local update_path = getWorkingDirectory().. "/update.ini"
local script_url = "https://raw.githubusercontent.com/Harcye/uptade/refs/heads/main/autouptabes.lua"
local script_path = thisScript().path

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then
        print("SAMP or SAMP functions not loaded, exiting script...")
        return
    end
    while not isSampAvailable() do wait(100) end

    sampRegisterChatCommand("update", cmd_update)

    local id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    local nick = sampGetPlayerNickname(id)

    -- Добавляем обработку ошибок при загрузке файла
    local function downloadUpdateFile()
        local success, err = pcall(function()
            downloadUrlToFile(update_url, update_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    local updateIni = inicfg.load(nil, update_path)
                    if updateIni then
                        if tonumber(updateIni.info.vers) > script_vers then
                            sampAddChatMessage(u8:decode("Есть обновление! Версия: ") .. updateIni.info.vers, -1)
                            update_state = true
                        end
                    else
                        sampAddChatMessage(u8:decode("Ошибка при загрузке конфигурации обновлений."), -1)
                    end
                    os.remove(update_path)
                elseif status == dlstatus.STATUS_ERROR then
                    sampAddChatMessage(u8:decode("Ошибка при загрузке файла обновлений."), -1)
                end
            end)
        end)
        
        if not success then
            sampAddChatMessage(u8:decode("Ошибка выполнения функции скачивания обновлений: " .. err), -1)
        end
    end

    downloadUpdateFile()  -- Вызов функции для загрузки файла обновлений

    while true do
        wait(0)
        if update_state then
            -- Загрузка нового скрипта
            local function downloadScript()
                local success, err = pcall(function()
                    downloadUrlToFile(script_url, script_path, function(id, status)
                        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                            sampAddChatMessage(u8:decode("Скрипт успешно обновлен!"), -1)
                            thisScript():reload()
                        elseif status == dlstatus.STATUS_ERROR then
                            sampAddChatMessage(u8:decode("Ошибка при скачивании нового скрипта."), -1)
                        end
                    end)
                end)

                if not success then
                    sampAddChatMessage(u8:decode("Ошибка выполнения функции скачивания нового скрипта: " .. err), -1)
                end
            end

            downloadScript()  -- Вызов функции для скачивания нового скрипта
            update_state = false  -- Сбрасываем флаг после выполнения
            break  -- Прерываем цикл
        end
    end
end

function cmd_update(arg)
    sampShowDialog(1000, "Автообновление 2.0", u8:decode("Это урок по харкол  самообновление ааа обновлению\nНовая версия"), "Закрыть", "", 0)
end
