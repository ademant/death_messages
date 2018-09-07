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
-- check if stamina is used and death may occured by exhausting
local mstamina = minetest.get_modpath("stamina")
local lstamina = 100
-- check if thirsty is used and death may occured by exhausting
local mthirsty = minetest.get_modpath("thirsty")
local lthirsty = 100
local msunburn = minetest.get_modpath("sunburn")
local lsunburn = 0
local mhbhunger = minetest.get_modpath("hbhunger")
local lhbhunger = 100

-- A table of quips for death messages.  The first item in each sub table is the
-- default message used when RANDOM_MESSAGES is disabled.
local messages = {}
local swas = { en = " was ", de = " war " }
local sby = { en = " by ", de = " von " }
local swith = {en = " with ", de = " mit " }

-- Default messages
-- Toxic death messages
messages.toxic = { en = {
	" melted into a ball of radioactivity.",
	" thought chemical waste was cool.",
	" melted into a jittering pile of flesh.",
	" couldn't resist that warm glow of toxic water.",
	" dug straight down.",
	" went into the toxic curtain.",
	" thought it was a toxic-tub.",
	" is radioactive.",
	" didn't know toxic water was radioactive."
},
de={
	" konnte dem warmen Glühen des giftigen Wassers nicht widerstehen.",
	" wollte wie Hulk werden.",
	" ist verstrahlt."
	}}
-- Lava death messages
messages.lava = { en = {
	" melted into a ball of fire.",
	" thought lava was cool.",
	" melted into a ball of fire.",
	" couldn't resist that warm glow of lava.",
	" dug straight down.",
	" went into the lava curtain.",
	" thought it was a hottub.",
	" is melted.",
	" didn't know lava was hot."
},de={
	" dachte über Lava laufen ist wie über Wasser laufen.",
	" nahm ein zu heißes Bad in der Lava.",
	" schmolz in der Lava dahin.",
	" verbrennt wie Papier.",
	" verbrannte sich die Finger.",
	" versuchte in Lava zu baden.",
	" wurde von der Lava gegrillt.",
	" hat sich an der Lava verbrannt."
}}

-- Drowning death messages
messages.water = { en = {
	" drowned.",
	" ran out of air.",
	" failed at swimming lessons.",
	" tried to impersonate an anchor.",
	" forgot he wasn't a fish.",
	" blew one too many bubbles."},
de = {
	" ertrank.",
	" verlor die Luft.",
	" dachte, er sei ein Anker.",
	" vergass, dass er kein Fisch ist.",
	" ist untergetaucht.",
	" wohnt jetzt bei den Fischen.",
	" starb an einer Überdosis Dihydrogenmonooxyd.",
	" vergass aufzutauchen.",
	" versank und tauchte nicht mehr auf."
}}
--end

-- Burning death messages
messages.fire = {en = {
	" burned to a crisp.",
	" got a little too warm.",
	" got too close to the camp fire.",
	" just got roasted, hotdog style.",
	" got burned up. More light that way."
},de={
	" verbrannte sich die Finger.",
	" wurde geröstet.",
	" wurde gegrillt.",
	" brennt wie eine Fackel.",
	" spielte mit dem Feuer."
}}

-- Other death messages
messages.other = {en = {
	" died.",
	" did something fatal.",
	" gave up on life.",
	" is somewhat dead now.",
	" passed out -permanently.",
	" kinda screwed up.",
	" couldn't fight very well.",
	" got 0wn3d.",
	" got SMOKED.",
	" got hurted by Oerkki.",
	" got blowed up."
},de={
	" starb.",
	" machte etwas Tödliches.",
	" ist irgendwie nicht mehr da.",
	" weilt nicht mehr unter den Lebenden.",
	" sieht die Radieschen von unten.",
	" dient als Dünger."
}}

-- exhausted
messages.exhausted = {en = {
	" was exhausted."
	},
	de = {
	" war erschöpft.",
	" vergass sein Pausenbrot zu Hause."
	}}
-- thirst
messages.thirst = {en = {
	" was too thirsty."
	},
	de = {
	" verdurstete.",
	" vergass sein Wasser zu Hause."
	}}
messages.sunburn = {en = {
	" burned by sun."
	},
	de = {
	" ist von der Sonne verbrannt.",
	" war zu lange in der Sonner."
	}}
	
-- PVP Messages
messages.pvp = {en = {
	" fisted",
	" sliced up",
	" rekt",
	" punched",
	" hacked",
	" skewered",
	" blasted",
	" tickled",
	" gotten",
	" sword checked",
	" turned into a jittering pile of flesh",
	" buried",
	" served",
	" poked",
	" attacked viciously",
	" busted up",
	" schooled",
	" told",
	" learned",
	" chopped up",
	" deader than ded ded ded",
	" CHOSEN to be the ONE",
	" all kinds of messed up",
	" smoked like a Newport",
	" hurted",
	" ballistic-ed",
	" jostled",
	" messed-da-frig-up",
	" lanced",
	" shot",
	" knocked da heck out",
	" pooped on"
},de={
	" geschlagen",
	" wurde verletzt",
	" angeschossen",
	" hitted",
	" begraben",
	" angegriffen",
	" wurde eine Lektion erteilt"
}}

-- Player Messages
messages.player = {en = {
	" for talking smack about thier mother.",
	" for cheating at Tic-Tac-Toe.",
	" for being a stinky poop butt.",
	" for letting Baggins grief.",
	" because it felt like the right thing to do.",
	" for spilling milk.",
	" for wearing a n00b skin.",
	" for not being good at PVP.",
	" because they are a n00b.",
	" for reasons uncertain.",
	" for using a tablet.",
	" with the quickness.",
	" while texting."
},de={
	" weil er nervte.",
	" denn er brachte den Müll nicht raus.",
	" für das ungeputzte Bad.",
	" da er keine Milch einkaufte.",
	" weil er die Hausaufgaben vergass.",
	" für das Ärgern des kleinen Bruders.",
	" für das Ärgern des großen Bruders.",
	" denn er hörte nicht auf seine Mutter.",
	" er gebrauchte zu oft das Wort digga.",
	" aus nicht näher genannten Gründen.",
	" für den Versuch bei Tic-Tac-Toe zu betrügen.",
	" denn er war nicht gut genug für den Kampf."
}}

-- MOB After Messages
messages.mobs = {en = {
	" and was eaten with a gurgling growl.",
	" then was cooked for dinner.",
	" then went to the supermarket.",
	" badly.",
	" terribly.",
	" horribly.",
	" in a haphazard way.",
	" that sparkles in the twilight with that evil grin.",
	" and now is covered by blood.",
	" so swiftly, that not even Chuck Norris could block.",
	" for talking smack about Oerkkii's mother.",
	" and grimmaced wryly."
},de={
	" zu schnell selbst für Chuck Norris.",
	" in einer tödlichen Weise.",
	" und ist das Mittagessen.",
	" und anschließend wieder ausgespuckt.",
	" weil er im Weg war.",
	" denn er brachte den Müll nicht raus.",
	" für das ungeputzte Bad.",
	" da er keine Milch einkaufte.",
	" weil er die Hausaufgaben vergass.",
	" für das Ärgern des kleinen Bruders.",
	" für das Ärgern des großen Bruders.",
	" denn er hörte nicht auf seine Mutter.",
	" er gebrauchte zu oft das Wort digga.",
	" aus nicht näher genannten Gründen.",
	" für den Versuch bei Tic-Tac-Toe zu betrügen.",
	" denn er war nicht gut genug für den Kampf."
}}

local function get_message(mtype)
	if RANDOM_MESSAGES then
		return messages[mtype][LANG][math.random(1, #messages[mtype][LANG])]
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
		minetest.chat_send_all(string.char(0x1b)..player:get_player_name().." "..reason)
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
