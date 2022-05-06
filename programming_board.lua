-------------------------
-- USER DEFINED DATA ----
-------------------------
local update_time = 1 --export

-------------------------
-- VARIABLES ------------
-------------------------
local is_all_slots_connected = false
local hydrogen_level
local oxygen_level
local indicator_status = 0

-------------------------
-- SLOTS ALLOCATION -----
-------------------------
local Screen = Slot1
local MainContainerHydrogen = Slot2
local ContainerHydrogen = Slot3
local HydrogenWasteGate = Slot4
local MainContainerOxygen = Slot5
local ContainerOxygen = Slot6
local OxygenWasteGate = Slot7

-------------------------
-- AUXILIARY FUNCTIONS --
-------------------------
local function round(value, precision)
	if precision then return round(value / precision) * precision end
	return value >= 0 and math.floor(value+0.5) or math.ceil(value-0.5)
end

local function printErrorMessage(text, screen)
	system.print(text)
	if screen and screen.setScriptInput then
		local data_to_send{}
		data_to_send.error = text
		screen.setScriptInput(json.encode(data_to_send))
	end
end

local function getDataFromScreens(screen)
	if screen and screen.getScriptOutput then
		local data_from_screen = json.decode(screen.getScriptOutput())
		hydrogen_level = data_from_screen[1]
		oxygen_level = data_from_screen[2]
		if not hydrogen_level or not oxygen_level then
			printErrorMessage("Levels from the screen are not received", Screen)
			return false
		end
		return true
	end
	return false
end

-------------------------
-- CHECK SLOTS ----------
-------------------------
local function checkSlots()
	
	if is_all_slots_connected then
		if not MainContainerHydrogen or not MainContainerHydrogen.getItemsVolume
			or not ContainerHydrogen or not ContainerHydrogen.getItemsVolume
			or not HydrogenWasteGate
			or not MainContainerOxygen or not MainContainerOxygen.getItemsVolume
			or not ContainerOxygen or not ContainerOxygen.getItemsVolume
			or not OxygenWasteGate
			then
			local text = "No equipment detected!\n Check the distance to the equipment"
			printErrorMessage(text, Screen)
			unit.exit()
		end
		
		if not hydrogen_level or not oxygen_level then
			if not getDataFromScreens(Screen) then
				return false
			end
		end
		
		return true
	end
	
	local function getSlotError(slot,slotClass,slotName)
		if not slot then
			local text = "Connect "..slotName.." to the programming board."
			printErrorMessage(text, Screen)
			return false
		end
		
		if not slot.getElementClass or slot.getElementClass():lower() ~= slotClass then
			local text = "Disconnect last element. This is not a "..slotName.."."
			printErrorMessage(text, Screen)
			return false
		end
		
		system.print(slotName.." connected.")
		return true
	end
	
	if getSlotError(Screen,'screenunit','Screen')
		and getSlotError(MainContainerHydrogen,'itemcontainer','Main container for Hydrogen')
		and getSlotError(ContainerHydrogen,'containersmallgroup','Wastegate Container for Hydrogen')
		and getSlotError(HydrogenWasteGate,'industryunit','TU for Hydrogen')
		and getSlotError(MainContainerOxygen,'itemcontainer','Main container for Oxygen')
		and getSlotError(ContainerOxygen,'containersmallgroup','Wastegate Container for Oxygen')
		and getSlotError(OxygenWasteGate,'industryunit','TU for Oxygen')
		then
		is_all_slots_connected = true
		
		if not hydrogen_level or not oxygen_level then
			if not getDataFromScreens(Screen) then
				return false
			end
		end
		
		return true
	else
		return false
	end
end

-------------------------
-- UPDATE FUNCTION ------
-------------------------
local function wasteGate(mainContainerSlot,wasteContainerSlot,transferSlot,level)
	if mainContainerSlot.getItemsVolume() > level then	 
		if wasteContainerSlot.getItemsVolume()/wasteContainerSlot.getMaxVolume() > 0.99 then
			--system.print(transferSlot.getStatus())
			if transferSlot.getStatus() == "STOPPED" then
				--system.print("start")
				transferSlot.start()
			else
				--system.print("hard stop")
				transferSlot.hardStop(1)
			end
		end
		return 1 -- wastegate in operation
	elseif transferSlot.getStatus() == "STOPPED" then
		return 0 -- wastegate is stopping
	else
		--system.print("stop")
		transferSlot.hardStop(1)
		return 2 -- wastegate is stopped
	end
end

function update()
	if not checkSlots() then return end
	
	local data_to_send = {}
	
	local oxygen_status = wasteGate(MainContainerOxygen,ContainerOxygen,OxygenWasteGate,oxygen_level)
	data_to_send[1] = oxygen_status
	
	local hydrogen_status = wasteGate(MainContainerHydrogen,ContainerHydrogen,HydrogenWasteGate,hydrogen_level)
	data_to_send[2] = hydrogen_status
	
	local oxygen_volume = MainContainerOxygen.getItemsVolume()
	data_to_send[3] = round(oxygen_volume)
	
	local hydrogen_volume = MainContainerHydrogen.getItemsVolume()
	data_to_send[4] = round(hydrogen_volume)
	
	if indicator_status == true then indicator_status = false else indicator_status = true end
	data_to_send[5] = indicator_status
	--system.print(indicator_status)  

	Screen.setScriptInput(json.encode(data_to_send))
end

-------------------------
-- SCRIPT STOPPED ------
-------------------------
function stop()
	printErrorMessage("Script Stopped", Screen)
end


-------------------------
-- CODE -----------------
-------------------------
checkSlots()
unit.setTimer("update", update_time)


-------------------------
-- FILTER UPDATE --------
-------------------------
update()


-------------------------
-- FILTER STOP ----------
-------------------------
stop()
