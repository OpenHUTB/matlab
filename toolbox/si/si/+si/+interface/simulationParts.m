function[projectDir,simulationStateDir,simulationDir,simName,ext]=simulationParts(simulationFile)





    [simulationDir,simName,ext]=fileparts(simulationFile);
    projectDir=simulationDir;
    lastDir=simName;
    simulationStateDir=[];
    while~strcmp(lastDir,"interfaces")
        [projectDir,lastDir]=fileparts(projectDir);
        if isempty(projectDir)
            error(message('si:apps:projectNotFound',simulationFile))
        end
        if string(projectDir).endsWith(".ssm")
            simulationStateDir=projectDir;
        end
    end
    if isempty(simulationStateDir)
        error(message('si:apps:stateNotFound',simulationFile))
    end
end

