function rec=DO178B_LogicBitOpsBlocksUsage



    rec=ModelAdvisor.Check('mathworks.do178.LogicBlockUsage');
    rec.Title=DAStudio.message('ModelAdvisor:do178b:LogicBitOpsBlocksTitle');
    rec.setCallbackFcn(@LogicBlockCallback,'None','StyleOne');
    rec.TitleTips=DAStudio.message('ModelAdvisor:do178b:LogicBitOpsBlocksUsageTip');
    rec.CSHParameters.MapKey='ma.do178b';
    rec.Value=false;
    rec.CallbackContext='PostCompile';
    rec.CSHParameters.TopicID='LogicBlockUsageTitle';
    rec.setLicense({do178b_license});
    rec.SupportExclusion=true;
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);

    function[ResultDescription]=LogicBlockCallback(system)
        ResultDescription={};
        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
        mdladvObj.setCheckResultStatus(false);
        checkResult=true;

        xlateTagPrefix='ModelAdvisor:do178b:';

        [bResult,aliasResultDescription]=ModelAdvisor.Common.modelAdvisorCheck_relopBlock(system,xlateTagPrefix);
        ResultDescription=[ResultDescription,aliasResultDescription];
        checkResult=checkResult&&bResult;

        [bResult,aliasResultDescription]=ModelAdvisor.Common.modelAdvisorCheck_logicBlock(system,xlateTagPrefix);
        aliasResultDescription{1}.setSubBar(0);
        ResultDescription=[ResultDescription,aliasResultDescription];
        checkResult=checkResult&&bResult;

        ResultDescription{1}.setCheckText(DAStudio.message('ModelAdvisor:do178b:LogicBitOpsBlocksUsageCheckText'));

        mdladvObj.setCheckResultStatus(checkResult);
