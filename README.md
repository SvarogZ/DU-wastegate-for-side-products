# DU-wastegate-for-side-products
Dual Universe wastegate for side-products: oxygen and hydrogen
<br><br>

This logic requires next equipment:
- main container with a gas
- small intermediate container
- transfer unit constantly pumping the gas from the main container to the small intermediate container
- transfer unit controlled by the script to pump the gas from the small intermediate container to nowhere
<br><br>

**Connection**

main container -> transfer unit -> intermediate container -> transfer unit
<br><br>

**Code**

Copy-paste the code (excluding "FILTER UPDATE" and "FILTER STOP" at the end) to the unit.start


Copy-paste next code to the 'unit.stop'

```-------------------------
-- FILTER STOP ----------
-------------------------
stop()
```
<br><br>

Copy-paste next code to the 'unit.tick(update)'
```-------------------------
-- FILTER UPDATE --------
-------------------------
update()
```
<br><br>

Connect next mandatory equipment to the slots and give appropriate names as shown below:

*Screen* - screen to shown

*MainContainerHydrogen* - this container/hub contains hydrogen

*ContainerHydrogen* - small intermediate container for hydrogen

*HydrogenWasteGate* - transfer unit to waste the hydrogen

*MainContainerOxygen* - this container/hub contains oxygen

*ContainerOxygen* - small intermediate container for oxygen

*OxygenWasteGate* - transfer unit to waste the oxygen
