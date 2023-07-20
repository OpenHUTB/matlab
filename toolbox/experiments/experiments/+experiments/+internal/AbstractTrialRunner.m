classdef(Abstract)AbstractTrialRunner<handle




    properties
dataQueue
stopDataQueue
execInfo
curRowData
rngState
paramStruct
snapshotDir
        stopTrial=false
        cancelTrial=false
msgFunction
stopFunction
isParallel
    end

    methods
        function obj=AbstractTrialRunner(args)
            obj.dataQueue=args.dataQueue;
            obj.stopDataQueue=[];
            obj.execInfo=args.execInfo;
            obj.curRowData=args.curRowData;
            obj.rngState=args.rngState;
            obj.paramStruct=args.paramStruct;
            obj.snapshotDir=args.snapshotDir;
            obj.msgFunction=[];
            obj.stopFunction=[];
            obj.isParallel=~isempty(args.dataQueue);
        end

        function sendStopDataQueue(this)
            if~this.isParallel
                return;
            end



            if isempty(this.stopDataQueue)



                this.stopDataQueue=parallel.pool.PollableDataQueue;
            end
            this.sendMessage({'stopDataQueue',...
            this.execInfo.runID,...
            this.execInfo.trialID,...
            this.stopDataQueue});
        end

        function sendRunningStatus(this)
            this.curRowData{2}.status='Running';

            if this.isParallel
                workerName=experiments.internal.getWorkerName;
                this.curRowData{2}.workerName=workerName;
            end

            trialCompletionTime=struct('startTime',experiments.internal.getCurrentTimeString(),'completionTime','');
            this.curRowData{3}=trialCompletionTime;
            this.updateResult();
        end

        function updateResult(this)
            res.rowInd=this.execInfo.trialID-1;
            res.rowData=this.curRowData;
            this.sendMessage({'savetodisk',...
            this.execInfo.runID,...
            this.execInfo.trialID,...
            res});
        end

        function emitResultToTable(this)
            res.rowInd=this.execInfo.trialID-1;
            res.rowData=this.curRowData;
            this.sendMessage({'emittotable',...
            this.execInfo.runID,...
            this.execInfo.trialID,...
            res});
        end

        function sendErrorStatus(this,ME1)
            ME=experiments.internal.ExperimentException(ME1);
            this.curRowData{2}.status='Error';
            this.curRowData{2}.errorText=this.getErrorReport(ME);

            res.rowInd=this.execInfo.trialID-1;
            res.rowData=this.curRowData;

            sendData.runID=this.execInfo.runID;
            sendData.trialID=this.execInfo.trialID;
            sendData.res=res;
            this.sendMessage({'saveAndCleanupTrialRunner',...
            this.execInfo.runID,...
            this.execInfo.trialID,...
            sendData});
        end

        function sendCanceledStatus(this)
            this.curRowData{2}.status='Canceled';
            this.curRowData{2}.errorText='';
            this.curRowData{2}.progressPercent=0;

            res.rowInd=this.execInfo.trialID-1;
            res.rowData=this.curRowData;

            sendData.runID=this.execInfo.runID;
            sendData.trialID=this.execInfo.trialID;
            sendData.res=res;
            this.sendMessage({'saveAndCleanupTrialRunner',...
            this.execInfo.runID,...
            this.execInfo.trialID,...
            sendData});
        end

        function sendTrialOutput(this,sendData)
            res.rowInd=this.execInfo.trialID-1;
            res.rowData=this.curRowData;

            sendData.runID=this.execInfo.runID;
            sendData.trialID=this.execInfo.trialID;
            sendData.paramList=fieldnames(this.paramStruct);
            sendData.res=res;
            this.sendMessage({'saveAndCleanupTrialRunner',...
            this.execInfo.runID,...
            this.execInfo.trialID,...
            sendData});
        end

        function updateStdMetrics(this,metrics)
            this.sendMessage({'updateMetricsConfig',...
            this.execInfo.runID,...
            this.execInfo.trialID,...
            metrics});
        end

        function sendMessage(this,msg)
            if~this.isParallel
                this.msgFunction(msg);
            else
                this.dataQueue.send(msg);
            end
        end

        function report=getErrorReport(this,ME)
            if this.isParallel
                snapshotPath=getAttachedFilesFolder(this.snapshotDir);
                report=experiments.internal.getErrorReport(ME,'SnapshotPath',snapshotPath,'RunID',this.execInfo.runID);
            else
                report=experiments.internal.getErrorReport(ME,'ProjectPath',experiments.internal.JSProjectService.getCurrentProjectPath());
            end
        end

        function setStopOnMonitor(~)
        end
    end

    methods(Abstract)
        runTrialInParallel(this);
    end
end
