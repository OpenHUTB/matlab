



classdef ModeSwitchInterface<autosar.ui.wizard.builder.Interface
    properties(SetAccess=private)
        ModeGroupName;
        ModeDeclarationGroup;
    end

    methods
        function obj=ModeSwitchInterface(name,modeGroup,modeDeclarationGroup,type)
            obj=obj@autosar.ui.wizard.builder.Interface(name,type);
            obj.ModeGroupName=modeGroup;
            obj.ModeDeclarationGroup=modeDeclarationGroup;
        end

        function setModeGroupName(obj,modeGroup)
            obj.ModeGroupName=modeGroup;
        end

        function setModeDeclarationGroup(obj,modeDeclarationGroup)
            obj.ModeDeclarationGroup=modeDeclarationGroup;
        end


        function dataType=getPropDataType(obj,propName)
            if strcmp(propName,'ModeGroupName')
                dataType='string';
            else
                dataType=getPropDataType@autosar.ui.wizard.builder.Interface(obj,propName);
            end
        end

    end

end
