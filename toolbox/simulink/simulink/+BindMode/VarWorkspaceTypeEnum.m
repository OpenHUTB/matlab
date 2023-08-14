

classdef VarWorkspaceTypeEnum<handle
    enumeration
        BASE('base'),MODEL('model'),DATA_DICTIONARY('')
    end

    properties
        sourceName char;
    end

    methods
        function e=VarWorkspaceTypeEnum(source)
            e.sourceName=source;
        end
    end

    methods(Static)
        function enumType=getEnumTypeFromStr(workspaceType)
            workspaceTypeLower=lower(workspaceType);
            if(strcmp(workspaceTypeLower,'base')||strcmp(workspaceTypeLower,'base workspace'))
                enumType=BindMode.VarWorkspaceTypeEnum.BASE;
            elseif(strcmp(workspaceTypeLower,'model')||strcmp(workspaceTypeLower,'model workspace'))
                enumType=BindMode.VarWorkspaceTypeEnum.MODEL;
            elseif(endsWith(workspaceTypeLower,'.sldd'))
                enumType=BindMode.VarWorkspaceTypeEnum.DATA_DICTIONARY;
                enumType.sourceName=workspaceType;
            else
                assert(false,DAStudio.message('SimulinkHMI:HMIBindMode:VariableWorkspaceUnknown'));
            end
        end
    end
end