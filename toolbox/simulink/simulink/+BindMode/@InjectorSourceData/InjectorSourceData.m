classdef InjectorSourceData<BindMode.BindModeSourceData









    properties(SetAccess=protected,GetAccess=public)
        modelName;
        clientName=BindMode.ClientNameEnum.INJECTORS;
        isGraphical=false;
        modelLevelBinding=true;
        allowMultipleConnections=false;
        requiresDropDownMenu=true;
        dropDownElements;
        injectorBindModeHandler;
        sourceElementPath;
        hierarchicalPathArray={};
sourceElementHandle
    end
    methods
        function this=InjectorSourceData(modelName,injectorBindModeHandler,dropDownElements)
            this.modelName=modelName;
            this.injectorBindModeHandler=injectorBindModeHandler;
            this.dropDownElements=dropDownElements;
        end

        function formattedData=getBindableData(this,selectionHandles,activeDropDownValue)
            formattedData=this.injectorBindModeHandler.getBindableData(selectionHandles,activeDropDownValue);
        end

        function result=onCheckBoxSelectionChange(this,dropDownValue,bindableType,bindableName,bindableMetaData,isChecked)
            disp('Attempting to change binding of injector source');
            result=true;
        end

        function success=onRadioSelectionChange(this,dropDownValue,bindableType,bindableName,bindableMetaData,isChecked)
            success=this.injectorBindModeHandler.onRadioSelectionChange(dropDownValue,bindableType,bindableName,bindableMetaData,isChecked);
        end
    end
end
