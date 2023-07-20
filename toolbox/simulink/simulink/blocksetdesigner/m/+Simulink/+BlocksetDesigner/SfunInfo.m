classdef SfunInfo<Simulink.BlocksetDesigner.BlockInfo
    properties
S_FUN_FILE
S_FUN_BUILD
BUILD
ISBUILDER
ISPACKAGED
S_FUN_FUNCTION_NAME
S_FUN_MEX_FILE
BUILD_TIMESTAMP
    end

    methods(Static)
        function result=isFileBasedProperties(property)
            fileBasedProperties={'S_FUN_FILE','S_FUN_MEX_FILE','S_FUN_BUILD'};
            result=any(strcmp(fileBasedProperties,property));
        end
    end

    methods
        function obj=SfunInfo(blockName,blockPath,parentId)
            obj=obj@Simulink.BlocksetDesigner.BlockInfo(blockName,blockPath,parentId);

            obj.BlockType='S-Function';
        end
    end
end

