

function[resultDescription]=actionConvertOldMaskTabnames(taskObj)
    resultDescription={};
    modelAdvisorObj=taskObj.MAObj;
    systemName=getfullname(modelAdvisorObj.System);


    blocksNeedingUpdate=findBlocksWithMaskTabnames(systemName);

    if~isempty(blocksNeedingUpdate)
        convertMaskTabnamesToTabs(blocksNeedingUpdate);
    end



    resultDescription=showPassStatus(modelAdvisorObj,blocksNeedingUpdate);
end



function convertMaskTabnamesToTabs(blockList)

    for i=1:length(blockList)
        block=blockList{i};
        maskObj=get_param(block,'MaskObject');



        maskObj.getDialogControls();
    end
end

function[resultTemplate]=showPassStatus(modelAdvisorObj,updatedBlockList)
    resultTemplate=ModelAdvisor.FormatTemplate('ListTemplate');
    resultTemplate.setSubBar(false);
    resultTemplate.setSubResultStatus('pass');
    statusMessage={};

    if isempty(updatedBlockList)
        statusMessage{end+1}=DAStudio.message('Simulink:tools:MALogNoOldMaskTabnamesConversionRequired');
        resultTemplate.setSubResultStatusText(statusMessage);
    else
        statusMessage{end+1}=ModelAdvisor.LineBreak;
        statusMessage{end+1}=DAStudio.message('Simulink:tools:MALogOldMaskTabnamesConversionDone');
        resultTemplate.setSubResultStatusText(statusMessage);
        resultTemplate.setListObj(updatedBlockList);
    end

    modelAdvisorObj.setActionResultStatus(true);
    modelAdvisorObj.setActionEnable(false);
end
