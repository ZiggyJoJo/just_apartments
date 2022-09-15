# just_apartments
 
Video Demo https://youtu.be/9zb6EJ8KSi8

# Dependencies

- ESX 
- https://github.com/overextended/ox_lib    
- https://github.com/brentN5/bt-polyzone
- https://github.com/HalCroves/mythic_progbar

# Optional Dependencies

- For Apartment Stashes: https://github.com/overextended/ox_inventory
- For Apartment Wardrobe: https://github.com/ZiggyJoJo/brp-fivem-appearance


# Description

Adds apartments that can be rented by players the cost and rent length can be changed by apartment in the SQL along with a starter apartment on Alta Street includes an option to view an apartment before purchasing the ability to give keys to other players along with a stash using OX_Inventory and a wardrobe using BRP Fivem Appearance. I plan to add offices and a shared garage system for those that have keys to the same apartmentalong with any other sugestions I might recieve.


# Setup

1. Ensure any dependancies before the script 
2. Run the SQL file 
3. Add TriggerServerEvent('just_apartments:getLastApartment') after your player spawns in if you use a spawn selector add it for last location option and TriggerServerEvent('just_apartments:updateLastApartment', nil) for any other option to prevent instancing outside of apartments 
