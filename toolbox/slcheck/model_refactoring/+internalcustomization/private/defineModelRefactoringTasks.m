function defineModelRefactoringTasks()
    mdladvRoot=ModelAdvisor.Root;




    rec=ModelAdvisor.FactoryGroup('Model Refactoring Checks');
    rec.DisplayName=DAStudio.message('sl_cloneDetection_edittime:messages:libPattern_edittime_taskName');
    rec.Description=DAStudio.message('sl_cloneDetection_edittime:messages:libPattern_edittime_Action_Description');
    rec.addCheck('mathworks.m2m_edittime.BusPortsXform');
    rec.addCheck('mathworks.cloneDetection.libraryEdittime');
    rec.Value=true;
    mdladvRoot.publish(rec);
end