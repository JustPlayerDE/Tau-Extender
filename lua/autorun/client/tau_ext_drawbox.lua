local C = Color(100,100,100)
local V1 = V1 or nil
local V2 = V2 or nil
local enabled = enabled or true
net.Receive("update_tau_rendering",function()
V1 = net.ReadTable()
V2 = V1.v2
V1 = V1.v1
end)

hook.Add( "HUDPaint", "Draw3DBoxWithTauEx", function()
	cam.Start3D()
		if enabled then
			if V1 then
				render.DrawBox( V1, Angle(0,0,0), Vector(-4,-4,-4), Vector(4,4,4),C, true )
			end
			if V2 then
				render.DrawBox( V2, Angle(0,0,0), Vector(-8,-8,-8), Vector(8,8,8),C, true )					
			end
		end
	cam.End3D()
end )