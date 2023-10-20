# intro
its filterscript plug and play to use sampvoice (https://github.com/CyberMor/sampvoice) with radio voice and phone voice

# how to install/use

you have to do 3 steps

## step 1 (plugin):
after install the plugin samp voice: https://github.com/CyberMor/sampvoice/releases

```
Download from the releases page the desired version of the plugin for your platform.
Unpack the archive to the root directory of the server.
Add to the server.cfg server configuration file the line "plugins sampvoice" for Win32 and "plugins sampvoice.so" for Linux x86. (If you have a Pawn.RakNet plugin be sure to place SampVoice after it)
```

## step 2 (filterscript):
you have to coppy and paste 
`sampvoice.amx`
`sampvoice.pwn`
into your filterscripts folder

and then add sampvoice into your filterscript line on server.cfg
`filterscripts sampvoice`

## step 3 (small changes on gamemode)
use as reference `gm_code_example`
from: https://github.com/aszarth/sampvoice_phone_and_radio/blob/master/gamemodes/gm_code_example.pwn

and put it in your gamemode so players can switch talk stat to radio/local and connect/disconnect on radio frequencies

# possible incompatibilities

sadly some libs cannot work fine with sampvoice lib their repository is abandoned so i recommend to avoid some libs that could possibly cause conflicts: `#include <Pawn.RakNet>`, some `YSI`
