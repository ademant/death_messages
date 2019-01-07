--[[
death_messages - A Minetest mod which sends a chat message when a player dies.
Copyright (C) 2016  EvergreenTree

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]
--Carbone death coords
--License of media (textures and sounds) From carbone subgame
--------------------------------------
--mods/default/sounds/player_death.ogg: from OpenArena – GNU GPL v2.
-----------------------------------------------------------------------------------------------
local title = "Death Messages"
local version = "0.1.4"
local mname = "death_messages"
-----------------------------------------------------------------------------------------------
dofile(minetest.get_modpath("death_messages").."/settings.txt")
-----------------------------------------------------------------------------------------------
local LANG = minetest.settings:get("language")
if not (LANG and (LANG ~= "")) then LANG = "en" end
-- check if stamina and/or hbhunger is used and death may occured by exhausting
local mstamina = minetest.get_modpath("stamina")
local mhbhunger = minetest.get_modpath("hbhunger")
local lstamina = 100
-- check if thirsty is used and death may occured by exhausting
local mthirsty = minetest.get_modpath("thirsty")
local lthirsty = 100
local msunburn = minetest.get_modpath("sunburn")
local lsunburn = 0

-- A table of quips for death messages.  The first item in each sub table is the
-- default message used when RANDOM_MESSAGES is disabled.
local messages = {}
local swas = { en = " was ", de = " war " }
local sby = { en = " by ", de = " von " }
local swith = {en = " with ", de = " mit " }

-- Default messages

for _,lan in ipairs({"en","de"}) do
	local infile=minetest.get_modpath("death_messages").."/"..lan..".txt"
	local file = io.open(infile, "r")
	for line in file:lines() do
		if line:sub(1,1) ~= "#" then -- lines starting with # are handled as comment
			local attribs = line:gsub("\r",""):split(",",true)
			if #attribs>1 then
				if messages[attribs[1]]==nil then
					messages[attribs[1]]={}
				end
				if messages[attribs[1]][lan] == nil then
					messages[attribs[1]][lan] = {}
				end
				table.insert(messages[attribs[1]][lan],attribs[2])
			end
		end
	end
end

print(dump2(messages))

local function get_message(mtype)
	if RANDOM_MESSAGES then
		return messages[mtype][LANG][math.random(1, #messages[mtype])]
	else
		return messages[1] -- 1 is the index for the non-random message
	end
end

local function get_int_attribute(player, key)
	local level = player:get_attribute(key)
	if level then
		return tonumber(level)
	else
		return nil
	end
end




minetest.register_on_dieplayer(function(player,reason)
	if reason == nil then
		local player_name = player:get_player_name()
		local node = minetest.registered_nodes[minetest.get_node(player:getpos()).name]
		local pos = player:getpos()
		local death = {x=0, y=23, z=-1.5}
		minetest.sound_play("player_death", {pos = pos, gain = 1})
		pos.x = math.floor(pos.x + 0.5)
		pos.y = math.floor(pos.y + 0.5)
		pos.z = math.floor(pos.z + 0.5)
		local param2 = minetest.dir_to_facedir(player:get_look_dir())
		local player_name = player:get_player_name()
		if minetest.is_singleplayer() then
			player_name = "You"
		end
		if mstamina ~= nil then
			lstamina = get_int_attribute(player, "stamina:level")
		end
		if mhbhunger ~= nil then
			lstamina = tonumber(hbhunger.hunger[player_name])
		end
		if mthirsty ~= nil then
			lthirsty = thirsty.get_thirst_factor(player)
		end
		if msunburn ~= nil then
			lsunburn = sunburn.get_sunburn(player)
		end
		
		-- Death by lava
		if node.name == "default:lava_source" then
			minetest.chat_send_all(
			string.char(0x1b).."(c@#00CED1)"..player_name .. 
			string.char(0x1b).."(c@#ff0000)"..get_message("lava"))
			--player:setpos(death)
		elseif node.name == "default:lava_flowing"  then
			minetest.chat_send_all(
			string.char(0x1b).."(c@#00CED1)"..player_name .. 
			string.char(0x1b).."(c@#ff0000)"..get_message("lava"))
			--player:setpos(death)
		-- Death by drowning
		elseif player:get_breath() == 0 then
			minetest.chat_send_all(
			string.char(0x1b).."(c@#00CED1)"..player_name .. 
			string.char(0x1b).."(c@#ff0000)"..get_message("water"))
			--player:setpos(death)
		-- Death by fire
		elseif node.name == "fire:basic_flame" then
			minetest.chat_send_all(
			string.char(0x1b).."(c@#00CED1)"..player_name .. 
			string.char(0x1b).."(c@#ff0000)"..get_message("fire"))
			--player:setpos(death)
		-- Death by Toxic water
		elseif node.name == "es:toxic_water_source" then
			minetest.chat_send_all(
			string.char(0x1b).."(c@#00CED1)"..player_name .. 
			string.char(0x1b).."(c@#ff0000)"..get_message("toxic"))
			--player:setpos(death)
		elseif node.name == "es:toxic_water_flowing" then
			minetest.chat_send_all(
			string.char(0x1b).."(c@#00CED1)"..player_name .. 
			string.char(0x1b).."(c@#ff0000)"..get_message("toxic"))
			--player:setpos(death)
		elseif node.name == "groups:radioactive" then
			minetest.chat_send_all(
			string.char(0x1b).."(c@#00CED1)"..player_name .. 
			string.char(0x1b).."(c@#ff0000)"..get_message("toxic"))
			--player:setpos(death)	
		elseif lthirsty <= 1 then
			minetest.chat_send_all(
			string.char(0x1b).."(c@#00CED1)"..player_name .. 
			string.char(0x1b).."(c@#ff0000)"..get_message("thirst"))
		elseif lstamina <= 1 then
			minetest.chat_send_all(
			string.char(0x1b).."(c@#00CED1)"..player_name .. 
			string.char(0x1b).."(c@#ff0000)"..get_message("exhausted"))
		elseif lsunburn >= 19 then
			minetest.chat_send_all(
			string.char(0x1b).."(c@#00CED1)"..player_name .. 
			string.char(0x1b).."(c@#ff0000)"..get_message("sunburn"))
		-- Death by something else
		else
			minetest.chat_send_all(
			string.char(0x1b).."(c@#ffffff)"..player_name .. 
			string.char(0x1b).."(c@#ff0000)"..get_message("other"))  --toospammy
			--minetest.after(0.5, function(holding)
				--player:setpos(death)  --gamebreaker?
			--end)
		end
		
		
		--minetest.chat_send_all(string.char(0x1b).."(c@#000000)".."[DEATH COORDINATES] "..string.char(0x1b).."(c@#ffffff)" .. player_name .. string.char(0x1b).."(c@#000000)".." left a corpse full of diamonds here: " ..
		--minetest.pos_to_string(pos) .. string.char(0x1b).."(c@#aaaaaa)".." Come and get them!")
		--player:setpos(death)
		--minetest.sound_play("pacmine_death", { gain = 0.35})  NOPE!!!
	else
		print(dump2(reason))
		if reason.type ~= nil then
				minetest.chat_send_all(string.char(0x1b)..player:get_player_name().." "..reason.type)
		else
			if (#reason > 1) then
				minetest.chat_send_all(string.char(0x1b)..player:get_player_name().." "..reason[1])
			else
				minetest.chat_send_all(string.char(0x1b)..player:get_player_name().." "..reason)
			end
		end
	end
end)

--bigfoot code
-- bigfoot547's death messages
-- hacked by maikerumine

-- get tool/item when  hitting   get_name()  returns item name (e.g. "default:stone")
minetest.register_on_punchplayer(function(player, hitter)
	local pos = player:getpos()
	local death = {x=0, y=23, z=-1.5}
   if not (player or hitter) then
      return false
   end
   if not hitter:get_player_name() == "" then
      return false
   end
   minetest.after(0, function(holding)
      if player:get_hp() == 0 and hitter:get_player_name() ~= "" and holding == hitter:get_wielded_item() ~= "" then
	  
			local holding = hitter:get_wielded_item() 
				if holding:to_string() ~= "" then  
				local weap = holding:get_name(holding:get_name())
					if holding then  
					minetest.chat_send_all(
					string.char(0x1b).."(c@#00CED1)"..player:get_player_name()..
					string.char(0x1b).."(c@#ff0000)"..swas[LANG]..
					string.char(0x1b).."(c@#ff0000)"..get_message("pvp")..
					string.char(0x1b).."(c@#ff0000)"..sby[LANG]..
					string.char(0x1b).."(c@#00CED1)"..hitter:get_player_name()..
					string.char(0x1b).."(c@#ffffff)"..swith[LANG]..
					string.char(0x1b).."(c@#FF8C00)"..weap..
					string.char(0x1b).."(c@#00bbff)"..get_message("player"))  --TODO: make custom mob death messages
					
					end 	
				end

		if player=="" or hitter=="" then return end -- no killers/victims
        return true
	

		elseif hitter:get_player_name() == "" and player:get_hp() == 0 then
					minetest.chat_send_all(
					string.char(0x1b).."(c@#00CED1)"..player:get_player_name()..
					string.char(0x1b).."(c@#ff0000)"..swas[LANG]..
					string.char(0x1b).."(c@#ff0000)"..get_message("pvp")..
					string.char(0x1b).."(c@#ff0000)"..sby[LANG]..
					string.char(0x1b).."(c@#FF8C00)"..hitter:get_luaentity().name..  --too many mobs add to crash
					string.char(0x1b).."(c@#00bbff)"..get_message("mobs"))  --TODO: make custom mob death messages
					
		if player=="" or hitter=="" or hitter=="*"  then return end -- no mob killers/victims
		else
		
        return false
      end
	   
   end)
   
end)

-----------------------------------------------------------------------------------------------
print("[Mod] "..title.." ["..version.."] ["..mname.."] ["..LANG.."] Loaded...")
-----------------------------------------------------------------------------------------------
