function job=submit2PCT(simulationFiles,clusterId)








    if nargin>1
        cluster=parcluster(clusterId);
    else
        cluster=parcluster;
    end
    simJob=createJob(cluster);
    for idx=1:numel(simulationFiles)
        simulationFilePath=simulationFiles{idx};


        simulationFile=java.io.File(simulationFilePath);
        if~simulationFile.isAbsolute
            simulationFile=java.io.File(pwd,simulationFilePath);
            simulationFilePath=string(simulationFile.getCanonicalPath);
        end
        createTask(simJob,@si.interface.runSimulationEngine,0,{simulationFilePath,false});
    end
    submit(simJob)
    if nargout>0
        job=simJob;
    end
end