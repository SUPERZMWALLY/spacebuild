fluix.modules.BottomPanel = { Enabled = true }
fluix.PlayerHealth, fluix.HealthS, fluix.PlayerArmor, fluix.ArmorS = 0, 0, 0, 0
fluix.Ammo1, fluix.Ammo1S, fluix.Ammo1Total, fluix.Ammo1Max, fluix.Ammo2 = 0, 0, 0, 0, 0
fluix.Weapon = LocalPlayer()
fluix.WeaponTable = { }
fluix.WeaponS = 0


--========================================Draw a bar indicator======================================================
local drawBarIndicator = function ( PosX, PosY, SizeX, SizeY, Value, Max, bg_color, value_color )
    PosX, PosY = PosX * math.Clamp(fluix.Smooth+0.4,0,1), PosY --* fluix.Smooth
    SizeX, SizeY = SizeX * math.Clamp(fluix.Smooth+0.4,0,1), SizeY --* fluix.Smooth
    Value = Value * fluix.Smooth2

    --[[bg_color.a = bg_color.a * fluix.Smooth
    surface.SetDrawColor( bg_color )
    surface.DrawRect( PosX, PosY, SizeX, SizeY )  ]]

    --[[bg_color = fluix.ColorNegate( bg_color )
    local old_alpha = bg_color.a
    bg_color.a = 255 * fluix.Smooth ]]
    bg_color.a = bg_color.a * fluix.Smooth
    value_color.a = value_color.a * fluix.Smooth

    --bg_color.a = old_alpha
    surface.SetDrawColor( value_color )           -- Outline of Background of the bar
    surface.DrawOutlinedRect( PosX + SizeX * 0.05, PosY + SizeY * 0.2, SizeX * 0.9, SizeY * 0.4 )

    surface.SetDrawColor( bg_color )        -- Background of Bar
    surface.DrawRect( PosX + SizeX * 0.05, PosY + SizeY * 0.2, SizeX * 0.9, SizeY * 0.4 )

    --value_color.a = value_color.a * fluix.Smooth
    surface.SetDrawColor( value_color )          --Value of Bar
    surface.DrawRect( PosX + SizeX * 0.05, PosY + SizeY * 0.2, SizeX * ( Value / Max ) * 0.9, SizeY * 0.4 )


end


--======================================== Display Ammo ======================================================

local drawAmmo = function (PosX,PosY,SizeX,SizeY, bg_color, value_color)

    drawBarIndicator( PosX, PosY, SizeX, SizeY, math.Clamp( fluix.Ammo1S * fluix.WeaponS, 0, fluix.Ammo1Max ), fluix.Ammo1Max, bg_color, value_color )


    fluix.DrawText( PosX, PosY + SizeY * 0.85, SizeX, string.Right(
        string.format( "Ammo: %i Total: %i", math.Round( fluix.Ammo1S ) * fluix.Smooth2, fluix.Ammo1Total * fluix.Smooth2 ), SizeX / 8 ), value_color )

    PosY = PosY + SizeY                 --ALT AMMO?
    fluix.DrawText( PosX, PosY + SizeY * 0.5, SizeX, string.Right( string.format( "Alt: %i", fluix.Ammo2 ), SizeX / 12 ), value_color, "Default" )


end


--=================================================================================================================

function fluix.modules.BottomPanel.Run( )
	local SizeX, SizeY = 200, 48
    local SizeY2 = SizeY + SizeY/4 -- Height of 1 section.
    local PosX, PosY = 16, (ScrH() - SizeY2*2) - 20

	--Check if player is alive.
	if LocalPlayer():Alive() then
		fluix.PlayerHealth = LocalPlayer():Health()
		fluix.PlayerArmor = LocalPlayer():Armor()
	end
	
	
	--Draw Health bar.
	fluix.HealthS = fluix.Smoother( fluix.PlayerHealth, fluix.HealthS, 0.15 )

    local SizeY = SizeY2

    local value_color = Color( 255, 255, 255, 240 )
    local bg_color = Color( 50,50,50,220)
	drawBarIndicator( PosX, PosY, SizeX, SizeY, math.Clamp( fluix.HealthS, 0, 100 ), 100, bg_color, value_color )

    local SizeY = SizeY - SizeY/8 -- Place text in middle of this new gap
	fluix.DrawText( PosX, PosY + SizeY, SizeX, string.format( "Health: %i%s", math.Round( fluix.HealthS ) * fluix.Smooth2, "%" ), value_color )

    local SizeY = SizeY2 -- Restore variable to height of health bar for next armour section.

	--Draw Armor bar.
	PosY = PosY + SizeY
	fluix.ArmorS = fluix.Smoother( fluix.PlayerArmor, fluix.ArmorS, 0.15 )

    local value_color = Color( 255, 255, 255, 240 )
    local bg_color = Color( 50,50,50,220)
	drawBarIndicator( PosX, PosY, SizeX, SizeY, math.Clamp( fluix.ArmorS, 0, 100 ), 100, bg_color, value_color )

    local SizeY = SizeY - SizeY/8 -- Place text in middle of this new gap
	fluix.DrawText( PosX, PosY + SizeY, SizeX, string.format( "Armor: %i%s", math.Round( fluix.ArmorS ) * fluix.Smooth2, "%" ), value_color )
	
	
	
	--Draw primary ammo bar.
	PosX, PosY = ScrW() - 216, ScrH() - 144 --Absolute values as SizeX varies with ammo, and can't be calculated previously.
	
	--Check if the weapon is valid.
	fluix.Weapon = LocalPlayer():GetActiveWeapon()
	fluix.Ammo1Total = fluix.Weapon:IsValid() and LocalPlayer():GetAmmoCount( fluix.Weapon:GetPrimaryAmmoType() ) or 0
	if fluix.Weapon:IsValid() and fluix.WeaponS >= 1 then
		
		fluix.Ammo1 = fluix.Weapon:Clip1() or 0
		--Check if weapon has ammo
		if fluix.Ammo1 > 0 then
			
			--Add weapon's maximum ammo to the table.
			if not fluix.WeaponTable[ fluix.Weapon:GetClass() ] then
				fluix.WeaponTable[ fluix.Weapon:GetClass() ] = 1
			elseif fluix.Ammo1 > fluix.WeaponTable[ fluix.Weapon:GetClass() ] then
				fluix.WeaponTable[ fluix.Weapon:GetClass() ] = fluix.Ammo1
			end
			
			fluix.Ammo1Max = fluix.WeaponTable[ fluix.Weapon:GetClass() ]
			
			fluix.Ammo2 = fluix.Weapon:GetSecondaryAmmoType() and LocalPlayer():GetAmmoCount( fluix.Weapon:GetSecondaryAmmoType() ) or 0
		elseif fluix.Ammo1Total > 0 then
			fluix.Ammo1 = 0
		end
		
		fluix.Ammo1S = fluix.Smoother( fluix.Ammo1, fluix.Ammo1S, 0.15 )
	elseif fluix.Weapon:IsValid() and ( fluix.Weapon:Clip1() > 0 or fluix.Ammo1Total > 0 ) then
		fluix.Ammo1S = 0.15
	end
	
	
	
	--Controller for showing the ammo bar.
	if ( fluix.Ammo1Total > 0 or fluix.Ammo1S > 0.1 ) and fluix.WeaponS < 1 and fluix.Smooth >= 1 then
		fluix.WeaponS = fluix.Smoother( 1.1, fluix.WeaponS, 0.15 )
	elseif fluix.Ammo1Total <= 0 and fluix.Ammo1S <= 0.1 and fluix.WeaponS > 0 then
		fluix.WeaponS = fluix.Smoother( -0.1, fluix.WeaponS, 0.15 )
	elseif fluix.WeaponS > 1 then
		fluix.WeaponS = 1
	elseif fluix.WeaponS < 0 then
		fluix.WeaponS = 0
	end
	
	--Shows the ammo bar.
	if fluix.WeaponS > 0 then
		SizeX = SizeX * fluix.WeaponS --THIS IS A BLOODY SMOOTHER
        local value_color = Color( 255, 255, 255, 240 )
        local bg_color = Color( 50,50,50,220)

        value_color.a = value_color.a * fluix.WeaponS
        bg_color.a = value_color.a * fluix.WeaponS

        drawAmmo(PosX,PosY,SizeX,SizeY,bg_color,value_color)

	end
	
end