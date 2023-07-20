function boardName=getBoardName(boardID)
    switch boardID
    case 'c5soc'
        boardName='Altera Cyclone V SoC development kit';
    case 'a10soc'
        boardName='Altera Arria 10 SoC development kit';
    case 'zc706'
        boardName='Xilinx Zynq ZC706 evaluation kit';
    case 'kc705'
        boardName='Xilinx Kintex-7 KC705 development board';
    case 'zedboard'
        boardName='ZedBoard';
    case 'arty'
        boardName='Artix-7 35T Arty FPGA evaluation kit';
    case 'zcu102'
        boardName='Xilinx Zynq UltraScale+ MPSoC ZCU102 Evaluation Kit';
    case 'zcu111'
        boardName='Xilinx Zynq UltraScale+ RFSoC ZCU111 Evaluation Kit';
    case 'zcu216'
        boardName='Xilinx Zynq UltraScale+ RFSoC ZCU216 Evaluation Kit';
    case 'zcu208'
        boardName='Xilinx Zynq UltraScale+ RFSoC ZCU208 Evaluation Kit';

    case 'custom'
        boardName='Custom Hardware Board';

    otherwise
        error(message('soc:msgs:unableGetBoardName'));
    end
end