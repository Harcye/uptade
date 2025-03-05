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
local script_vers = 3
local script_vers_text = "1.05"

local update_url = "https://raw.githubusercontent.com/Harcye/uptade/refs/heads/main/update.ini"
local update_path = getWorkingDirectory().. "/update.ini"
local script_url = "https://github.com/Harcye/uptade/blob/main/autouptabes.lua?raw=true"
local script_path = thisScript().path

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    sampRegisterChatCommand("update", cmd_update)

    local id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    local nick = sampGetPlayerNickname(id)

    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            local updateIni = inicfg.load(nil, update_path)
            if updateIni and tonumber(updateIni.info.vers) > script_vers then
                sampAddChatMessage(u8:decode("Есть обновление! Версия: ") .. updateIni.info.vers, -1)
                update_state = true
            end
            os.remove(update_path)
        end
    end)

    while true do
        wait(0)
        if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage(u8:decode("Скрипт успешно обновлен!"), -1)
                    thisScript():reload()
                end
            end)
            break
        end
    end
end

function cmd_update(arg)
    sampShowDialog(1000, "Автообновление 2.0", u8:decode("Это урок по ffff iiii you обновлению\nНовая версия"), "Закрыть", "", 0)
end
