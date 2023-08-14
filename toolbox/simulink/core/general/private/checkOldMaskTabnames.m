





function[resultDescription]=checkOldMaskTabnames(system)
    resultDescription={};

    systemHandle=get_param(system,'Handle');
    modelAdvisorObj=Simulink.ModelAdvisor.getModelAdvisor(systemHandle);


    blocksNeedingUpdate=findBlocksWithMaskTabnames(system);

    if isempty(blocksNeedingUpdate)
        resultDescription{end+1}=showPassStatus(modelAdvisorObj,'Simulink:tools:MALogNoOldMaskTabnamesConversionRequired');
        return;
    end

    resultDescription{end+1}=showFailStatus(modelAdvisorObj,blocksNeedingUpdate);
end

function[resultTemplate]=showPassStatus(modelAdvisorObj,messageID)

    resultTemplate=ModelAdvisor.FormatTemplate('ListTemplate');
    resultTemplate.setSubBar(false);
    resultTemplate.setInformation(DAStudio.message('Simulink:tools:MATitletipOldMaskTabnamesConversion'));
    resultTemplate.setSubResultStatus('pass');
    resultTemplate.setSubResultStatusText(DAStudio.message(messageID));

    modelAdvisorObj.setCheckResultStatus(true);
end

function[resultTemplate]=showFailStatus(modelAdvisorObj,blocksNeedingUpdate)

    resultTemplate=ModelAdvisor.FormatTemplate('ListTemplate');
    resultTemplate.setSubBar(false);
    resultTemplate.setInformation(DAStudio.message('Simulink:tools:MATitletipOldMaskTabnamesConversion'));
    resultTemplate.setSubResultStatus('warn');
    resultTemplate.setSubResultStatusText(DAStudio.message('Simulink:tools:MALogUpgradeOldMaskTabnamesConversion',...
    DAStudio.message('Simulink:tools:MAUpgradeButtonOldMaskTabnamesConversion')));
    resultTemplate.setListObj(blocksNeedingUpdate);

    modelAdvisorObj.setCheckResultStatus(false);
    modelAdvisorObj.setActionEnable(true);
end
