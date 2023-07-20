function taskCellArray=defineSfunModelAdvisorTasks







    taskCellArray={};
    mdladvRoot=ModelAdvisor.Root;

    rec=ModelAdvisor.FactoryGroup('S-function_Checks');
    rec.DisplayName=DAStudio.message('Simulink:tools:MASFunAnalyzerTaskTitle');
    rec.Description=DAStudio.message('Simulink:tools:MASFunAnalyzerTaskTitleTips');
    rec.addCheck('mathworks.design.SFuncAnalyzer');
    mdladvRoot.publish(rec);




