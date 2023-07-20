classdef TargetSpecificTriggerBase<handle






    properties(SetObservable=true)
        ParentTaskGroup;
    end

    methods


        function checkSimulationConstraints(~,~)
        end



        function checkCodeGenerationConstraints(~,~)
        end




        function panel=getSubDialogSchema(~,panel)
            panel.noSchemaCreated=true;
        end



        function varType=getPropDataType(obj,varName)
            varType='other';
            if(~isempty(findprop(obj,varName)))
                valClass=class(obj.(varName));
                switch(valClass)
                case 'char',varType='string';return;
                case 'double',varType='double';return;
                case 'int32',varType='int';return;
                case 'logical',varType='bool';return;
                otherwise,return;
                end
            end
            return;
        end
    end
end
