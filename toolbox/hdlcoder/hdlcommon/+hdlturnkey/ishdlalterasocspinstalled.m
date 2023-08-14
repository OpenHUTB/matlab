function[isInstalled,spName]=ishdlalterasocspinstalled




    spName='HDL Coder Support Package for Intel SoC Devices';
    spID='Altera SoC HDL Coder';

    isInstalled=hdlturnkey.isSupportPackageInstalled(spID);

end

