









function simJob=createSimulationJob(parallelJob)
    validateattributes(parallelJob,{'parallel.Job'},{'scalar'});

    if~strcmp(parallelJob.ApiTag,Simulink.Simulation.Job.JobTag)
        error(message('Simulink:batchsim:InvalidJob'));
    end

    simJob=Simulink.Simulation.Job(parallelJob);
end
