function rec=IEC61508_PortsSubsystemsUsage



    rec=ModelAdvisor.Check('mathworks.iec61508.PortsSubsystemsUsage');
    rec.Title=DAStudio.message('ModelAdvisor:iec61508:PortsSubsystemsBlocksTitle');
    rec.setCallbackFcn(@PortsSubsystemsCallback,'None','StyleOne');
    rec.TitleTips=DAStudio.message('ModelAdvisor:iec61508:PortsSubsystemsBlocksTip');
    rec.CSHParameters.MapKey='ma.iec61508';
    rec.Value=false;
    rec.CallbackContext='PostCompile';
    rec.CSHParameters.TopicID='PortsSubsystemsUsageTitle';
    rec.setLicense({iec61508_license});
    rec.SupportExclusion=true;
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);
end

function[ResultDescription]=PortsSubsystemsCallback(system)
    ResultDescription={};

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);
    checkResult=true;

    xlateTagPrefix='ModelAdvisor:iec61508:';

    [bResult,aliasResultDescription]=ModelAdvisor.Common.modelAdvisorCheck_whileBlock(system,xlateTagPrefix);
    ResultDescription=[ResultDescription,aliasResultDescription];

    checkResult=checkResult&&bResult;

    [bResult,aliasResultDescription]=ModelAdvisor.Common.modelAdvisorCheck_forBlock(system,xlateTagPrefix);
    aliasResultDescription{end}.setSubBar(true);
    ResultDescription=[ResultDescription,aliasResultDescription];

    checkResult=checkResult&&bResult;

    [bResult,aliasResultDescription]=ModelAdvisor.Common.modelAdvisorCheck_ifBlock(system,xlateTagPrefix);
    aliasResultDescription{1}.setSubTitle(DAStudio.message('ModelAdvisor:iec61508:IfBlockSubtitle'));
    InfoString=[DAStudio.message('ModelAdvisor:iec61508:IfBlockInformation1'),'<br/>',DAStudio.message('ModelAdvisor:iec61508:IfBlockInformation2'),'<br/>',DAStudio.message('ModelAdvisor:iec61508:IfBlockInformation3')];
    aliasResultDescription{1}.setInformation(InfoString);

    aliasResultDescription{end}.setSubBar(true);
    ResultDescription=[ResultDescription,aliasResultDescription];

    checkResult=checkResult&&bResult;

    [bResult,aliasResultDescription]=ModelAdvisor.Common.modelAdvisorCheck_CaseBlock(system,xlateTagPrefix);
    aliasResultDescription{1}.setSubTitle(DAStudio.message('ModelAdvisor:iec61508:hisl_0011_SubTitle'));
    aliasResultDescription{1}.setInformation([DAStudio.message('ModelAdvisor:iec61508:hisl_0011_Info_1'),'<br/>',DAStudio.message('ModelAdvisor:iec61508:hisl_0011_Info_2')]);
    ResultDescription=[ResultDescription,aliasResultDescription];
    ResultDescription{end}.setSubBar(true);
    checkResult=checkResult&&bResult;


    [bResult,aliasResultDescription]=...
    ModelAdvisor.Common.modelAdvisorCheck_SampleTimeDependentBlocks(...
    system,xlateTagPrefix);
    ResultDescription=[ResultDescription,aliasResultDescription];
    checkResult=checkResult&&bResult;

    ResultDescription{end}.setSubBar(false);
    ResultDescription{1}.setCheckText(DAStudio.message('ModelAdvisor:iec61508:PortsSubsystemsBlocksCheckText'));

    mdladvObj.setCheckResultStatus(checkResult);
end