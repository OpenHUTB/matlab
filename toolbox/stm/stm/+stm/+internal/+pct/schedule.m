function errorId=schedule(bWorkersCreated,resultSetID,tcIdList,...
    tciIdList,tcrIdList,rootPathList)



    errorId='';


    closePool=bWorkersCreated;
    pool=gcp('nocreate');


    if isempty(pool)
        pool=createPool();
        closePool=true;
    end

    cleanupPool=onCleanup(@()shutdownPool(closePool));

    try
        scheduleHelper(pool,resultSetID,tcIdList,tciIdList,tcrIdList,rootPathList);
    catch me
        errorId=me.identifier;
    end
end

function scheduleHelper(pool,resultSetID,tcIdList,tciIdList,tcrIdList,rootPathList)
    cleanupWordersHandle=onCleanup(@()cleanupWorkers());


    testDBLocation=stm.internal.getRepositoryLocation();
    setupWorkers(pool,resultSetID,testDBLocation);

    nWorkers=min(pool.NumWorkers,length(tcrIdList));
    stm.internal.initWorkerStatus(resultSetID,nWorkers);

    doBatchSchedule(tcIdList,tciIdList,tcrIdList,rootPathList);

    stm.internal.processPCTResults(resultSetID);
end

function shutdownPool(closePool)
    if closePool
        pool=gcp('nocreate');
        if(~isempty(pool))
            delete(pool);
        end
    end
end

function pool=createPool()
    pool=parpool(parallel.defaultProfile);
end

function doBatchSchedule(tcIdList,tciIdList,tcrIdList,rootPathList)
    pool=gcp('nocreate');

    tcr=arrayfun(@(id)sltest.testmanager.TestResult.getResultFromID(id),...
    tcrIdList,'Uniform',false);
    nTests=length(tcrIdList);
    testList=cell(nTests,1);
    for idx=1:nTests
        testList{idx}={tcrIdList(idx),rootPathList{idx},tcIdList(idx),...
        tciIdList(idx),tcr{idx}.ResultUUID};
    end

    if pool.NumWorkers>nTests

        for idx=1:nTests
            parfeval(pool,@stm.internal.scheduleTasks,0,testList(idx,:),idx);
        end
    else
        batchSize=floor(length(tcrIdList)/pool.NumWorkers);
        startIndex=1;
        for idx=1:pool.NumWorkers
            if idx==pool.NumWorkers
                tempList=testList(startIndex:end,:);
            else
                tempList=testList(startIndex:startIndex+batchSize-1,:);
            end
            parfeval(pool,@stm.internal.scheduleTasks,0,tempList,idx);
            startIndex=startIndex+batchSize;
        end
    end
end

function setupWorkers(pool,resultSetID,dbLocation)

    payloadStruct=struct('VirtualChannel','Results/Initializing/Workers','Payload',struct());
    message.publish('/stm/messaging',payloadStruct);
    parfevalOnAll(pool,@setupWorker,0,resultSetID,dbLocation,slfeature('AssessmentRunInCustomCriteria'));
end

function cleanupWorkers()

    pool=gcp('nocreate');
    if(~isempty(pool))
        parfevalOnAll(pool,@cleanupWorker,0);
    end

end


function setupWorker(resultSetID,dbLocation,assessmentsFeature)
    start_simulink();
    stm.internal.setupEnvironment(resultSetID,dbLocation);
    slfeature('AssessmentRunInCustomCriteria',assessmentsFeature);
end

function cleanupWorker()
    stm.internal.cleanupEnvironment();
end
