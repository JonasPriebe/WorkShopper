# WorkShopper
This is a simple script to get the Steam Workshop IDs and their Mod IDs for a collection of mods.
The Usage looks like the following:
```bash
./workshopper.sh <collection_id>
```
Only one workshop collection at a time is supported per command call. \
The collection ID can be at the end of the Steam Collection URL: \
```https://steamcommunity.com/sharedfiles/filedetails/?id=<collection_id>.``` \
The output is a list of the workshop IDs of the mods in the collection. \
If a Workshop Item contains multiple Mod IDs, these will be printed out separately and the user has to 
manually choose the wanted one and remove the rest from the output. \
Sometimes no Mod ID can be parsed out because it is either not in the description or because the mod Author has named 
it differently.