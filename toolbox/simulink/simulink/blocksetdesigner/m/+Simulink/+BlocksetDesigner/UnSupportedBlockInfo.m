classdef UnSupportedBlockInfo<Simulink.BlocksetDesigner.BlockInfo




    properties
    end

    methods
        function obj=UnSupportedBlockInfo(blockName,blockPath,parentId)
            obj=obj@Simulink.BlocksetDesigner.BlockInfo(blockName,blockPath,parentId);

            obj.BlockType='UnSupported';
            obj.IsSupported=0;
        end
    end
end

