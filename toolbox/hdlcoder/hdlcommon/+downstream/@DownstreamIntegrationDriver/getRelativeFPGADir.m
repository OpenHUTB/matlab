function reldir=getRelativeFPGADir(obj)


    switch obj.hToolDriver.hTool.ToolName
    case 'Xilinx ISE'
        reldir=obj.iseDir;
    case 'Xilinx Vivado'
        reldir=obj.vivadoDir;
    case 'Microchip Libero SoC'
        reldir=obj.liberoDir;
    case 'Intel Quartus Pro'
        reldir=obj.intelquartusproDir;
    otherwise
        reldir=obj.quartusDir;
    end
end
