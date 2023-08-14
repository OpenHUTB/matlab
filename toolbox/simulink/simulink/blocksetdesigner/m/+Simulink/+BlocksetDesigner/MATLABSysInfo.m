classdef MATLABSysInfo<Simulink.BlocksetDesigner.BlockInfo




    properties
SYSTEM_OBJECT_FILE
MLSYS_SYSTEM
    end

    methods(Static)
        function result=isFileBasedProperties(property)
            fileBasedProperties={'SYSTEM_OBJECT_FILE'};
            result=any(strcmp(fileBasedProperties,property));
        end
    end

    methods
        function obj=MATLABSysInfo(blockName,blockPath,parentId)
            obj=obj@Simulink.BlocksetDesigner.BlockInfo(blockName,blockPath,parentId);

            obj.BlockType='MATLABSystem';

            obj.DOCUMENT='PASS';
        end
    end
end

