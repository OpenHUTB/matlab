function tempCopy=createConfigUIObj(allInputParameters,originalNodeID)
    am=Advisor.Manager.getInstance;
    am.updateCacheIfNeeded;
    TaskAdvisorCellArray=am.slCustomizationDataStructure.TaskAdvisorCellArray;
    originalNode=[];
    for i=1:numel(TaskAdvisorCellArray)
        if strcmp(TaskAdvisorCellArray{i}.ID,originalNodeID)
            originalNode=TaskAdvisorCellArray{i};
            break;
        end
    end
    tempCopy=locCreateConfigUIObj(originalNode);
    for i=1:numel(tempCopy.InputParameters)
        tempCopy.InputParameters{i}.Enable=allInputParameters(i).isenable;
        switch tempCopy.InputParameters{i}.Type
        case 'BlockType'
            ValueElement={};
            for j=1:numel(allInputParameters(i).value)
                ValueElement{j,1}=allInputParameters(i).value(j).name;
                ValueElement{j,2}=allInputParameters(i).value(j).masktype;
            end
            tempCopy.InputParameters{i}.Value=ValueElement;
        case 'BlockTypeWithParameter'
            ValueElement=[];
            for j=1:numel(allInputParameters(i).value)
                ValueElement{j,1}=allInputParameters(i).value(j).name;
                ValueElement{j,2}=allInputParameters(i).value(j).masktype;
                ValueElement{j,3}=allInputParameters(i).value(j).blocktypeparameters;
            end
            tempCopy.InputParameters{i}.Value=ValueElement;
        case 'PushButton'
            tempCopy.InputParameters{i}.Value=allInputParameters(i).value;
        otherwise
            tempCopy.InputParameters{i}.Value=allInputParameters(i).value;
        end
    end
end

function ConfigUIObj=locCreateConfigUIObj(taskObj)
    ConfigUIObj=ModelAdvisor.ConfigUI.createFromMANodeObj(taskObj);
    if isa(taskObj,'ModelAdvisor.Task')
        am=Advisor.Manager.getInstance;
        checkCell=am.slCustomizationDataStructure.checkCellArray;

        if(taskObj.MACIndex>0)&&(taskObj.MACIndex<=length(checkCell))
            ConfigUIObj.InputParameters=modeladvisorprivate('modeladvisorutil2','DeepCopy',checkCell{taskObj.MACIndex}.InputParameters);
            CallbackContext=checkCell{taskObj.MACIndex}.CallbackContext;

            if~strcmp(CallbackContext,'None')
                ConfigUIObj.DisplayLabelPrefix=DAStudio.message('Simulink:tools:PrefixForCompileCheck');
            end
            ConfigUIObj.InputParametersLayoutGrid=checkCell{taskObj.MACIndex}.InputParametersLayoutGrid;
            if isempty(checkCell{taskObj.MACIndex}.InputParametersCallback)
                cacheFilePath=am.getCacheFilePath;
                varName=['FcnHandle_',num2str(taskObj.MACIndex)];
                cachedVaule=load(cacheFilePath,varName);
                checkCell{taskObj.MACIndex}.InputParametersCallback=cachedVaule.(varName).InputParametersCallback;
            end
            ConfigUIObj.InputParametersCallback=checkCell{taskObj.MACIndex}.InputParametersCallback;
        end
    end
end