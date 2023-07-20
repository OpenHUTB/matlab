

function position=getJTAGChainPosition(boardName)
    switch boardName
    case{'Altera Arria 10 SoC development kit','Xilinx Kintex-7 KC705 development board','Artix-7 35T Arty FPGA evaluation kit','Xilinx Zynq UltraScale+ MPSoC ZCU102 Evaluation Kit'}
        position=1;
    case{'Xilinx Zynq ZC706 evaluation kit','ZedBoard','Altera Cyclone V SoC development kit'}
        position=2;
    case codertarget.internal.getCustomHardwareBoardNamesForSoC
        fpgaParams=soc.internal.getCustomBoardParams(boardName);
        position=fpgaParams.fdevObj.JTAGChainPosition;
    otherwise
        error(message('soc:msgs:unableGetJTAGChainPosition'));
    end

end