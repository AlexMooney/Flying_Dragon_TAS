textY = 96
textHeight = 14

enemy1type = 0x0741
enemy1X = 0x0743
enemy1Y = 0x0742
enemy1phaseduration = 0x074E
enemy1phasecounter = 0x0744
--enemy1phasetimer = 0x02F3
--enemy1hitbymagiccounter = 0x0343
--enemy1hitbyswordcounter = 0x0353

numSprites = 12

spritesLocation = 0x2CC
spritesXstart = 0x00BA
spritesYstart = 0x00C2

spriteSizes = 0xB4DF
spriteWidths = 0xB4D1
spriteHeights = 0xB4D8

deltaWidth = -8
deltaHeight = -24

c = 0

playerHitPoints = 0x0029
enemyHitPoints = 0x002A
playerIFrames = 0x00e9
bossIFrames = 0x048D

itemCounter = 0x043A
globalClock = 0x01C
-- playerBeh = 0x00A4

last = {}

function printText (text, fore, back, dx)
	if dx then
		c = c - 1
	else
		dx = 0
	end
	fore = fore or "white"
	back = back or "black"
	gui.text (10+dx, textY + c * textHeight, text, fore, back)
	c = c + 1
end


while true do
	c = 0

	pX = memory.readbyte (0x0703)
	if (pX > 0) then
		gui.text (68, 39, "HP: " .. memory.readbyte(playerHitPoints) .. "  [" .. math.max(0, memory.readbyte(playerIFrames)*8 - memory.readbyte(globalClock)%8) .. "]", "white")
		gui.text (58, 55, "EHP: " .. memory.readbyte(enemyHitPoints) .. "  [" .. memory.readbyte(bossIFrames) .. "]", "white")

		SX = 0x0100*memory.readbyte(0x0017) + memory.readbyte (0x0016)
		pXfrac = memory.readbyte (0x009D)
		pY = memory.readbyte (0x0702)
		xVel = memory.readbyte (0x00C8)
		inv = memory.readbyte (0x00E9)
		bossInv = memory.readbyte (0x048D)
		pCool = memory.readbyte(0x070E)
		enemies = memory.readbyte(0x048A)
		spawn = memory.readbyte(0x00EB)*8 - memory.readbyte(globalClock)%8
		--glov = memory.readbyte (0x0428)
		--boots = memory.readbyte (0x0429)
		--rng = memory.readbyte (0x00DA)
		--pause = memory.readbyte (0x1A)

		--pausestr = "";
		--if pause % 64 == 0 then
			--pausestr = "UNPAUSE!!!"
		--elseif pause % 64 == 62 then
			--pausestr = "PAUSE!!!"
		--else
			--pausestr = "" .. pause % 64 .. "(" .. pause .. ")"
		--end

		--rngVal = bizstring.binary (memory.readbyte (0x8000 + rng, "System Bus"))

		printText (string.format ("SX: %3d X: %3d [%3d] Y: %3d Vx: %2d cool: %2d kills: %1d", SX, pX, pXfrac, pY, xVel, pCool, enemies))

		if (last["X"]) then
			printText (string.format ("SX: %3d X: %3d [%3d] Y: %3d Vx: %2d", last["SX"], last["X"], last["Xfrac"], last["Y"], last["xVel"]), "gray")
		end

		--beh = memory.readbyte (playerBeh)
		--printText (string.format ("Behaviours: Atk: %d Ldr: %d Jmp: %d Item: %d", bit.band(beh, 128), bit.band(beh, 8), bit.band(beh, 1), memory.readbyte(itemCounter)))
		--printText (string.format ("Ointment: %d, Boots: %d, Frame Counter: %s", oint, boots, pausestr))

		--rock = memory.readbyte(0xD7)
		--if rock > 0 then
			--printText (string.format ("Rock: %d", rock))
		--end

		playerHeight = 32
		playerWidth = 16
		animation = memory.readbyte(0x0704)
		if (animation == 12) then
			playerHeight = 16
		elseif (animation == 8) then
			playerWidth = 36
		elseif (animation == 128 or animation == 129) then
			playerWidth = 36
		end

		gui.drawRectangle (memory.readbyte(0x703) + deltaWidth, memory.readbyte(0x702) + deltaHeight + (32 - playerHeight), playerWidth, playerHeight, "white")

		c = c + 1

	  --printText (string.format ("%2s %3s %10s %3s %3s %3s %3s %4s", "E", "Type", "(  X,   Y)", "P1", "P2", "P3", "Inv", "MInv"))
		printText (string.format ("%2s %4s %10s %3s %3s %6s: %2d", "E", "Type", "(  X,   Y)", "P1", "P2", "Spawn", spawn))
		--printText (string.format ("%2s %4s %10s %3s %3s", "E", "Type", "(  X,   Y)", "P1", "P2"), nil, nil, 300)

		for i = 0, numSprites - 1, 1 do
			type = memory.readbyte (enemy1type + 0x10*i)
			if type > 0 then

				phasedur = memory.readbyte (enemy1phaseduration + 0x10*i)
				phasecount = memory.readbyte (enemy1phasecounter + 0x10*i)
				--phasetimer = memory.readbyte (enemy1phasetimer + 0x10*i)
				--minv = memory.readbyte (enemy1hitbymagiccounter + 0x10*i)
				--inv = memory.readbyte  (enemy1hitbyswordcounter + 0x10*i)
				eX = memory.readbyte(enemy1X + 0x10*i)
				eY = memory.readbyte(enemy1Y + 0x10*i)

				--spriteX = memory.readbyte (spritesXstart + i)
				--spriteY = memory.readbyte (spritesYstart + i)
				--sprite = memory.readbyte (spritesLocation + i)
				--spriteSize = memory.readbyte (spriteSizes + sprite, "System Bus")
				--spriteWidth = memory.readbyte (spriteWidths + spriteSize, "System Bus")
				--spriteHeight = memory.readbyte (spriteHeights + spriteSize, "System Bus")

				printText (string.format ("%2d %4d (%3d, %3d) %3d %3d", i + 1, type, eX, eY, phasedur, phasecount))

				-- Draw hitboxes around enemies
				gui.drawText (eX + deltaWidth+12, eY + deltaHeight, i+1, "white", "black", 10)
				gui.drawRectangle(eX + deltaWidth + 7, eY + deltaHeight, 4, 32, "blue")
			end
		end

		-- Draw useful hitboxes (for cosmic saucers)
		for i = 1, 3, 1 do
			if memory.readbyte(0x0701 + 0x10*i) > 0 then
				hX = memory.readbyte(0x0703 + 0x10*i)
				hY = memory.readbyte(0x0702 + 0x10*i)

				hW = 16
				hH = 1
				gui.drawRectangle (hX + deltaWidth, hY + deltaHeight + 16 + 7, hW, hH, "white")
			end
		end



		last["SX"] = SX
		last["X"] = pX
		last["Xfrac"] = pXfrac
		last["Y"] = pY
		last["xVel"] = xVel
		--last["RNG"] = rng
		--last["RNGVal"] = rngVal
	else -- tournament fight
		gui.text(68, 39, "HP: " .. memory.readbyte(playerHitPoints), "white")
		gui.text(58, 55, "EHP: " .. memory.readbyte(enemyHitPoints), "white")

		pY = memory.readbyte( 0x0682)
		pX = memory.readbyte( 0x0683)
		eY = memory.readbyte( 0x06C2)
		eX = memory.readbyte( 0x06C3)
		potion = memory.readbyte( 0x0780)
		potionX = memory.readbyte( 0x0782)
		potionY = memory.readbyte( 0x0783)

		atkCnt = memory.readbyte( 0x06E7)

		printText(string.format("You   X: %3d Y: %3d", pX, pY))
		printText(string.format("Enemy X: %3d Y: %3d", eX, eY))

		c = c+1
		printText(string.format("Attack Cnt: %2d", atkCnt))
	end
	emu.frameadvance();
end
