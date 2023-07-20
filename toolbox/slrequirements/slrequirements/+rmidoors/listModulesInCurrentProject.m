function[modulesInfo,currentProject]=listModulesInCurrentProject()




    currentProject='';
    modulesInfo=[];

    hDOORS=rmidoors.comApp();
    if isempty(hDOORS)
        return;
    end

    currentProject=rmidoors.currentProject(hDOORS);
    if isempty(currentProject)
        return;
    end

    modulesInfo=rmidoors.listModules(currentProject);
end
