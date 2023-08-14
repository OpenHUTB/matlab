classdef BlockInfo<Simulink.BlocksetDesigner.EntityInfo

    properties(Access=public,Hidden=true)

BlockClass
BlockDesc
BlockKeywords
BlockIconPath
BlockReference
    end

    properties

BlockName
BlockPath
BlockType

BLOCK_LIBRARY
BLOCK_ICON
TEST_SCRIPT
TEST_HARNESS
DOC_SCRIPT
DOC_FILE
DOCUMENT
DOCUMENT_TIMESTAMP
TEST
TEST_TIMESTAMP
DOCUMENT_CHECKBOX
TEST_CHECKBOX
BUILD_CHECKBOX
        DOCUMENT_CHECKBOX_ENABLE='false'
        TEST_CHECKBOX_ENABLE='false'
        BUILD_CHECKBOX_ENABLE='false'
    end

    methods(Static)
        function result=isFileBasedProperties(property)
            fileBasedProperties={'BLOCK_LIBRARY','TEST_SCRIPT','TEST_HARNESS','DOC_SCRIPT','DOC_FILE'};
            result=any(strcmp(fileBasedProperties,property));
        end
    end

    methods
        function obj=BlockInfo(blockName,blockPath,parentId)
            obj=obj@Simulink.BlocksetDesigner.EntityInfo('block',parentId);
            obj.BlockName=blockName;
            obj.BlockPath=blockPath;

            obj.IsLeafNode=1;

            obj.TEST='WARNING';
            obj.DOCUMENT='WARNING';
        end

    end
end

