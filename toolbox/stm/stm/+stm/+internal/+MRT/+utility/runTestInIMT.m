function results=runTestInIMT(workerName,workerRoot,resultSetRoot,...
    testInfoArray)





    pool=stm.internal.MRT.mrtpool.getInstance;
    pool.addWorker(workerName,workerRoot,pwd);

    infoPath=fullfile(resultSetRoot,'TestInfo',workerName);
    if(~exist(infoPath,'dir'))
        mkdir(infoPath);
    end
    infoFile=[tempname(infoPath),'.mat'];
    save(infoFile,'testInfoArray');

    params={resultSetRoot,infoPath,infoFile};
    paramStr=join(params,''',''');
    cmdStr=['results = multiReleaseTestRunOneTest(''',paramStr{1},''');'];

    workerId=pool.findWorkerByPath(workerRoot);
    imtHarnessRoot=fullfile(matlabroot,'toolbox','stm','stm','MultiReleaseExecHarness');
    results=pool.run(workerId,cmdStr,{'results'},true,{imtHarnessRoot});
end




