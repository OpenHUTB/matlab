function runBatchJob(javaDefinition,javaListener,javaTerminator)






    import Simulink.ModelManagement.Project.BatchJob.Runners.GeneralBatchJobRunner;
    import Simulink.ModelManagement.Project.BatchJob.JavaImpl.*;


    definition=JavaDefinitionAdapter(javaDefinition);
    listener=JavaListenerAdapter(javaListener);
    terminator=JavaTerminatorAdapter(javaTerminator);


    runner=GeneralBatchJobRunner;
    runner.run(definition,listener,terminator);

end

