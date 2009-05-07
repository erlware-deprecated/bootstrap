## Faxien bootstrap creation

A bootstrap file contains a fully compiled faxien install for a given architecture. Basically faxien object code is tarred up without ERTS. The script create_bootstrap within this depot among a few other things pulls in ERTS that it finds locally on the target system and includes it in the OS specific bootstrap executable that it creates.  This executable script contains script code to run the installer and a tar of the actual faxien code which the script properly places on the users system.

To create a new bootstraper simply run create_bootstrap.sh and follow directions.
