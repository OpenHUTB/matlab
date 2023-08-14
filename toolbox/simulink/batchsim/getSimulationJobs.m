








function jobs=getSimulationJobs(myCluster)
    validateattributes(myCluster,{'parallel.Cluster'},{'scalar'});

    jobs=Simulink.Simulation.Job.empty;

    clusterJobs=myCluster.Jobs;
    for i=1:numel(clusterJobs)
        iJob=clusterJobs(i);
        if strcmp(iJob.ApiTag,'Created_by_batchsim')
            jobs=[jobs,Simulink.Simulation.Job(iJob)];%#ok<AGROW>
        end
    end
end
