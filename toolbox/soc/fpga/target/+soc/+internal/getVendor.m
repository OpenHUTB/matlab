function vendor=getVendor(sys)
    if isa(sys,'ioplayback.hardware.Base')
        board=sys.BoardName;
    else
        board=soc.internal.getHardwareBoard(sys);
    end

    switch board
    case{'Altera Arria 10 SoC development kit','Altera Cyclone V SoC development kit'}
        vendor='Intel';
    case{...
        'Xilinx Zynq ZC706 evaluation kit',...
        'Xilinx Kintex-7 KC705 development board',...
        'ZedBoard',...
        'Artix-7 35T Arty FPGA evaluation kit',...
'Xilinx Zynq UltraScale+ MPSoC ZCU102 Evaluation Kit'...
        }
        vendor='Xilinx';
    case codertarget.internal.getCustomHardwareBoardNamesForSoC
        fpgaParams=soc.internal.getCustomBoardParams(board);
        if~isempty(fpgaParams)
            vendor=fpgaParams.fdevObj.FPGAVendor;
        else
            vendor=board;
        end
    case codertarget.targethardware.getSupportedHardwareBoardsForID(codertarget.targethardware.BaseProductID.SOC)
        vendor=board;
    otherwise
        error(message('soc:msgs:BoardNotSupported',board));
    end
end


