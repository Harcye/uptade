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
local script_vers = 5
local script_vers_text = "2"

local update_url = "https://raw.githubusercontent.com/Harcye/uptade/refs/heads/main/update.ini"
local update_path = getWorkingDirectory().. "/update.ini"
local script_url = "https://raw.githubusercontent.com/Harcye/uptade/refs/heads/main/autouptabes.lua"
local script_path = thisScript().path

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

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
