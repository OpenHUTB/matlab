classdef AssessmentsSourceData<BindMode.BindModeSourceData









    properties(SetAccess=protected,GetAccess=public)
        modelName;
        systemModelName;
        clientName=BindMode.ClientNameEnum.ASSESSMENTS;
        isGraphical=false;
        modelLevelBinding=true;
        sourceElementPath;
        hierarchicalPathArray={};
        sourceElementHandle;
        allowMultipleConnections=false;
        requiresDropDownMenu=true;
        dropDownElements;
        assessmentsBindModeHandler;
    end
    methods
        function this=AssessmentsSourceData(modelName,systemModelName,assessmentsBindModeHandler,dropDownElements)
            this.modelName=modelName;
            this.systemModelName=systemModelName;
            this.assessmentsBindModeHandler=assessmentsBindModeHandler;
            this.dropDownElements=dropDownElements;
        end

        function formattedData=getBindableData(this,selectionHandles,activeDropDownValue)
            formattedData=this.assessmentsBindModeHandler.getBindableData(selectionHandles,activeDropDownValue);
        end

        function result=onCheckBoxSelectionChange(this,dropDownValue,bindableType,bindableName,bindableMetaData,isChecked)
            disp('Attempting to change binding of assessments source');
            result=true;
        end

        function success=onRadioSelectionChange(this,dropDownValue,bindableType,bindableName,bindableMetaData,isChecked)
            success=this.assessmentsBindModeHandler.onRadioSelectionChange(dropDownValue,bindableType,bindableName,bindableMetaData,isChecked);
        end

        function result=onTableElementClick(this,elementType,bindableMetaData)
            if this.assessmentsBindModeHandler.checkBindableExists(elementType,bindableMetaData)
                result=onTableElementClick@BindMode.BindModeSourceData(this,elementType,bindableMetaData);
            else
                result=false;
            end
        end
    end
end
