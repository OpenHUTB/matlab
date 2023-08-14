function multiReleaseTestWrapper(multiReleaseResultSetRoot,...
    releaseTestInfoRoot,workerIdx)



    persistent hrnsPathAdded
    persistent cachedFolder
    if isempty(hrnsPathAdded)
        hrnsRoot=fileparts(mfilename('fullpath'));
        addpath(hrnsRoot);
        addpath(fullfile(hrnsRoot,'testphases'));
        hrnsPathAdded=1;
    end

    runningFolder=fullfile(multiReleaseResultSetRoot,'Running');
    completedFolder=fullfile(multiReleaseResultSetRoot,'Completed');
    workerfolder=fullfile(multiReleaseResultSetRoot,'Workers');



    addpath(releaseTestInfoRoot);

    if isempty(cachedFolder)
        cachedFolder=tempname;
        mkdir(cachedFolder);
        try
            set_param(0,'CacheFolder',cachedFolder);
            set_param(0,'CodeGenFolder',cachedFolder);
        catch
        end

    end

    logFile=fullfile(workerfolder,sprintf('worker_%d.log',workerIdx));
    logFid=fopen(logFile,'w');

    try
        stopSignFile=fullfile(workerfolder,'STOP');
        workerStartFile=fullfile(workerfolder,sprintf('worker_%d.START',workerIdx));
        fid=fopen(workerStartFile,'w');
        fclose(fid);


        infoFileMap=containers.Map;
        testInfoFiles={};
        if(exist('testTree.mat','file'))
            exePkg=load('testTree.mat');
            for testK=1:numel(exePkg.testTree.ExecutionIdList)
                testId=exePkg.testTree.ExecutionIdList(testK);
                exeCmd=exePkg.testTree.ExecutionCmdList(testK);
                if(exeCmd==3)
                    infoFile=sprintf('TestInfoHook_%d.m',testId);
                elseif(exeCmd==1)
                    infoFile=sprintf('TestInfoHook_%d_cb1.m',testId);
                elseif(exeCmd==2)
                    infoFile=sprintf('TestInfoHook_%d_cb2.m',testId);
                end
                if(exist(infoFile,'file'))
                    testInfoFiles{end+1}=infoFile;
                    infoFileMap(infoFile)=1;
                end
            end
        end

        allFiles=dir('TestInfoHook*.m');
        tmpInfoFiles={allFiles.name};
        for k=1:numel(tmpInfoFiles)
            if(~infoFileMap.isKey(tmpInfoFiles{k}))
                testInfoFiles{end+1}=tmpInfoFiles{k};
            end
        end


        for testK=1:numel(testInfoFiles)
            if(exist(stopSignFile,'file'))
                break;
            end
            [~,testInfoFile]=fileparts(testInfoFiles{testK});
            testInfoArray=eval(testInfoFile);

            fprintf(logFid,'%s %d\n',testInfoFile,numel(testInfoArray));
            for ii=1:numel(testInfoArray)
                fprintf(logFid,'%d %s\n',testInfoArray{ii}.ResultID,testInfoArray{ii}.STMTestName);


                bIsTestSuite=testInfoArray{ii}.IsTestSuite;
                if(exist(stopSignFile,'file'))
                    break;
                end
                if(~bIsTestSuite)
                    runningIcon=fullfile(runningFolder,sprintf('%d',testInfoArray{ii}.ResultID));
                    fid=fopen(runningIcon,'w');
                    fclose(fid);
                end

                TestResult=MRTHarness('MultiReleaseTesting',...
                ii,...
                testInfoArray{ii},...
                pwd,...
                workerIdx);
                if(bIsTestSuite)
                    tsCmd=testInfoArray{ii}.TestSuiteCMD;
                    tsOutputLoc=fullfile(multiReleaseResultSetRoot,...
                    ['TestSuiteResult_',sprintf('%d',testInfoArray{ii}.ResultID)]);

                    runMatFile=fullfile(tsOutputLoc,['TestResult_',tsCmd,'.mat']);
                    if(exist(tsOutputLoc,'dir'))
                        save(runMatFile,'TestResult');
                    end
                else
                    simIndex=testInfoArray{ii}.SimulationIndex;
                    simOutputLoc=fullfile(multiReleaseResultSetRoot,...
                    ['TestCaseResult_',sprintf('%d',testInfoArray{ii}.ResultID)],...
                    sprintf('PermutationOutput_%d',simIndex));

                    runMatFile=fullfile(simOutputLoc,'TestResult.mat');
                    if(exist(simOutputLoc,'dir'))
                        save(runMatFile,'TestResult');
                    end

                    completeIcon=fullfile(completedFolder,sprintf('%d',testInfoArray{ii}.ResultID));
                    if(testInfoArray{ii}.EquivalenceTestStatus>=3)
                        completeIcon=fullfile(completedFolder,sprintf('%d_%d',...
                        testInfoArray{ii}.ResultID,testInfoArray{ii}.SimulationIndex));
                    end
                    fid=fopen(completeIcon,'w');
                    fclose(fid);
                end
            end
        end
        writeWorkerEndFile(workerfolder,workerIdx);

    catch err %#ok<*CTCH>

        fprintf(logFid,'%s\n',err.message);

        IMTDisplayMessage(lasterr);%#ok<*LERR>
        writeWorkerEndFile(workerfolder,workerIdx);
    end
    fclose(logFid);


    IMT_PostHarnessAutoTestCleanup();



end

function writeWorkerEndFile(workerfolder,workerIdx)
    workerEndFile=fullfile(workerfolder,sprintf('worker_%d.END',workerIdx));
    fid=fopen(workerEndFile,'w');
    fclose(fid);
end


