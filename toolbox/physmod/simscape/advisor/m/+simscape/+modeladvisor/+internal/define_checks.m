function[checkFcn,taskFcn]=define_checks






    checkFcn=@registerModelAdvisorChecks;
    taskFcn=@registerModelAdvisorTasks;
end



function registerModelAdvisorChecks



    check1=checkParameterUnits('check');


    check2=checkOutdatedBlocks('check');


    check3=checkDryHydraulicNodes('check');


    register_simscape_product_checks({check1,check2,check3});




    register_physmod_task_checks({check1,check3});

    mdlAdvisor=ModelAdvisor.Root;



    mdlAdvisor.register(checkOutdatedPSBlocks('check'));
    mdlAdvisor.register(checkUnspecifiedEventVariables('check'));
    mdlAdvisor.register(checkDaesscAsAutoSolver('check'));
    mdlAdvisor.register(checkConsistencySolver('check'));
    if matlab.internal.feature("SimscapeLegacyBlockAdvisor")
        mdlAdvisor.register(checkLegacyBlocks('check'));
    end
end


function registerModelAdvisorTasks


    mdlAdvisor=ModelAdvisor.Root;
    upgAdvisor=UpgradeAdvisor;


    mdlAdvisor.register(checkParameterUnits('task'));


    mdlAdvisor.register(checkOutdatedBlocks('task'));


    mdlAdvisor.register(checkDryHydraulicNodes('task'));


    outdatedPSBlocksTask=checkOutdatedPSBlocks('task');
    mdlAdvisor.register(outdatedPSBlocksTask);
    upgAdvisor.addTask(outdatedPSBlocksTask);

    unspecifiedEventVarsTask=checkUnspecifiedEventVariables('task');
    mdlAdvisor.register(unspecifiedEventVarsTask);
    upgAdvisor.addTask(unspecifiedEventVarsTask);

    checkDaesscAsAutoSolverTask=checkDaesscAsAutoSolver('task');
    mdlAdvisor.register(checkDaesscAsAutoSolverTask);
    upgAdvisor.addTask(checkDaesscAsAutoSolverTask);

    checkConsistencySolverTask=checkConsistencySolver('task');
    mdlAdvisor.register(checkConsistencySolverTask);
    upgAdvisor.addTask(checkConsistencySolverTask);

    if matlab.internal.feature("SimscapeLegacyBlockAdvisor")
        legacyBlocksTask=checkLegacyBlocks('task');
        mdlAdvisor.register(legacyBlocksTask);
        upgAdvisor.addTask(legacyBlocksTask);
    end
end
