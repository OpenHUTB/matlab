classdef ConditionalSourceData<BindMode.BindModeSourceData









    properties(SetAccess=protected,GetAccess=public)
        modelName;
        clientName=BindMode.ClientNameEnum.CONDITIONALS;
        isGraphical=false;
        modelLevelBinding=true;
        allowMultipleConnections=false;
        requiresDropDownMenu=true;
        dropDownElements;
        conditionalBindModeHandler;
        sourceElementPath;
        hierarchicalPathArray={};
        sourceElementHandle;
    end
    methods
        function this=ConditionalSourceData(modelName,conditionalBindModeHandler,dropDownElements)
            this.modelName=modelName;
            this.conditionalBindModeHandler=conditionalBindModeHandler;
            this.dropDownElements=dropDownElements;
        end

        function formattedData=getBindableData(this,selectionHandles,activeDropDownValue)
            formattedData=this.conditionalBindModeHandler.getBindableData(selectionHandles,activeDropDownValue);
        end

        function result=onCheckBoxSelectionChange(this,dropDownValue,bindableType,bindableName,bindableMetaData,isChecked)

            result=true;
        end

        function success=onRadioSelectionChange(this,dropDownValue,bindableType,bindableName,bindableMetaData,isChecked)
            success=this.conditionalBindModeHandler.onRadioSelectionChange(dropDownValue,bindableType,bindableName,bindableMetaData,isChecked);
        end
    end
end
