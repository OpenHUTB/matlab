function[out,baseProductForSpPkg]=isSpPkgInstalledForSelectedBoard(hCS,selectedBoard)










    out=false;
    baseProductForSpPkg='';
    try
        registeredTargetHW=...
        codertarget.targethardware.getRegisteredTargetHardwareNames;
        if ismember(selectedBoard,registeredTargetHW)
            out=true;
        end

        if~isequal(exist('esb_task','file'),3)

            return;
        end

        soCSupportedTgtHw=getBoardsSupportedWithECAndSoC();
        if~ismember(selectedBoard,soCSupportedTgtHw)
            return;
        end

        if codertarget.utils.isMdlConfiguredForSoC(hCS)
            product='soc';
            baseProductForSpPkg='SoC Blockset support for ';
        else
            product='ec';
            baseProductForSpPkg='Embedded Coder support package for ';
        end

        installedHWBoards=codertarget.internal.getHardwareBoardsForInstalledSpPkgs(product);
        if~isempty(installedHWBoards)&&isequal(product,'soc')
            installedHWBoards=[installedHWBoards,'Custom Hardware Board'];
        end

        if~any(ismember(installedHWBoards,selectedBoard))
            out=false;
        end
    catch

    end
end

function out=getBoardsSupportedWithECAndSoC()

    out={'Xilinx Zynq UltraScale+ MPSoC ZCU102 Evaluation Kit',...
    'Altera Arria 10 SoC development kit',...
    'Altera Cyclone V SoC development kit',...
    'Arrow SoCKit development board',...
    'Xilinx Zynq-7000 based board',...
    'Xilinx Zynq ZC706 evaluation kit',...
    'ZedBoard'};
end