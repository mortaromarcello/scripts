Raccolta di vari scripts.
-----------------------------------------------
create_disk_image.sh: uno script per creare dischi immagine avviabili con syslinux. Accetta come parametri il nome del disco immagine, la dimensione in Mbytes e il path dove montare la partizione creata.

inst-syslinux.sh: installa syslinux su un disco device. Accetta come parametri il device (/dev/sdx) e il path dove montare la partizione. A richiesta può cancellare il device e ricreare la tabella delle partizioni e la partizione primaria fat32 alla massima dimensione.

qemu_launcher.sh: lancia qemu con la particolare caratteristica di bootare da un dispositivo usb identificato dal suo numero di identificazione (si legge con il comando lsusb). Accetta come parametri il nome del disco immagine e il numero identificativo del dispositivo usb.
