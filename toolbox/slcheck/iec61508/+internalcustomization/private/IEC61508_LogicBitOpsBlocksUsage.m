function rec=IEC61508_LogicBitOpsBlocksUsage



    rec=ModelAdvisor.Check('mathworks.iec61508.LogicBlockUsage');
    rec.Title=DAStudio.message('ModelAdvisor:iec61508:LogicBitOpsBlocksTitle');
    rec.setCallbackFcn(@LogicBlockCallback,'None','StyleOne');
    rec.TitleTips=DAStudio.message('ModelAdvisor:iec61508:LogicBitOpsBlocksUsageTip');
    rec.CSHParameters.MapKey='ma.iec61508';
    rec.Value=false;
    rec.CallbackContext='PostCompile';
    rec.CSHParameters.TopicID='LogicBlockUsageTitle';
    rec.setLicense({iec61508_license});
    rec.SupportExclusion=true;
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);

    function[ResultDescription]=LogicBlockCallback(system)
        ResultDescription={};
        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
        mdladvObj.setCheckResultStatus(false);
        checkResult=true;

        xlateTagPrefix='ModelAdvisor:iec61508:';

        [bResult,aliasResultDescription]=ModelAdvisor.Common.modelAdvisorCheck_relopBlock(system,xlateTagPrefix);
        ResultDescription=[ResultDescription,aliasResultDescription];
        checkResult=checkResult&&bResult;

        [bResult,aliasResultDescription]=ModelAdvisor.Common.modelAdvisorCheck_logicBlock(system,xlateTagPrefix);
        aliasResultDescription{1}.setSubBar(0);
        ResultDescription=[ResultDescription,aliasResultDescription];
        checkResult=checkResult&&bResult;

        ResultDescription{1}.setCheckText(DAStudio.message('ModelAdvisor:iec61508:LogicBitOpsBlocksUsageCheckText'));

        mdladvObj.setCheckResultStatus(checkResult);
