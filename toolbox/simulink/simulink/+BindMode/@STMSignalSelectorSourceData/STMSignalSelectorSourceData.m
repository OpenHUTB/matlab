classdef STMSignalSelectorSourceData<BindMode.BindModeSourceData











    properties(SetAccess=protected,GetAccess=public)
        modelName;
        clientName=BindMode.ClientNameEnum.STMSIGSELECTOR;
        isGraphical=false;
        sourceElementPath;
        sourceElementHandle;
        allowMultipleConnections=true;
        modelLevelBinding=true;
        requiresDropDownMenu=false;
        hierarchicalPathArray={};
        simOutSigSelectorBindModeHandler;
    end
    methods
        function this=STMSignalSelectorSourceData(modelName,simOutSigSelectorBindModeHandler)
            this.modelName=modelName;
            this.disableSorting=true;
            this.simOutSigSelectorBindModeHandler=simOutSigSelectorBindModeHandler;
        end


        function formattedData=getBindableData(this,selectionHandles,activeDropDownValue)
            formattedData=this.simOutSigSelectorBindModeHandler.filterSelectionAddCheckedSignals(selectionHandles,activeDropDownValue);
        end



        function success=onCheckBoxSelectionChange(this,dropDownValue,bindableType,bindableName,bindableMetaData,isChecked)
            success=this.simOutSigSelectorBindModeHandler.updateSignalSet(dropDownValue,bindableType,bindableName,bindableMetaData,isChecked);
        end
    end
end
