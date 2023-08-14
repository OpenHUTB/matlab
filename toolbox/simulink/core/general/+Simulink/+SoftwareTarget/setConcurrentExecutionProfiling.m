function setConcurrentExecutionProfiling(modelName,profilingFlag,numSamples)







    load_system(modelName);
    mgr=get_param(modelName,'MappingManager');
    mapping=mgr.getActiveMappingFor('DistributedTarget');
    profReport=mapping.ProfileReport;
    profReport.ProfileGenCode=profilingFlag;
    profReport.ProfileNumSamples=num2str(numSamples);
end
