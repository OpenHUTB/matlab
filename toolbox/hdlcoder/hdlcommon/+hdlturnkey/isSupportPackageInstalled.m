function isInstalled=isSupportPackageInstalled(spID)





    switch spID

    case 'Xilinx Zynq-7000 EC'






        isInstalled=isequal(exist('axiinterfacelib.slx','file'),4);
    case 'Altera SoC Embedded Coder'

        isInstalled=isequal(exist('codertarget.alterasoc.setup.AlteraSoCFirmwareUpdate','class'),8);

    case 'Xilinx Zynq-7000'

        isInstalled=isequal(exist('hdlturnkey.backend.ModelGenerationZynq','class'),8);
    case 'Altera SoC HDL Coder'

        isInstalled=isequal(exist('hdlturnkey.backend.ModelGenerationAlteraSoc','class'),8);

    case 'Micro FPGA SoC'
        isInstalled=isequal(exist('matlabshared.supportpkg.internal.sppkglegacy.MICRO_FPGA_SOC','class'),8);
    otherwise

        isInstalled=false;
    end

end

