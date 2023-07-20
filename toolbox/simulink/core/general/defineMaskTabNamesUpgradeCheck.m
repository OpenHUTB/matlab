function defineMaskTabNamesUpgradeCheck






    check=ModelAdvisor.Check('mathworks.design.CheckAndUpdateOldMaskTabnames');
    check.Title=DAStudio.message('Simulink:tools:MATitleOldMaskTabnamesConversion');
    check.TitleTips=DAStudio.message('Simulink:tools:MATitletipOldMaskTabnamesConversion');
    check.SupportLibrary=true;
    check.CSHParameters.MapKey='ma.simulink';
    check.CSHParameters.TopicID='MATitleOldMaskTabnamesConversion';
    check.setCallbackFcn(@checkOldMaskTabnames,'None','StyleOne');


    modifyAction=ModelAdvisor.Action;
    modifyAction.Name=DAStudio.message('Simulink:tools:MAUpgradeButtonOldMaskTabnamesConversion');
    modifyAction.Description=DAStudio.message('Simulink:tools:MAActionOldMaskTabnamesConversion');
    modifyAction.setCallbackFcn(@actionConvertOldMaskTabnames);
    check.setAction(modifyAction);


    modelAdvisor=ModelAdvisor.Root;
    modelAdvisor.register(check);

end




