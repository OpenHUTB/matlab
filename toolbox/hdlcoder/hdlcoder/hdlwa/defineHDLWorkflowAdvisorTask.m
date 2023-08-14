function nodes=defineHDLWorkflowAdvisorTask




    nodes={};

    taskLvlOne=0;



    TAN=ModelAdvisor.Procedure('com.mathworks.HDL.WorkflowAdvisor');
    TAN.DisplayName=DAStudio.message('HDLShared:hdldialog:HDLAdvisor');
    TAN.Description=DAStudio.message('HDLShared:hdldialog:HDLAdvisorDesc');
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID='hdlwa_help_button';
    TAN.Children{end+1}='com.mathworks.HDL.SetTarget';
    TAN.Children{end+1}='com.mathworks.HDL.ModelPreparation';
    TAN.Children{end+1}='com.mathworks.HDL.HDLCodeAndTestbenchGeneration';
    TAN.Children{end+1}='com.mathworks.HDL.FPGAImplementation';
    TAN.Children{end+1}='com.mathworks.HDL.DownloadToTarget';
    TAN.Children{end+1}='com.mathworks.HDL.FILImplementation';
    TAN.Children{end+1}='com.mathworks.HDL.RunUSRP';
    TAN.Children{end+1}='com.mathworks.HDL.EmbeddedIntegration';

    HDLWACustomObj=ModelAdvisor.Customization;
    HDLWACustomObj.MenuSettings.Visible=false;
    TAN.CustomObject=HDLWACustomObj;
    nodes{end+1}=TAN;


    taskLvlOne=taskLvlOne+1;
    taskLvlTwo=0;
    TAN=ModelAdvisor.Procedure('com.mathworks.HDL.SetTarget');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWASetTarget'),taskLvlOne);
    TAN.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescSetTarget');
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.Children{end+1}='com.mathworks.HDL.SetTargetDevice';
    TAN.Children{end+1}='com.mathworks.HDL.SetTargetReferenceDesign';
    TAN.Children{end+1}='com.mathworks.HDL.SetTargetInterface';
    TAN.Children{end+1}='com.mathworks.HDL.SetTargetInterfaceAndMode';
    TAN.Children{end+1}='com.mathworks.HDL.SetGenericTargetFrequency';
    TAN.Children{end+1}='com.mathworks.HDL.SetTargetFrequency';
    nodes{end+1}=TAN;


    taskLvlTwo=taskLvlTwo+1;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.SetTargetDevice');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWASetTargetDeviceAndSynthesisTool'),taskLvlOne,taskLvlTwo);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.SetTargetDevice';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    TAN=ModelAdvisor.Task('com.mathworks.HDL.SetTargetReferenceDesign');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWASetTargetReferenceDesign'),taskLvlOne,taskLvlTwo);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.SetTargetReferenceDesign';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlTwo=taskLvlTwo+1;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.SetTargetInterface');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWASetTargetInterface'),taskLvlOne,taskLvlTwo);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.SetTargetInterface';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlTwo3=taskLvlTwo;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.SetTargetInterfaceAndMode');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWASetTargetInterface'),taskLvlOne,taskLvlTwo3);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.SetTargetInterfaceAndMode';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    TAN=ModelAdvisor.Task('com.mathworks.HDL.SetGenericTargetFrequency');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWASetTargetFrequency'),taskLvlOne,taskLvlTwo3);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.SetGenericTargetFrequency';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlTwo=taskLvlTwo+1;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.SetTargetFrequency');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWASetTargetFrequency'),taskLvlOne,taskLvlTwo);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.SetTargetFrequency';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;



    taskLvlOne=taskLvlOne+1;
    taskLvlTwo=0;
    TAN=ModelAdvisor.Procedure('com.mathworks.HDL.ModelPreparation');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWAPrepareModelForHDLCodeGeneration'),taskLvlOne);
    TAN.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescPrepareModelForHDLCodeGeneration');
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.Children{end+1}='com.mathworks.HDL.CheckModelSettings';
    TAN.Children{end+1}='com.mathworks.HDL.CheckFIL';
    TAN.Children{end+1}='com.mathworks.HDL.CheckUSRP';

    nodes{end+1}=TAN;


    taskLvlTwo=taskLvlTwo+1;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.CheckModelSettings');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWACheckModelSettings'),taskLvlOne,taskLvlTwo);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.CheckModelSettings';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlTwo=taskLvlTwo+1;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.CheckFIL');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWACheckFILCompatibility'),taskLvlOne,taskLvlTwo);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.CheckFIL';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlTwo=taskLvlTwo+1;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.CheckUSRP');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWACheckUsrpCompatibility'),taskLvlOne,taskLvlTwo);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.CheckUSRP';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlOne=taskLvlOne+1;
    taskLvlTwo=0;
    TAN=ModelAdvisor.Procedure('com.mathworks.HDL.HDLCodeAndTestbenchGeneration');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWAHDLCodeGeneration'),taskLvlOne);
    TAN.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescHDLCodeGeneration');
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.Children{end+1}='com.mathworks.HDL.SetHDLOptions';
    TAN.Children{end+1}='com.mathworks.HDL.GenerateHDLCodeAndReport';
    TAN.Children{end+1}='com.mathworks.HDL.VerifyCosim';
    TAN.Children{end+1}='com.mathworks.HDL.GenerateIPCore';
    TAN.Children{end+1}='com.mathworks.HDL.GenerateRTLCode';
    nodes{end+1}=TAN;


    taskLvlTwo=taskLvlTwo+1;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.SetHDLOptions');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWASetHDLOptions'),taskLvlOne,taskLvlTwo);
    TAN.MAC='com.mathworks.HDL.SetHDLOptions';
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlTwo=taskLvlTwo+1;
    saveTaskLvl=taskLvlTwo;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.GenerateHDLCodeAndReport');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWAGenerateRTLCodeAndTestbench'),taskLvlOne,taskLvlTwo);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.GenerateHDLCodeAndReport';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlTwo=taskLvlTwo+1;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.VerifyCosim');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWAVerifyCosim'),taskLvlOne,taskLvlTwo);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.VerifyCosim';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlTwo=saveTaskLvl;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.GenerateIPCore');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWAGenerateIPCore'),taskLvlOne,taskLvlTwo);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.GenerateIPCore';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlTwo=saveTaskLvl;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.GenerateRTLCode');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWAGenerateRTLCode'),taskLvlOne,taskLvlTwo);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.GenerateRTLCode';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlOne=taskLvlOne+1;
    taskLvlTwo=0;
    TAN=ModelAdvisor.Procedure('com.mathworks.HDL.FPGAImplementation');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWAFPGASynthesisAndAnalysis'),taskLvlOne);
    TAN.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescFPGASynthesisAndAnalysis');
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.Children{end+1}='com.mathworks.HDL.CreateProject';
    TAN.Children{end+1}='com.mathworks.HDL.RunSynthesisTasks';
    TAN.Children{end+1}='com.mathworks.HDL.AnnotateModel';
    nodes{end+1}=TAN;


    taskLvlTwo=taskLvlTwo+1;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.CreateProject');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWACreateProject'),taskLvlOne,taskLvlTwo);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.CreateProject';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlTwo=taskLvlTwo+1;
    taskLvlThree=0;
    TAN=ModelAdvisor.Procedure('com.mathworks.HDL.RunSynthesisTasks');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWAPerformSynthesisAndPR'),taskLvlOne,taskLvlTwo);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.Children{end+1}='com.mathworks.HDL.RunLogicSynthesis';
    TAN.Children{end+1}='com.mathworks.HDL.RunMapping';
    TAN.Children{end+1}='com.mathworks.HDL.RunPandR';
    TAN.Children{end+1}='com.mathworks.HDL.RunVivadoSynthesis';
    TAN.Children{end+1}='com.mathworks.HDL.RunImplementation';
    nodes{end+1}=TAN;


    taskLvlThree=taskLvlThree+1;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.RunLogicSynthesis');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWAPerformLogicSynthesis'),taskLvlOne,taskLvlTwo,taskLvlThree);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.RunLogicSynthesis';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlThree=taskLvlThree+1;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.RunMapping');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWAPerformMapping'),taskLvlOne,taskLvlTwo,taskLvlThree);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.RunMapping';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlThree=taskLvlThree+1;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.RunPandR');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWAPerformPlaceAndRoute'),taskLvlOne,taskLvlTwo,taskLvlThree);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.RunPandR';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlThree=0;
    taskLvlThree=taskLvlThree+1;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.RunVivadoSynthesis');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWAVivadoSynthesis'),taskLvlOne,taskLvlTwo,taskLvlThree);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.RunVivadoSynthesis';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlThree=taskLvlThree+1;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.RunImplementation');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWAVivadoImplementation'),taskLvlOne,taskLvlTwo,taskLvlThree);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.RunImplementation';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;




    taskLvlTwo=taskLvlTwo+1;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.AnnotateModel');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWAAnnotateModelWithSynthesisResult'),taskLvlOne,taskLvlTwo);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.AnnotateModel';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;



    taskLvlOne=taskLvlOne+1;
    taskLvlTwo=0;
    TAN=ModelAdvisor.Procedure('com.mathworks.HDL.DownloadToTarget');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWADownloadToTarget'),taskLvlOne);
    TAN.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescDownloadToTarget');
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.Children{end+1}='com.mathworks.HDL.GenerateBitstream';
    TAN.Children{end+1}='com.mathworks.HDL.ProgramDevice';
    TAN.Children{end+1}='com.mathworks.HDL.GeneratexPCInterface';
    nodes{end+1}=TAN;


    taskLvlTwo=taskLvlTwo+1;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.GenerateBitstream');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWAGenerateProgrammingFile'),taskLvlOne,taskLvlTwo);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.GenerateBitstream';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlTwo=taskLvlTwo+1;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.ProgramDevice');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWAProgramTargetDevice'),taskLvlOne,taskLvlTwo);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.ProgramDevice';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;



    TAN=ModelAdvisor.Task('com.mathworks.HDL.GeneratexPCInterface');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWAGenerateXPCTargetInterface'),taskLvlOne,taskLvlTwo);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.GeneratexPCInterface';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;



    taskLvlOne=4;
    taskLvlTwo=0;
    TAN=ModelAdvisor.Procedure('com.mathworks.HDL.FILImplementation');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWAFILImplementation'),taskLvlOne);
    TAN.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescFILImplementation');
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.Children{end+1}='com.mathworks.HDL.FILOption';
    TAN.Children{end+1}='com.mathworks.HDL.RunFIL';
    nodes{end+1}=TAN;


    taskLvlTwo=taskLvlTwo+1;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.FILOption');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWASetFILOptions'),taskLvlOne,taskLvlTwo);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.CustomDialogSchema=@schemaSetFILOptions;
    TAN.MAC='com.mathworks.HDL.FILOption';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlTwo=taskLvlTwo+1;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.RunFIL');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWABuildFIL'),taskLvlOne,taskLvlTwo);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.RunFIL';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;



    taskLvlOne=4;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.RunUSRP');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWABuildUSRP'),taskLvlOne);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.RunUSRP';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlOne=4;
    taskLvlTwo=0;
    TAN=ModelAdvisor.Procedure('com.mathworks.HDL.EmbeddedIntegration');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWAEmbeddedIntegration'),taskLvlOne);
    TAN.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescEmbeddedIntegration');
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.Children{end+1}='com.mathworks.HDL.EmbeddedProject';
    TAN.Children{end+1}='com.mathworks.HDL.EmbeddedModelGen';
    TAN.Children{end+1}='com.mathworks.HDL.EmbeddedCustomModelGen';
    TAN.Children{end+1}='com.mathworks.HDL.EmbeddedSystemBuild';
    TAN.Children{end+1}='com.mathworks.HDL.EmbeddedDownload';
    nodes{end+1}=TAN;


    taskLvlTwo=taskLvlTwo+1;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.EmbeddedProject');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWACreateProject'),taskLvlOne,taskLvlTwo);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.EmbeddedProject';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlTwo=taskLvlTwo+1;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.EmbeddedModelGen');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('hdlcommon:workflow:HDLWAEmbeddedModelGen'),taskLvlOne,taskLvlTwo);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.EmbeddedModelGen';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlTwo=taskLvlTwo+1;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.EmbeddedCustomModelGen');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('hdlcommon:workflow:HDLWAEmbeddedModelGen'),taskLvlOne,taskLvlTwo);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.EmbeddedCustomModelGen';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlTwo=taskLvlTwo+1;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.EmbeddedSystemBuild');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWAEmbeddedSystemBuild'),taskLvlOne,taskLvlTwo);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.EmbeddedSystemBuild';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    taskLvlTwo=taskLvlTwo+1;
    TAN=ModelAdvisor.Task('com.mathworks.HDL.EmbeddedDownload');
    TAN.DisplayName=utilTaskTitle(DAStudio.message('HDLShared:hdldialog:HDLWAProgramTargetDevice'),taskLvlOne,taskLvlTwo);
    TAN.CSHParameters.MapKey='hdlwa';
    TAN.CSHParameters.TopicID=TAN.ID;
    TAN.MAC='com.mathworks.HDL.EmbeddedDownload';
    TAN.EnableReset=true;
    nodes{end+1}=TAN;


    hWorkflowList=hdlworkflow.getWorkflowList;
    nodes=hWorkflowList.defineHDLWorkflowAdvisorTasks(nodes,@utilTaskTitle);

end


