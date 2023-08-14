classdef ObserverSourceData<BindMode.BindModeSourceData









    properties(SetAccess=protected,GetAccess=public)
        modelName;
        clientName=BindMode.ClientNameEnum.OBSERVERS;
        isGraphical=false;
        modelLevelBinding=true;
        allowMultipleConnections=false;
        requiresDropDownMenu=true;
        dropDownElements;
        observerBindModeHandler;
        sourceElementPath;
        hierarchicalPathArray={};
sourceElementHandle
    end
    methods
        function this=ObserverSourceData(modelName,observerBindModeHandler,dropDownElements)
            this.modelName=modelName;
            this.observerBindModeHandler=observerBindModeHandler;
            this.dropDownElements=dropDownElements;
        end

        function formattedData=getBindableData(this,selectionHandles,activeDropDownValue)
            formattedData=this.observerBindModeHandler.getBindableData(selectionHandles,activeDropDownValue);
        end

        function result=onCheckBoxSelectionChange(this,dropDownValue,bindableType,bindableName,bindableMetaData,isChecked)
            disp('Attempting to change binding of observer source');
            result=true;
        end

        function success=onRadioSelectionChange(this,dropDownValue,bindableType,bindableName,bindableMetaData,isChecked)
            success=this.observerBindModeHandler.onRadioSelectionChange(dropDownValue,bindableType,bindableName,bindableMetaData,isChecked);
        end
    end
end
