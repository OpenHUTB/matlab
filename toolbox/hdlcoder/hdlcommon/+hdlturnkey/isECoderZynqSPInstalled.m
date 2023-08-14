function[isInstalled,spName]=isECoderZynqSPInstalled()




    eCoderSPID='Xilinx Zynq-7000 EC';
    [isInstalled,spName]=hdlturnkey.isECoderSPInstalled(eCoderSPID);

end

