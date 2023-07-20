classdef SublibraryInfo<Simulink.BlocksetDesigner.EntityInfo

    properties(Access=public)

LibName
LibDesc
LibPath
ParentLibPath
OpenFunction

IsRoot
DocScript
DOCUMENT_CHECKBOX
TEST_CHECKBOX
BUILD_CHECKBOX
    end

    methods
        function obj=SublibraryInfo(libName,openFunction,parentId)
            obj=obj@Simulink.BlocksetDesigner.EntityInfo('sublibrary',parentId);
            obj.OpenFunction=openFunction;
            obj.LibName=libName;
            if isempty(parentId)
                obj.IsRoot='true';
            else
                obj.IsRoot='false';
            end
        end
    end
end

