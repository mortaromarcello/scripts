Raccolta di vari scripts.
-----------------------------------------------
create_disk_image.sh: uno script per creare dischi immagine avviabili con syslinux. Accetta come parametri il nome del disco immagine, la dimensione in Mbytes e il path dove montare la partizione creata.

-----------------------------------------------
inst-syslinux.sh: installa syslinux su un disco device. Accetta come parametri il device (/dev/sdx) e il path dove montare la partizione. A richiesta può cancellare il device e ricreare la tabella delle partizioni e la partizione primaria fat32 alla massima dimensione.
-----------------------------------------------
