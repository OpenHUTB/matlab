function[isInstalled,spName]=ishdlzynqspinstalled




    spName='HDL Coder Support Package for Xilinx Zynq Platform';
    spID='Xilinx Zynq-7000';

    isInstalled=hdlturnkey.isSupportPackageInstalled(spID);

end

