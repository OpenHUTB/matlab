classdef SubsysInfo<Simulink.BlocksetDesigner.BlockInfo




    properties
    end

    methods
        function obj=SubsysInfo(blockName,blockPath,parentId)
            obj=obj@Simulink.BlocksetDesigner.BlockInfo(blockName,blockPath,parentId);

            obj.BlockType='SubSystem';
        end
    end
end

