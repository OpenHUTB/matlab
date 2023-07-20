classdef ExecutionUtils




    methods(Static)
        function[runInfo,expInputList]=initializeRunInfo(service,expDef)
            import experiments.internal.ExperimentException
            runInfo.expName=expDef.Name;
            runInfo.uuid=char(matlab.lang.internal.uuid());
            runInfo.indexOfBestFromBayesopt='';
            runInfo.expDescription=expDef.Description;
            runInfo.startTime=experiments.internal.getCurrentTimeString();
            runInfo.expId=expDef.ExperimentId;
            [runInfo.runID,runInfo.runLabel]=service.getNewRunID(runInfo.expName,...
            runInfo.expId);

            runInfo.paramList={};
            runInfo.snapshotExperimentID='';
            runInfo.data={};
            runInfo.trainingType='Unknown';
            runInfo.usesValidation=false;

            if exist(service.getResultsDir(),'dir')
                [~,values]=fileattrib(service.getResultsDir());
                if values.UserWrite==0
                    readOnlyResultME=ExperimentException(message('experiments:manager:readOnlyResult'));
                    throw(readOnlyResultME);
                end
            end

            service.createRunDir(runInfo.runID);
            snapshotDir=service.createSnapshotDir(runInfo.runID);
            [snapshotExperiment,snapshotExperimentPath]=service.saveExpDefForRun(expDef,snapshotDir);
            runInfo.snapshotExperimentID=snapshotExperiment.ExperimentId;
            runInfo.snapshotExperimentPath=snapshotExperimentPath;
            runInfo.colValues=struct('Col_Status',["Running","Queued","Stopped","Error","Complete","Canceled","Discarded"]);

            [runInfo,expInputList]=snapshotExperiment.validate(runInfo);
            if~isempty(runInfo.error)
                service.rsSetRun(runInfo);

                return;
            end


            runInfo.RNGState=rng();


            try
                [snapshotDir,snapshotFiles]=service.createSnapshotFolderAndCopyDependencies(runInfo.runID,expDef);
            catch ME
                snapshotErrorME=ExperimentException(message('experiments:editor:SnapshotError',expDef.Name));
                snapshotErrorME=snapshotErrorME.addCause(ExperimentException(ME));
                runInfo.error=service.getErrorReport(snapshotErrorME);

                service.rsSetRun(runInfo);
                return;
            end
            runInfo.snapshotFiles=snapshotFiles;

            if service.feature.captureWorkerInfo
                runInfo.runInParallel=service.parallelToggleOn;

                [cpuInfo,gpuInfo]=experiments.internal.saveMachineInfo(false);

                clusterInfo=[];
                workerInfo=[];

                if service.parallelToggleOn

                    pool=gcp;
                    cluster=pool.Cluster;

                    clusterInfo=struct('Type',cluster.Type,'Host',cluster.Host,'NumWorkers',cluster.NumWorkers);


                    allWorkerInfoFuture=parfevalOnAll(@experiments.internal.saveMachineInfo,2,true);
                    wait(allWorkerInfoFuture);
                    [allWorkerCPUInfo,allWorkerGPUInfo]=fetchOutputs(allWorkerInfoFuture);
                    workerInfo.cpuInfo=allWorkerCPUInfo;
                    workerInfo.gpuInfo=allWorkerGPUInfo;
                end

                save([snapshotDir,filesep,'environmentInfo.mat'],'cpuInfo','gpuInfo','clusterInfo','workerInfo');
            end
        end

    end
end
