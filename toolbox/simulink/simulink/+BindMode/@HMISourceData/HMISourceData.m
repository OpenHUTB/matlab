

classdef HMISourceData<BindMode.BindModeSourceData






    properties(SetAccess=protected,GetAccess=public)
        modelName;
        clientName=BindMode.ClientNameEnum.HMI;
        isGraphical=true;
        modelLevelBinding=false;
        sourceElementPath;
        hierarchicalPathArray;
        sourceElementHandle;
        allowMultipleConnections;
        requiresDropDownMenu=false;
    end
    methods
        function newObj=HMISourceData(modelName,sourceElementPath,allowMultipleConnections)
            newObj.modelName=modelName;
            newObj.sourceElementPath=sourceElementPath;
            try
                newObj.sourceElementHandle=get_param(sourceElementPath,'Handle');
            catch ME
                if strcmp(ME.identifier,'Simulink:Commands:InvSimulinkObjectName')
                    newObj.sourceElementHandle=-1;
                end
            end
            newObj.hierarchicalPathArray=BindMode.utils.getHierarchicalPathArray(sourceElementPath);
            newObj.allowMultipleConnections=allowMultipleConnections;
            newObj.allowSelectAll=allowMultipleConnections;


            widgetBindingType=utils.getWidgetBindingType(newObj.sourceElementHandle);
            if(strcmp(widgetBindingType,'ParameterOrVariable'))
                newObj.requiresInputField=true;
                newObj.inputPlaceholder=DAStudio.message('SimulinkHMI:selectionwidget:CompositeTuningTextfieldPlaceHolder');
            end
        end

        function result=allowBindWhenSimulating(~)
            result=true;
        end

        function result=allowStateflowBinding(~)
            result=slfeature('BindHMIBlocksToStateflow');
        end
    end
end