function[bayesObj,constraintViolation,trialId]=bayesoptRunTrial(dataQueue,optVars)




    replyQueue=parallel.pool.PollableDataQueue;
    paramStruct=table2struct(optVars);
    send(dataQueue,{'createTrialRunnerForBayesopt',paramStruct,replyQueue});
    try
        trialRunner=replyQueue.poll(300);
    catch ME

        mex=ExperimentException(message('experiments:manager:WorkerDqPollTimeoutError'));
        mex=mex.addCause(ExperimentException(ME));
        mex.throw();
    end
    bayesObj=trialRunner.runTrialInParallel([]);
    assert(~isempty(trialRunner.execInfo.trialID),"The trialID value should not be empty");
    trialId=trialRunner.execInfo.trialID;
    constraintViolation=[];
end
