function[isInstalled,spName]=isECoderSPInstalled(spID)




    isInstalled=hdlturnkey.isSupportPackageInstalled(spID);

    switch spID
    case 'Xilinx Zynq-7000 EC'
        spName='Embedded Coder Support Package for Xilinx Zynq Platform';
    case 'Altera SoC Embedded Coder'
        spName='Embedded Coder Support Package for Intel SoC Devices';
    otherwise
        spName='';
    end


end

