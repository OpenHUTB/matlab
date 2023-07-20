function MultiReleaseTestLauncher(testTrees,releaseNames,releaseLocations,outputRoot)




    harnessRoot=fullfile(matlabroot,'toolbox','stm','stm','MultiReleaseExecHarness');

    testInfoRoot=fullfile(outputRoot,'TestInfo');
    if(exist(testInfoRoot,'dir')==7)
        try
            rmdir(testInfoRoot,'s');
        catch
        end
    end
    mkdir(testInfoRoot);

    for treek=1:length(testTrees)

        releaseName=testTrees(treek).releaseName;
        if(isempty(releaseName))
            continue;
        end
        infoFileRoot=fullfile(outputRoot,'TestInfo',releaseName);
        if(~exist(infoFileRoot,'dir'))
            mkdir(infoFileRoot);
        end


        oFile=fullfile(infoFileRoot,'testTree.mat');
        testTree=testTrees(treek);
        save(oFile,'testTree');


        stm.internal.MRT.utility.createSimulationSetting(testTree,outputRoot);


        status=stm.internal.MRT.utility.createTestInfoHook(testTree,outputRoot);
        if~status
            disp(lasterr);
            continue;
        end
    end


    pool=stm.internal.MRT.mrtpool.getInstance;

    currDir=pwd;
    workerfolder=fullfile(outputRoot,'Workers');
    stopSignFile=fullfile(workerfolder,'STOP');


    pathsToAdd=stm.internal.MRT.utility.getUserAddedPathEntries();

    f1=get_param(0,'CacheFolder');
    pathsToAdd(strcmp(pathsToAdd,f1))=[];
    pathsToAdd{end+1}=harnessRoot;


    for rk=1:length(releaseNames)
        releaseName=releaseNames{rk};
        infoFileRoot=fullfile(outputRoot,'TestInfo',releaseName);
        assert(exist(infoFileRoot,'dir')>0);

        if(exist(stopSignFile,'file'))
            break;
        end

        releaseMLRoot=releaseLocations{rk};

        pool.addWorker(releaseName,releaseMLRoot,currDir);
        workerId=pool.findWorkerByPath(releaseMLRoot);

        script=['multiReleaseTestWrapper(''',outputRoot,''',''',infoFileRoot,''',',num2str(rk),');'];
        pool.run(workerId,script,{},false,pathsToAdd);
    end
end

