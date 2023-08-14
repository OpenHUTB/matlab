function[taskInfo,numTasks,isDeploymentDiagram]=getExtModeTaskInfo(buildDir,taskInfoFile)


    if exist(fullfile(buildDir,taskInfoFile),'file')
        currentDir=pwd;
        restoreDir=onCleanup(@()cd(currentDir));
        cd(buildDir);
        [taskInfo,numTasks,isDeploymentDiagram]=feval(taskInfoFile);
        clear restoreDir
    else
        taskInfo=0;
        numTasks=0;
        isDeploymentDiagram=0;
    end

end
