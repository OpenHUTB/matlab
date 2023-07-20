function taskCellArray=defineModelAdvisorTasks







    taskCellArray={};
    mdladvRoot=ModelAdvisor.Root;

    rec=ModelAdvisor.FactoryGroup('Units_Inconsistencies');
    rec.DisplayName=DAStudio.message('Simulink:tools:MAUnitInconsTaskTitle');
    rec.Description=DAStudio.message('Simulink:tools:MAUnitInconsTaskTitleTips');
    rec.addCheck('mathworks.design.UnitMismatches');
    rec.addCheck('mathworks.design.AutoUnitConversions');
    rec.addCheck('mathworks.design.DisallowedUnitSystems');
    rec.addCheck('mathworks.design.UndefinedUnits');
    rec.addCheck('mathworks.design.AmbiguousUnits');
    mdladvRoot.publish(rec);




