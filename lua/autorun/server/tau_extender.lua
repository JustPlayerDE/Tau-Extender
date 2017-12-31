
/*

	Commands:
		/tau add
			Adds one corner (you need to do this 2 times)
		/tau reset
			Removes the current corner selections
		/tau save
			Permanently Saves the selected Zone
	
	This is to help some guys out with configuring the "Tom's Jailbreak System(auto unarrest)" addon you can find under
	https://www.gmodstore.com/scripts/view/536/toms-jailbreak-systemauto-unarrest
	

	if you need help about this file then contact me on gmodstore (JustPlayerDE)
	
	Note: the creator of the addon does nothing have to do with this file
	
*/

local TauEx = {}
local Zones = {}
 // Disable unarrest1 to unarrest6 and all other data that was set in the config before this script is loaded
TauEx.DisableDefaultZones = true

// Here is your Unarrest function that you can edit
TauEx.Funct = function( ply ) 	// \/ \/
	if ply:isArrested() then
		ply:unArrest()
	end
end								// /\ /\



//
//	DO NOT TOUCH THIS PLS
//
	util.AddNetworkString( "update_tau_rendering" )
TauEx.SaveData = function(data)
	data = data or {}
	file.CreateDir( "tauextender" )
	file.Write( "tauextender/"..game.GetMap()..".txt", util.TableToJSON( data ) )
end

TauEx.LoadData = function()
	local data = file.Read( "tauextender/"..game.GetMap()..".txt", "DATA" ) -- Read the file
	if not data then MsgC("TauEX: No data for "..game.GetMap().."\n") return end -- the File doesn't exist so we dont need to load anything
	Zones = util.JSONToTable( data )	// otherwise put the data in our list
end

// Adding data to TAU
TauEx.SubmitData = function(zones)
	for id, data in pairs(Zones) do
	if tau.triggers[id] then continue end // We dont like dublicate errors
	
		tau.Register(id, { // Just using the default function
			posMin = data.Vector1,
			posMax = data.Vector2,
			playerOnly = data.PlayerOnly or true,
			onEndTouch = function( ply )
				if SERVER then
						TauEx.Funct(ply)
				end
			end
		})
		
	end
end

// Waiting for TAU to load...
timer.Simple( 5, function()
	
	if not tau then
		return // because TAU is not loaded nor installed
	end
	TauEx.LoadData()	// load existing data
	
	if TauEx.DisableDefaultZones then // if DisableDefaultZones = true then
		tau.triggers = {}			// Clear the old data about the old zones
	end
		
	TauEx.SubmitData(Zones) 		// and update it
	
	
	MsgC("TAU Extender successfully inserted\n")
end )

// I just simplyfied this case for me
TauEx.ChatFunctions = {} // i like lua for it tables

// The /tau add command
TauEx.ChatFunctions["add"] = function(ply,chat_arr) 
		
			if ply.TauExData["vec1"] and ply.TauExData["vec2"] then
			ply:ChatPrint("You already have 2 Points! type '/tau reset' to clear the current data!")
			return
			end
		
		if not ply.TauExData["vec2"] then
			if not ply.TauExData["vec1"] then
				ply.TauExData["vec1"] = ply:GetEyeTrace().HitPos
				ply:ChatPrint("Added "..tostring(ply:GetEyeTrace().HitPos))
			else
				ply.TauExData["vec2"] = ply:GetEyeTrace().HitPos
				ply:ChatPrint("Added "..tostring(ply:GetEyeTrace().HitPos))
				ply:ChatPrint("type '/tau save' to save")
			end
		end
		net.Start("update_tau_rendering")
			if ply.TauExData then net.WriteTable({v1 = ply.TauExData["vec1"], v2 = ply.TauExData["vec2"]}) end
		net.Send(ply)
end

// the /tau reset command
TauEx.ChatFunctions["reset"] = function(ply,chat_arr) 
	ply.TauExData = {}
		net.Start("update_tau_rendering")
			net.WriteTable({v1 = nil, v2 = nil})
		net.Send(ply)
		ply:ChatPrint("Tau Data removed.")
end

// the /tau save command
TauEx.ChatFunctions["save"] = function(ply,chat_arr) 
	if ply.TauExData["vec1"] and ply.TauExData["vec2"] then
		local Z =  table.Count(Zones)
			Zones["zone_"..Z] = {
				Vector1 = ply.TauExData["vec1"],
				Vector2 = ply.TauExData["vec2"],
			}
			ply.TauExData = {}
			print("zone_"..Z..": "..util.TableToJSON(Zones["zone_"..Z]))
			TauEx.SaveData(Zones)
			TauEx.SubmitData(Zones)
			
		ply:ChatPrint("Saved Zone: zone_"..Z)
	end
	
end

// the /tau command
TauEx.chatCommand = function( ply, text, public )
    if (string.sub(text, 1, 4) == "/tau") then 
		if not ply:IsSuperAdmin() then 
			ply:ChatPrint("/tau is restricted to SuperAdmins only!")
			return ""
		end
		
		
		ply.TauExData = ply.TauExData or {}
		ChatData = string.Explode( " ", text)
		if not ChatData[2] then
			ply:ChatPrint("Usage: /tau add|reset|save")
			return ""
		end
		TauEx.ChatFunctions[ChatData[2]](ply,ChatData)
		return ""
    end
end
hook.Add( "PlayerSay", "TauExChatCommand", TauEx.chatCommand );