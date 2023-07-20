function taskingMode=getTaskingMode(h,modelName)




    acs=getActiveConfigSet(modelName);
    taskingMode=getProp(acs,'SolverMode');
