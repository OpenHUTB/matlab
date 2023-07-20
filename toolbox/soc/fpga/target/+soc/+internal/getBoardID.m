function boardID=getBoardID(boardName)
    switch boardName
    case 'Altera Cyclone V SoC development kit'
        boardID='c5soc';
    case 'Altera Arria 10 SoC development kit'
        boardID='a10soc';
    case 'Xilinx Zynq ZC706 evaluation kit'
        boardID='zc706';
    case 'Xilinx Kintex-7 KC705 development board'
        boardID='kc705';
    case 'ZedBoard'
        boardID='zedboard';
    case 'Artix-7 35T Arty FPGA evaluation kit'
        boardID='arty';
    case 'Xilinx Zynq UltraScale+ MPSoC ZCU102 Evaluation Kit'
        boardID='zcu102';
    otherwise
        boardID=matlab.lang.makeValidName(boardName);
    end
end

