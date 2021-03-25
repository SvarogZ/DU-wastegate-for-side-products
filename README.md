# DU-wastegate-for-side-products
Dual Universe wastegate for side-products: oxygen and hydrogen

This logic requires next equipment:
- main container with a gas
- small intermediate container
- transfer unit constantly pumping the gas from the main container to the small intermediate container
- transfer unit controlled by the script to pump the gas from the small intermediate container to nowhere

**Connection**

main container -> transfer unit -> intermediate container -> transfer unit
<br><br>

**Code**

Copy-paste the code (excluding "FILTER UPDATE" and "FILTER STOP" at the end) to the unit.start


Copy-paste next code to the 'unit.stop'

```
-------------------------
-- FILTER STOP ----------
-------------------------
stop()
```

Copy-paste next code to the 'unit.tick(update)'
```
-------------------------
-- FILTER UPDATE --------
-------------------------
update()
```

Connect next mandatory equipment to the slots and give appropriate names as shown below:

*Screen* - screen to shown

*MainContainerHydrogen* - this container/hub contains hydrogen

*ContainerHydrogen* - small intermediate container for hydrogen

*HydrogenWasteGate* - transfer unit to waste the hydrogen

*MainContainerOxygen* - this container/hub contains oxygen

*ContainerOxygen* - small intermediate container for oxygen

*OxygenWasteGate* - transfer unit to waste the oxygen

As far as the container hub does not return max volume, set your hub volume 'container_size' via Lua parameters.

**How to start the Programming Board**

You can use any logic you want

```
Zone Detector -> OR
OR -> Relay
Relay -> Programming Board
Relay -> AND
AND -> OR
Button -> NOT
NOT -> AND
```

The Button is required to reset the logic in some cases.
