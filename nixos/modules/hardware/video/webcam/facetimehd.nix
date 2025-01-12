{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.hardware.facetimehd;

  kernelPackages = config.boot.kernelPackages;

in

{

  options.hardware.facetimehd.enable = mkEnableOption "facetimehd kernel module";

  config = mkIf cfg.enable {

    boot.kernelModules = [ "facetimehd" ];

    boot.blacklistedKernelModules = [ "bdc_pci" ];

    boot.extraModulePackages = [ kernelPackages.facetimehd ];

    hardware.firmware = [ pkgs.facetimehd-firmware ];

    # unload module during suspend/hibernate as it crashes the whole system
    powerManagement.powerDownCommands = ''
      ${pkgs.kmod}/bin/lsmod | ${pkgs.gnugrep}/bin/grep -q "^facetimehd" && ${pkgs.kmod}/bin/rmmod -f -v facetimehd
    '';

    # and load it back on resume
    powerManagement.resumeCommands = ''
      ${pkgs.kmod}/bin/modprobe -v facetimehd
    '';

  };

}
