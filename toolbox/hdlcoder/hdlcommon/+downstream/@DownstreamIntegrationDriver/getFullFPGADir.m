function fulldir=getFullFPGADir(obj)


    switch obj.hToolDriver.hTool.ToolName
    case 'Xilinx ISE'
        fulldir=fullfile(obj.getProjectFolder,obj.iseDir);
    case 'Xilinx Vivado'
        fulldir=fullfile(obj.getProjectFolder,obj.vivadoDir);
    case 'Microchip Libero SoC'
        fulldir=fullfile(obj.getProjectFolder,obj.liberoDir);
    case 'Intel Quartus Pro'
        fulldir=fullfile(obj.getProjectFolder,obj.intelquartusproDir);
    otherwise
        fulldir=fullfile(obj.getProjectFolder,obj.quartusDir);
    end
end
