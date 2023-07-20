function defineDO254ModelAdvisorTasks()




    mdladvRoot=ModelAdvisor.Root;




    rec=ModelAdvisor.FactoryGroup('do254');
    rec.DisplayName=DAStudio.message('ModelAdvisor:do178b:ByTaskDO254_group_title');
    rec.Description=DAStudio.message('ModelAdvisor:do178b:ByTaskDO254_group_description');
    rec.CSHParameters.MapKey='ma.do254';
    rec.CSHParameters.TopicID='do_254_overview';
    rec.addCheck('mathworks.do178.MdlChecksum');



    recHil=ModelAdvisor.Common.defineHISLTasks('do254',true);
    rec.addFactoryGroup(recHil);
    mdladvRoot.publish(recHil);



    recLib=ModelAdvisor.FactoryGroup('do254:LibraryLinks');
    recLib.DisplayName=DAStudio.message('ModelAdvisor:do178b:LibraryLinksGroupName');
    recLib.Description=DAStudio.message('ModelAdvisor:do178b:LibraryLinksGroupDescription');
    recLib.CSHParameters.MapKey='ma.do254';
    recLib.CSHParameters.TopicID='mdl_std_do254_liblinks';
    if~slfeature('hisl_0075')
        recLib.addCheck('mathworks.design.DisabledLibLinks');
        recLib.addCheck('mathworks.design.ParameterizedLibLinks');
    end
    recLib.addCheck('mathworks.design.UnresolvedLibLinks');
    rec.addFactoryGroup(recLib);



    recReq=ModelAdvisor.FactoryGroup('do254:Requirements');
    recReq.DisplayName=DAStudio.message('ModelAdvisor:do178b:RequirementsGroupName');
    recReq.Description=DAStudio.message('ModelAdvisor:do178b:RequirementsGroupDescription');
    recReq.CSHParameters.MapKey='ma.do254';
    recReq.CSHParameters.TopicID='mdl_std_do254_requirements';
    recReq.addCheck('mathworks.req.Identifiers');
    recReq.addCheck('mathworks.req.Documents');
    recReq.addCheck('mathworks.req.Paths');
    recReq.addCheck('mathworks.req.Labels');
    rec.addFactoryGroup(recReq);



    recHdl=ModelAdvisor.FactoryGroup('do254:HDLCoder');
    recHdl.DisplayName='HDL Coder';
    recHdl.Description=DAStudio.message('HDLShared:hdlmodelchecker:desc_Model_Checker');
    recHdl.CSHParameters.MapKey='hdlmodelchecker';
    recHdl.CSHParameters.TopicID='hdlmodelchecker_help_button';
    rec.addFactoryGroup(recHdl);



    recHdlMdl=ModelAdvisor.FactoryGroup('do254:HDLCoder.Checkforblocksandblocksettings');
    recHdlMdl.DisplayName=DAStudio.message('HDLShared:hdlmodelchecker:cat_Block_Level_Checks');
    recHdlMdl.Description=DAStudio.message('HDLShared:hdlmodelchecker:desc_Block_Level_Checks');
    recHdlMdl.CSHParameters.MapKey='hdlmodelchecker';
    recHdlMdl.CSHParameters.TopicID='com.mathworks.HDL.ModelChecker.Group_Block_Level_Checks';
    recHdlMdl.addCheck('com.mathworks.HDL.ModelAdvisor.runHDLRecipChecks');
    recHdlMdl.addCheck('com.mathworks.HDL.ModelAdvisor.runSampleTimeChecks');
    recHdlMdl.addCheck('com.mathworks.HDL.ModelAdvisor.runBlockSupportChecks');
    recHdlMdl.addCheck('com.mathworks.HDL.ModelAdvisor.runMLFcnBlkChecks');
    recHdlMdl.addCheck('com.mathworks.HDL.ModelAdvisor.runStateflowChartSettingsChecks');
    recHdlMdl.addCheck('com.mathworks.HDL.ModelAdvisor.runUnsupportedLUTTrigFunChecks');
    recHdlMdl.addCheck('com.mathworks.HDL.ModelAdvisor.runObsoleteDelaysChecks');
    recHdlMdl.addCheck('com.mathworks.HDL.ModelAdvisor.runSignalObjectStorageClassChecks');
    recHdlMdl.addCheck('com.mathworks.HDL.ModelAdvisor.runMatrixSizesChecks');
    recHdl.addFactoryGroup(recHdlMdl);



    recHdlInd=ModelAdvisor.FactoryGroup('do254:HDLCoder.Industrystandardchecks');
    recHdlInd.DisplayName=DAStudio.message('HDLShared:hdlmodelchecker:cat_IndustryStandards_Checks');
    recHdlInd.Description=DAStudio.message('HDLShared:hdlmodelchecker:desc_IndustryStandards_Checks');
    recHdlInd.CSHParameters.MapKey='hdlmodelchecker';
    recHdlInd.CSHParameters.TopicID='com.mathworks.HDL.ModelChecker.Group_IndustryStandards_Checks';
    recHdlInd.addCheck('com.mathworks.HDL.ModelAdvisor.runFileExtensionChecks');
    recHdlInd.addCheck('com.mathworks.HDL.ModelAdvisor.runNameConventionChecks');
    recHdlInd.addCheck('com.mathworks.HDL.ModelAdvisor.runToplevelNameChecks');
    recHdlInd.addCheck('com.mathworks.HDL.ModelAdvisor.runSubsystemNameChecks');
    recHdlInd.addCheck('com.mathworks.HDL.ModelAdvisor.runPackageNameChecks');
    recHdlInd.addCheck('com.mathworks.HDL.ModelAdvisor.runPortSignalNameChecks');
    recHdlInd.addCheck('com.mathworks.HDL.ModelAdvisor.runGenericChecks');
    recHdlInd.addCheck('com.mathworks.HDL.ModelAdvisor.runClockResetEnableChecks');
    recHdlInd.addCheck('com.mathworks.HDL.ModelAdvisor.runArchitectureNameChecks');
    recHdlInd.addCheck('com.mathworks.HDL.ModelAdvisor.runSplitEntityArchitectureChecks');
    recHdlInd.addCheck('com.mathworks.HDL.ModelAdvisor.runClockChecks');
    recHdl.addFactoryGroup(recHdlInd);



    recHdlMdlConf=ModelAdvisor.FactoryGroup('do254:HDLCoder.ModelConfigurationchecks');
    recHdlMdlConf.DisplayName=DAStudio.message('HDLShared:hdlmodelchecker:cat_Model_Level_Checks');
    recHdlMdlConf.Description=DAStudio.message('HDLShared:hdlmodelchecker:desc_Model_Level_Checks');
    recHdlMdlConf.CSHParameters.MapKey='hdlmodelchecker';
    recHdlMdlConf.CSHParameters.TopicID='com.mathworks.HDL.ModelChecker.Group_Model_Level_Checks';
    recHdlMdlConf.addCheck('com.mathworks.HDL.ModelAdvisor.runModelParamsChecks');
    recHdlMdlConf.addCheck('com.mathworks.HDL.ModelAdvisor.runGlobalResetChecks');
    recHdlMdlConf.addCheck('com.mathworks.HDL.ModelAdvisor.runInlineConfigurationsChecks');
    recHdlMdlConf.addCheck('com.mathworks.HDL.ModelAdvisor.runVisualizationChecks');
    recHdlMdlConf.addCheck('com.mathworks.HDL.ModelAdvisor.runBalanceDelaysChecks');
    recHdlMdlConf.addCheck('com.mathworks.HDL.ModelAdvisor.runAlgebraicLoopChecks');
    recHdl.addFactoryGroup(recHdlMdlConf);



    recHdlMdlNat=ModelAdvisor.FactoryGroup('do254:HDLCoder.NativeFlaotingPointChecks');
    recHdlMdlNat.DisplayName=DAStudio.message('HDLShared:hdlmodelchecker:cat_NativeFloatingPoint_Checks');
    recHdlMdlNat.Description=DAStudio.message('HDLShared:hdlmodelchecker:desc_NativeFloatingPoint_Checks');
    recHdlMdlNat.CSHParameters.MapKey='hdlmodelchecker';
    recHdlMdlNat.CSHParameters.TopicID='com.mathworks.HDL.ModelChecker.Group_NativeFloatingPoint_Checks';
    recHdlMdlNat.addCheck('com.mathworks.HDL.ModelAdvisor.runNFPLatencyChecks');
    recHdlMdlNat.addCheck('com.mathworks.HDL.ModelAdvisor.runNFPULPErrorChecks');
    recHdlMdlNat.addCheck('com.mathworks.HDL.ModelAdvisor.runNFPSuggestionChecks');
    recHdlMdlNat.addCheck('com.mathworks.HDL.ModelAdvisor.runDoubleDatatypeChecks');
    recHdlMdlNat.addCheck('com.mathworks.HDL.ModelAdvisor.runNFPDTCChecks');
    recHdlMdlNat.addCheck('com.mathworks.HDL.ModelAdvisor.runNFPHDLRecipChecks');
    recHdlMdlNat.addCheck('com.mathworks.HDL.ModelAdvisor.runNFPRelopChecks');
    recHdlMdlNat.addCheck('com.mathworks.HDL.ModelAdvisor.runNFPSupportedBlocksChecks')
    recHdl.addFactoryGroup(recHdlMdlNat);



    recHdlMdlPor=ModelAdvisor.FactoryGroup('do254:HDLCoder.Checkforportsandsubsystems');
    recHdlMdlPor.DisplayName=DAStudio.message('HDLShared:hdlmodelchecker:cat_Subsystem_Level_Checks');
    recHdlMdlPor.Description=DAStudio.message('HDLShared:hdlmodelchecker:desc_Subsystem_Level_Checks');
    recHdlMdlPor.CSHParameters.MapKey='hdlmodelchecker';
    recHdlMdlPor.CSHParameters.TopicID='com.mathworks.HDL.ModelChecker.Group_Subsystem_Level_Checks';
    recHdlMdlPor.addCheck('com.mathworks.HDL.ModelAdvisor.runInvalidDUTChecks');
    recHdlMdlPor.addCheck('com.mathworks.HDL.ModelAdvisor.runEnTrigInitConChecks');
    recHdl.addFactoryGroup(recHdlMdlPor);

    mdladvRoot.publish(recHdlMdlPor);
    mdladvRoot.publish(recHdlMdlNat);
    mdladvRoot.publish(recHdlMdlConf);
    mdladvRoot.publish(recHdlInd);
    mdladvRoot.publish(recHdlMdl);
    mdladvRoot.publish(recHdl);
    mdladvRoot.publish(recReq);
    mdladvRoot.publish(recLib);
    mdladvRoot.publish(rec);

end
