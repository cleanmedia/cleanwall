# Mainboard

Qotom J190G4 is supported.

The reason not to use router platforms from Atheros or TP-Link is, that every few month (and in unpredictable intervals) they come with new hardware revisions not compatible to the old linux firmware! The time spent to fix those issues is about 10 to 100 times more expensive, than the added cost of the Qotom box. And as soon as they offer comparable performance, they also approach the price target or bypass it. Last but not least the Qotom is a true firewall platform having on each of it's 4 Ethernet ports it's own controller chip - not just a switch.


# Peripherals

- 4GB RAM
- mSATA SSD 16GB
- MiniPCIe with USB signaling (Ralink RT3070)


# Wifi

The Wifi offered by Qotom is the only card supported and that current (linux) firmwares allow to be used in b/g modes only.
No Wifi n mode is supported by linux firmware.

Better AP mode is possible using an external AP (not currently supported by cleanwall).

The reason not to support external AP is the amount of cabling needed in home environments.


# UEFI

The Qotom EFI does fully support EFI modes. Same for debian and cleanwall. However switching the SSD - mixing those modes including GPT and MBR partitioning could cause the originally installed cleanwall SSD to not boot at all. That's the only reason for removing any partitions before letting debian installer do it's work - and to use all CSM / legacy modes.


