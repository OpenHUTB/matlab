function[isInstalled,spName]=ishdlmicrochipspinstalled




    spName='HDL Coder Support Package for Microchip FPGA and SoC Devices';
    spID='Micro FPGA SoC';

    isInstalled=hdlturnkey.isSupportPackageInstalled(spID);

end

