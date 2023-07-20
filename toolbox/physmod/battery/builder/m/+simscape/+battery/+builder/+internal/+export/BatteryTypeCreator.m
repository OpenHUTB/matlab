classdef(Abstract,Hidden,AllowedSubclasses={?simscape.battery.builder.internal.export.ParallelAssemblyCreator,...
    ?simscape.battery.builder.internal.export.ModuleCreator,...
    ?simscape.battery.builder.internal.export.ModuleAssemblyCreator,...
    ?simscape.battery.builder.internal.export.PackCreator})...
BatteryTypeCreator




    methods(Abstract)
        blockDetails=createBlock(obj,blockDatabase)
    end

    methods(Access=protected,Static)
        function blockName=getBlockName(battery,typeIsHighestLevel)

            switch typeIsHighestLevel
            case true
                blockName=battery.Name;
            otherwise
                blockName=battery.BlockType;
            end
        end
    end
end
