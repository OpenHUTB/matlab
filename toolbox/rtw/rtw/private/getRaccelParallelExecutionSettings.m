function ret=getRaccelParallelExecutionSettings(model)







    ret=[];

    NumParNodes=length(get_param(model,'ParallelExecutionNodeHandles'));
    hasParForEach=(NumParNodes>0);
    ParallelExecution=(hasParForEach||...
    (slfeature('ParallelExecutionInRapidAccelerator')>0));




    NumThreads=min(feature('numcores'),maxNumCompThreads);

    ParallelSimulatorType=slfeature('ParallelExecutionInRapidAccelerator');


    ret.ParallelExecution=num2str(ParallelExecution);
    ret.NumThreads=num2str(NumThreads);
    ret.NumParNodes=num2str(NumParNodes);
    ret.ParallelSimulatorType=num2str(ParallelSimulatorType);
