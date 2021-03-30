-------------------------
-- USER DEFINED DATA ----
-------------------------
local hydrogen_level = 4 --export
local oxygen_level = 4 --export
local font_size = 6 --export
local font_color = "black" --export
local screen_color = "#979A9A" --export
local row_color_1 = "#ECF0F1" --export
local row_color_2 = "#D0D3D4" --export
local low_low_level = 2 --export
local low_low_level_color = "#922B21" --export
local low_level = 3 --export
local low_level_color = "#F1C40F" --export
local normal_level_color = "#229954" --export
local high_level = 10 --export
local high_level_color = "F1C40F" --export
local high_high_level = 50 --export
local high_high_level_color = "#922B21" --export
local update_time = 1 --export
local indicator_color = "#229954" --export
local container_size = 153600 --export: temporary


-------------------------
-- AUXILIARY FUNCTIONS --
-------------------------	
local sformat = string.format

local function round(value, precision)
	if precision then return round(value / precision) * precision end
	return value >= 0 and math.floor(value+0.5) or math.ceil(value-0.5)
end

local function format_number(n)
	if n < 1000 then
		return math.floor(n + 0.5)
	elseif n < 1000000 then
		return math.floor(n/10 + 0.5)/100 .."k"
	else
		return math.floor(n/10000 + 0.5)/100 .."M"
	end
end

local function getColor(number, lll, ll, hl, hhl)
	local low_low_level = lll or low_low_level
	local low_level = ll or low_level
	local high_level = hl or high_level
	local high_high_level = hhl or high_high_level
	
	if number < low_low_level then
		return low_low_level_color
	elseif number < low_level then
		return low_level_color
	elseif number > high_high_level then
		return high_high_level_color
	elseif number > high_level then
		return high_level_color
	else
		return normal_level_color
	end
end


-------------------------
-- HTML -----------------
-------------------------
local htmlMessageTemplate = [[<div style="height: 100vh;width: 100vw;color:]]..font_color..[[;font-size: 10vw;display:flex;justify-content:center;align-items:center;background-color:]]..screen_color..[[;">%s</div>]]

local html_head = [[<style>
	div.table {
		font-family:"Lucinda Sans";
		border-collapse: collapse;
		background-color:]]..screen_color..[[;
		width:100vw;
		height:100vh;
	}
	div.cell {
		position:absolute;
		height:12.5vh;
		width:45vw;
		display:flex;
		color:]]..font_color..[[;
		font-size:6vw;
	}
	div.name {
		width:24vw;
		height:10.5vh;
		display:flex;
		align-items:center;
		font-size:]]..font_size..[[vh;
	}
	div.number {
		position:absolute;
		right:0;
		width:19vw;
		height:5vh;
		display:flex;
		flex-direction:row-reverse;
		align-items:center;
		font-size:]]..font_size..[[vh;
	}
	div.percent {
		position:absolute;
		right:0;
		bottom:2vh;
		width:15vw;
		height:5vh;
		display:flex;
		align-items:center;
		font-size:]]..font_size..[[vh;
	}
	div.progress {
		position:absolute;
		bottom:0;
		height:2vh;
	}
	div.indicator {
		position:absolute;
		width:3vw;
		height:2vh;
	}
	div.status {
		position:absolute;
		height: 20vh;
		width: 45vw;
		color:]]..font_color..[[;
		font-size:]]..font_size..[[vh;
		display:flex;
		align-items:center;
		background-color:]]..row_color_2..[[;
	}
</style>
]]


-------------------------
-- SCRIPT STOPPED ------
-------------------------
function stop()
	Screen.setHTML(sformat(htmlMessageTemplate,'Script Stopped'))
end


-------------------------
-- UPDATE FUNCTION ------
-------------------------
local indicator_color_current = indicator_color

local function wasteGate(mainContainerSlot,wasteContainerSlot,transferSlot,level)
	if mainContainerSlot.getItemsVolume()/container_size > level/100 then	 
		if wasteContainerSlot.getItemsVolume()/wasteContainerSlot.getMaxVolume() > 0.99 then
			--system.print(transferSlot.getStatus())
			if transferSlot.getStatus() == "STOPPED" and transferSlot.getStatus() ~= "RUNNING" then
				--system.print("start")
				transferSlot.start()
			else
				--system.print("hard stop")
				transferSlot.hardStop(1)
			end
		end
		return "Wastegate in operation!"
	elseif transferSlot.getStatus() ~= "STOPPED" then
		--system.print("Stop")
		transferSlot.hardStop(1)
		return "Wastegate is stopping..."
	else
		return "Standby mode..."
	end
end

function update()
	if not MainContainerHydrogen
		or not ContainerHydrogen
		or not HydrogenWasteGate
		or not MainContainerOxygen
		or not ContainerOxygen
		or not OxygenWasteGate
		then
		local text = "No Equipment Detected \n Check distance to equipment"
		if Screen then
			Screen.setHTML(sformat(htmlMessageTemplate,text))
		end
		system.print(text)
		return
	end

	if indicator_color_current == indicator_color then indicator_color_current = screen_color else indicator_color_current = indicator_color end
	--system.print(indicator_color_current)  
	local hydrogen_status = wasteGate(MainContainerHydrogen,ContainerHydrogen,HydrogenWasteGate,hydrogen_level)
	local oxygen_status = wasteGate(MainContainerOxygen,ContainerOxygen,OxygenWasteGate,oxygen_level)
	
	local hydrogen_volume = MainContainerHydrogen.getItemsVolume()
	local oxygen_volume = MainContainerOxygen.getItemsVolume()
	local hydrogen_percent = round(hydrogen_volume/container_size*100,0.1)
	local oxygen_percent = round(oxygen_volume/container_size*100,0.1)
	local hydrogen_color = getColor(hydrogen_percent, low_low_level, low_level, high_level, high_high_level)
	local oxygen_color = getColor(oxygen_percent, low_low_level, low_level, high_level, high_high_level)
	local number_hydrogen = format_number(hydrogen_volume)
	local number_oxygen = format_number(oxygen_volume)
	
	Screen.setHTML(html_head
		..[[
<div class="table">
	<div class="cell" style="left:3vw;background-color:]]..row_color_1..[[;">
		<div class="name">Hydrogen</div>
		<div class="number" align="right">]]..number_hydrogen..[[</div>
		<div class="percent">]]..hydrogen_percent..[[%</div>
		<div class="progress" style="width:]]..hydrogen_percent..[[%;background-color:]]..hydrogen_color..[[;"></div>
	</div>
	<div class="cell" style="left:55vw;background-color:]]..row_color_1..[[;">
		<div class="name">Hydrogen</div>
		<div class="number" align="right">]]..number_oxygen..[[</div>
		<div class="percent">]]..oxygen_percent..[[%</div>
		<div class="progress" style="width:]]..oxygen_percent..[[%;background-color:]]..oxygen_color..[[;"></div>
	</div>
	<div class="status" style="top:12.5vh;left:3vw;">]]..hydrogen_status..[[</div>
	<div class="status" style="top:12.5vh;left:55vw;">]]..oxygen_status..[[</div>
	<div class="indicator" style="background-color:]]..indicator_color_current..[[;"></div>
</div>]])
end


-------------------------
-- CHECK SLOTS ----------
-------------------------
local function checkSlots()

	local function getSlotError(slot,slotClass,slotName)
		local text = ""
		if not slot then
			text = text.."'"..slotName.."' is not defined!\n"
		elseif not slot.getElementClass then
			text = text.."'getElementClass()' does not exist for '"..slotName.."'\n"
		elseif slot.getElementClass():lower() ~= slotClass then
			text = text.."'"..slotName.."' must be '"..slotClass.."'\n"
		end
		--system.print('slotName = '..slot.getElementClass():lower())
		return text
	end

	local text = getSlotError(Screen,'screenunit','Screen')
		..getSlotError(MainContainerHydrogen,'itemcontainer','MainContainerHydrogen')
		..getSlotError(ContainerHydrogen,'itemcontainer','ContainerHydrogen')
		..getSlotError(HydrogenWasteGate,'industryunit','HydrogenWasteGate')
		..getSlotError(MainContainerOxygen,'itemcontainer','MainContainerOxygen')
		..getSlotError(ContainerOxygen,'itemcontainer','ContainerOxygen')
		..getSlotError(OxygenWasteGate,'industryunit','OxygenWasteGate')

	if text ~= "" then
		error(text)
	end
end

-------------------------
-- CODE -----------------
-------------------------
checkSlots()

Screen.setHTML(sformat(htmlMessageTemplate,'Processing...'))

unit.setTimer("update", update_time)



-------------------------
-- FILTER UPDATE --------
-------------------------
update()



-------------------------
-- FILTER STOP ----------
-------------------------
stop()
