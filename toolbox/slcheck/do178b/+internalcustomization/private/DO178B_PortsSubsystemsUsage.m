
function rec=DO178B_PortsSubsystemsUsage

    rec=ModelAdvisor.Check('mathworks.do178.PortsSubsystemsUsage');
    rec.Title=DAStudio.message('ModelAdvisor:do178b:PortsSubsystemsBlocksTitle');
    rec.setCallbackFcn(@PortsSubsystemsCallback,'None','StyleOne');
    rec.TitleTips=DAStudio.message('ModelAdvisor:do178b:PortsSubsystemsBlocksTip');
    rec.CSHParameters.MapKey='ma.do178b';
    rec.Value=false;
    rec.CallbackContext='PostCompile';
    rec.CSHParameters.TopicID='PortsSubsystemsUsageTitle';
    rec.setLicense({do178b_license});
    rec.SupportExclusion=true;
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);
end

function[ResultDescription]=PortsSubsystemsCallback(system)
    ResultDescription={};

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);
    checkResult=true;

    xlateTagPrefix='ModelAdvisor:do178b:';

    [bResult,aliasResultDescription]=ModelAdvisor.Common.modelAdvisorCheck_whileBlock(system,xlateTagPrefix);
    ResultDescription=[ResultDescription,aliasResultDescription];

    checkResult=checkResult&&bResult;

    [bResult,aliasResultDescription]=ModelAdvisor.Common.modelAdvisorCheck_forBlock(system,xlateTagPrefix);
    aliasResultDescription{end}.setSubBar(true);
    ResultDescription=[ResultDescription,aliasResultDescription];

    checkResult=checkResult&&bResult;

    [bResult,aliasResultDescription]=ModelAdvisor.Common.modelAdvisorCheck_ifBlock(system,xlateTagPrefix);
    aliasResultDescription{1}.setSubTitle(DAStudio.message('ModelAdvisor:do178b:IfBlockSubtitle'));
    InfoString=[DAStudio.message('ModelAdvisor:do178b:IfBlockInformation1'),'<br/>',DAStudio.message('ModelAdvisor:do178b:IfBlockInformation2'),'<br/>',DAStudio.message('ModelAdvisor:do178b:IfBlockInformation3')];
    aliasResultDescription{1}.setInformation(InfoString);

    aliasResultDescription{end}.setSubBar(true);
    ResultDescription=[ResultDescription,aliasResultDescription];

    checkResult=checkResult&&bResult;

    [bResult,aliasResultDescription]=ModelAdvisor.Common.modelAdvisorCheck_CaseBlock(system,xlateTagPrefix);
    aliasResultDescription{1}.setSubTitle(DAStudio.message('ModelAdvisor:do178b:hisl_0011_SubTitle'));
    aliasResultDescription{1}.setInformation([DAStudio.message('ModelAdvisor:do178b:hisl_0011_Info_1'),'<br/>',DAStudio.message('ModelAdvisor:do178b:hisl_0011_Info_2')]);
    ResultDescription=[ResultDescription,aliasResultDescription];
    checkResult=checkResult&&bResult;
    ResultDescription{end}.setSubBar(true);


    [bResult,aliasResultDescription]=...
    ModelAdvisor.Common.modelAdvisorCheck_SampleTimeDependentBlocks(...
    system,xlateTagPrefix);
    ResultDescription=[ResultDescription,aliasResultDescription];
    checkResult=checkResult&&bResult;


    ResultDescription{end}.setSubBar(false);
    ResultDescription{1}.setCheckText(DAStudio.message('ModelAdvisor:do178b:PortsSubsystemsBlocksCheckText'));

    mdladvObj.setCheckResultStatus(checkResult);
end

