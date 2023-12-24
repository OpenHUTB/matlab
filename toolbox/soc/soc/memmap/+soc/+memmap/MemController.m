classdef MemController<handle
    properties(SetAccess=private)
        memPSBaseAddr='0x00000000'
        memPSRange={'0',''};
        memPSBaseAddrMMU={0,'0'};
        memPLBaseAddr='0x00000000';
        memPLRange={'0',''};
        memPLBaseAddrMMU={0,'0'};
        regBaseAddr='0x00000000';
        regAddrRange={'0',''};
        regBaseAddrMMU={0,'0'};

        regSize=4;
    end


    methods
        function obj=MemController(memoryMapInfo)

            switch memoryMapInfo.boardName
            case 'Xilinx Zynq ZC706 evaluation kit'
                if memoryMapInfo.FPGADesign.IncludeProcessingSystem
                    obj.memPSRange={'1','G'};
                end
                obj.memPLRange={'1','G'};
            case 'ZedBoard'
                obj.memPSRange={'512','M'};
            case 'Xilinx Zynq UltraScale+ MPSoC ZCU102 Evaluation Kit'
                if memoryMapInfo.FPGADesign.IncludeProcessingSystem
                    obj.memPSRange={'2','G'};
                end
                obj.memPLRange={'512','M'};
            case 'Artix-7 35T Arty FPGA evaluation kit'
                obj.memPLRange={'256','M'};
            case 'Xilinx Kintex-7 KC705 development board'
                obj.memPLRange={'1','G'};
            case 'Altera Arria 10 SoC development kit'
                obj.memPSRange={'2','G'};
                obj.memPLRange={'2','G'};
            case 'Altera Cyclone V SoC development kit'
                obj.memPSRange={'1','G'};
                obj.memPLRange={'1','G'};
            case codertarget.internal.getCustomHardwareBoardNamesForSoC
                fobs=soc.internal.getCustomBoardParams(memoryMapInfo.boardName);
                if memoryMapInfo.FPGADesign.HasPSMemory
                    PSMemSize=fobs.fdevObj.ExternalMemorySize.PSMemSize;
                    if PSMemSize<1024
                        obj.memPSRange={num2str(PSMemSize),'M'};
                    elseif PSMemSize<2048
                        obj.memPSRange={num2str(PSMemSize/1024),'G'};
                    else
                        obj.memPSRange={'2','G'};
                    end
                end
                if memoryMapInfo.FPGADesign.HasPLMemory
                    PLMemSize=fobs.fdevObj.ExternalMemorySize.MIGMemSize;
                    if PLMemSize<1024
                        obj.memPLRange={num2str(PLMemSize),'M'};
                    elseif PLMemSize<2048
                        obj.memPLRange={num2str(PLMemSize/1024),'G'};
                    else
                        obj.memPLRange={'2','G'};
                    end
                end
            otherwise
                obj.memPSRange={'2','G'};
                obj.memPLRange={'2','G'};
            end
            switch(memoryMapInfo.FPGAFamily)
            case{'Zynq'}
                obj.memPLBaseAddr='0x80000000';
            case{'MPSoC','RFSoC','Zynq UltraScale+','Zynq UltraScale+ RFSoC'}
                obj.memPLBaseAddr='0x00000000';
                obj.memPLBaseAddrMMU={9,'0'};
            case{'Cyclone V','Arria 10'}
                obj.memPLBaseAddr='0x80000000';
            end


            switch(memoryMapInfo.FPGAFamily)
            case{'Zynq','Artix7','Kintex7'}
                obj.regBaseAddr='0x40000000';
                obj.regAddrRange={'1','G'};
            case{'MPSoC','RFSoC','Zynq UltraScale+','Zynq UltraScale+ RFSoC'}
                obj.regBaseAddr='0xA0000000';
                obj.regAddrRange={'256','M'};
            case{'Cyclone V','Arria 10'}
                obj.regBaseAddr='0xC0000000';
                obj.regAddrRange={'512','M'};
                obj.regBaseAddrMMU={8,'0'};
            otherwise
                obj.regBaseAddr='0x80000000';
                obj.regAddrRange={'1','G'};
            end
        end
    end
end

