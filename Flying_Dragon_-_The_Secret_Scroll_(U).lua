textY = 128
textHeight = 12

enemy8health = 0x034B
enemy8sprite = 0x02D3
enemy8phaseduration = 0x036B
enemy8phasecounter = 0x02EB
enemy8phasetimer = 0x02F3
enemy8hitbymagiccounter = 0x0343
enemy8hitbyswordcounter = 0x0353

numSprites = 8

spritesLocation = 0x2CC
spritesXstart = 0x00BA
spritesYstart = 0x00C2

spriteSizes = 0xB4DF
spriteWidths = 0xB4D1
spriteHeights = 0xB4D8

infoHeight = 0x20

c = 0

magicCostOffset = 0xB7A9
selectedMagic = 0x03C0
manaPoints = 0x039A
hitPointsFull = 0x0431
hitPointsFrac = 0x0432

itemCounter = 0x043A
playerBeh = 0x00A4

last = {}

function printText (text, fore, back)
	fore = fore or "white"
	back = back or "black"
	gui.text (10, textY + c * textHeight, text, fore, back)
	c = c + 1
end


while true do
	c = 0

	if memory.readbyte(selectedMagic) < 255 then
		mp = memory.readbyte (manaPoints)
		mpCost = memory.readbyte (magicCostOffset + memory.readbyte(selectedMagic), "System Bus")
		manaText = string.format ("MP: %d [%d]", mp, mp / mpCost)
	else
		manaText = string.format ("MP: %d", memory.readbyte(manaPoints))
	end

	gui.text (80, 32, manaText, "white")
	gui.text (80, 60, "HP: " .. memory.readbyte(hitPointsFull) .. " [" .. memory.readbyte(hitPointsFrac) .. "]", "white")

	printText (string.format ("%2s %3s %10s %3s %3s %3s %3s %4s", "E", "HP", "(  X,   Y)", "P1", "P2", "P3", "Inv", "MInv"))

	for i = 0, numSprites - 1, 1 do
		health = memory.readbyte (enemy8health - i)
		phasedur = memory.readbyte (enemy8phaseduration - i)
		phasecount = memory.readbyte (enemy8phasecounter - i)
		phasetimer = memory.readbyte (enemy8phasetimer - i)
		minv = memory.readbyte (enemy8hitbymagiccounter - i)
		inv = memory.readbyte  (enemy8hitbyswordcounter - i)
		eX = memory.readbyte(spritesXstart + (numSprites - i - 1))
		eY = memory.readbyte(spritesYstart + (numSprites - i - 1))

		spriteX = memory.readbyte (spritesXstart + i)
		spriteY = memory.readbyte (spritesYstart + i)
		sprite = memory.readbyte (spritesLocation + i)
		spriteSize = memory.readbyte (spriteSizes + sprite, "System Bus")
		spriteWidth = memory.readbyte (spriteWidths + spriteSize, "System Bus")
		spriteHeight = memory.readbyte (spriteHeights + spriteSize, "System Bus")

		printText (string.format ("%2d %3d (%3d, %3d) %3d %3d %3d %3d %4d", numSprites - i, health, eX, eY, phasedur, phasecount, phasetimer, inv, minv))

		-- Draw hitboxes around most enemies
		if spriteX > 0 and spriteY > 0 then
			gui.drawText (spriteX, spriteY + infoHeight, i + 1, "white", "black", 10)
			gui.drawRectangle(spriteX, spriteY + infoHeight, spriteWidth, spriteHeight, "blue")
		end
	end

	-- Draw useful hitboxes (for NPCs)
	hX = memory.readbyte (0x03E2)
	hY = memory.readbyte (0x03E3)
	hW = memory.readbyte (0x03E4)
	hH = memory.readbyte (0x03E5)
	if hX > 0 and hY > 0 then
		gui.drawRectangle (hX, hY + infoHeight, hW, hH, "white")
	end

	if c > 0 then
		c = c + 1
	end

	pX = memory.readbyte (0x009E)
	pXfrac = memory.readbyte (0x009D)
	pY = memory.readbyte (0x00A1)
	xVel = memory.read_s16_le (0x00A9)
	inv = memory.readbyte (0x00AD)
	oint = memory.readbyte (0x0427)
	glov = memory.readbyte (0x0428)
	boots = memory.readbyte (0x0429)
	rng = memory.readbyte (0x00DA)
	pause = memory.readbyte (0x1A)

	pausestr = "";
	if pause % 64 == 0 then
		pausestr = "UNPAUSE!!!"
	elseif pause % 64 == 62 then
		pausestr = "PAUSE!!!"
	else
		pausestr = "" .. pause % 64 .. "(" .. pause .. ")"
	end

	rngVal = bizstring.binary (memory.readbyte (0x8000 + rng, "System Bus"))

	printText (string.format ("X: %3d [%3d] Y: %3d S: %3d I: %2d RNG: %3d [0b%s]", pX, pXfrac, pY, xVel, inv, rng, rngVal))

	if (last["X"]) then
		printText (string.format ("X: %3d [%3d] Y: %3d S: %3d       RNG: %3d [0b%s]", last["X"], last["Xfrac"], last["Y"], last["Vel"], last["RNG"], last["RNGVal"]), "gray")
	end

	beh = memory.readbyte (playerBeh)
	printText (string.format ("Behaviours: Atk: %d Ldr: %d Jmp: %d Item: %d", bit.band(beh, 128), bit.band(beh, 8), bit.band(beh, 1), memory.readbyte(itemCounter)))
	printText (string.format ("Ointment: %d, Boots: %d, Frame Counter: %s", oint, boots, pausestr))

	rock = memory.readbyte(0xD7)
	if rock > 0 then
		printText (string.format ("Rock: %d", rock))
	end

	gui.drawRectangle (memory.readbyte(0x009E), memory.readbyte(0x00A1) + infoHeight, 16, 32, "white")

	emu.frameadvance();

	last["X"] = pX
	last["Xfrac"] = pXfrac
	last["Y"] = pY
	last["Vel"] = xVel
	last["RNG"] = rng
	last["RNGVal"] = rngVal
end
