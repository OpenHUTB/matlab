classdef TrialRunner<experiments.internal.AbstractTrialRunner




    properties
setupFcn
input
metrics
trainingType
    end

    properties(SetAccess=immutable)
trainingPlotter
showROCCurve
    end

    methods
        function obj=TrialRunner(runLabel,expName,rngState,paramStruct,setupFcn,execInfo,curTrial,curRowData,dataQueue,snapshotDir,metrics,trainingType)

            superClsArgs.dataQueue=dataQueue;
            superClsArgs.stopDataQueue=[];
            superClsArgs.execInfo=execInfo;
            superClsArgs.curRowData=curRowData;
            superClsArgs.rngState=rngState;
            superClsArgs.paramStruct=paramStruct;
            superClsArgs.snapshotDir=snapshotDir;

            superClsArgs.execInfo.runID=curTrial.runID;
            superClsArgs.execInfo.trialID=curTrial.trialID;

            obj@experiments.internal.AbstractTrialRunner(superClsArgs);

            if isempty(dataQueue)
                obj.trainingPlotter=experiments.internal.TrainingPlotter();
            else
                obj.trainingPlotter=experiments.internal.TrainingPlotter('DataQueue',dataQueue.fork());
            end
            label=message('experiments:results:TrainingPlotLabel').getString();
            title=message('experiments:results:VisualizationLabel',label,curTrial.trialID,runLabel,expName).getString();
            obj.trainingPlotter.setTitle(title);

            obj.setupFcn=setupFcn;
            obj.metrics=metrics;
            obj.trainingType=trainingType;
            if isfield(execInfo,'showROCCurve')
                obj.showROCCurve=execInfo.showROCCurve;
            else
                obj.showROCCurve=false;
            end
            obj.input=[];
        end

        function delete(this)
            delete(this.trainingPlotter);
        end

        function panel=getPanel(this)
            panel=this.trainingPlotter.TrainingAxes;
        end

        function out=detachTrainingAxes(this)
            out=this.trainingPlotter.detachTrainingAxes();
        end

        function out=processTrainingInfo_parallel(this,info)




            if info.State=="start"
                out=false;
                return;
            end
            progress=experiments.internal.getProgress(info,this.trainingPlotter.MaxEpochs,this.trainingPlotter.MaxIterations);
            prevProgress=this.curRowData{2}.progressPercent;
            this.curRowData{2}.progressPercent=progress;
            this.curRowData{2}.executionEnvironment=this.trainingPlotter.ExecutionEnvironmentInfo;

            usesValidation=~isempty(this.input{end}.ValidationData);
            stdMetrics=experiments.internal.getStandardMetricsFromOutputFcn(info,this.trainingType,usesValidation);
            trainingAccuracyOrRMSE_indx=4+length(fieldnames(this.paramStruct));
            last_indx=trainingAccuracyOrRMSE_indx+length(stdMetrics)-1;
            this.curRowData(trainingAccuracyOrRMSE_indx:last_indx)=stdMetrics;

            elapsedTime=toc(this.execInfo.lastProgressTime);
            if prevProgress<this.curRowData{2}.progressPercent&&...
                elapsedTime>=5.0
                this.execInfo.lastProgressTime=tic;
                this.emitResultToTable();
            end

            if this.isParallel
                [~,shouldStop]=this.stopDataQueue.poll(0);
            else
                shouldStop=this.stopFunction(info.Epoch);
            end

            if shouldStop(1)


                this.stopTrial=true;
                if~this.isParallel
                    this.cancelTrial=shouldStop(2);
                end
                this.updateResult();
                out=true;
            else
                updateFreq=2;


                if(prevProgress+updateFreq)<=this.curRowData{2}.progressPercent
                    this.updateResult();
                end
                out=false;
            end
        end

        function cleanupPath=executeSetupFcn(this)
            if this.isParallel
                if this.execInfo.runBatch&&this.execInfo.trialID<1
                    loc_snapshotDir=this.snapshotDir;
                else
                    loc_snapshotDir=getAttachedFilesFolder(this.snapshotDir);
                end
                trialDir=tempname;
            else
                loc_snapshotDir=this.snapshotDir;
                trialDir=fullfile(fileparts(this.snapshotDir),['Trial_',num2str(this.execInfo.trialID)]);
            end
            if~isfolder(trialDir)
                mkdir(trialDir);
            end
            oldDir=cd(trialDir);
            oldPath=addpath(genpath(loc_snapshotDir));
            cleanupPath=onCleanup(@()resetDirAndPath(oldDir,oldPath));

            function resetDirAndPath(oldDir,oldPath)
                path(oldPath);
                cd(oldDir);
            end
            m=nargout(this.setupFcn);
            this.input=cell(1,m);
            [this.input{:}]=feval(this.setupFcn,this.paramStruct);
            this.validateInputsForTrainNetwork();
        end


        function validateInputsForTrainNetwork(this)
            import experiments.internal.ExperimentException;
            baseMEX=ExperimentException(message('experiments:manager:InvalidSetupFcnOutputs'));
            inputLen=length(this.input);
            if~(inputLen==3||inputLen==4)
                subMEX=ExperimentException(message('experiments:manager:IncorrectNumberOfSetupFcnOutputs'));
                baseMEX=baseMEX.addCause(subMEX);
                throw(baseMEX);
            end

            penultimateArgType=string(class(this.input{end-1}));
            if~any(penultimateArgType==["nnet.cnn.LayerGraph","nnet.cnn.layer.Layer"])
                subMEX=ExperimentException(message('experiments:manager:PenultimateOutputNotLayers',penultimateArgType));
                baseMEX=baseMEX.addCause(subMEX);
                throw(baseMEX);
            end

            if~isa(this.input{end},'nnet.cnn.TrainingOptions')
                subMEX=ExperimentException(message('experiments:manager:LastOutputNotTrainingOptions',class(this.input{end})));
                baseMEX=baseMEX.addCause(subMEX);
                throw(baseMEX);
            end
            if this.isParallel
                if this.execInfo.runBatch
                    mode=message('experiments:manager:ExpExectionMode_Batch_Simultaneous').getString();
                else
                    mode=message('experiments:manager:ExpExectionMode_Simultaneous').getString();
                end
                if strcmpi(this.input{end}.ExecutionEnvironment,'parallel')||...
                    strcmpi(this.input{end}.ExecutionEnvironment,'multi-gpu')
                    subMEX=ExperimentException(message('experiments:manager:InvalidTrainingOptExecEnv',this.input{end}.ExecutionEnvironment,mode));
                    baseMEX=baseMEX.addCause(subMEX);
                    throw(baseMEX);
                end
                if this.input{end}.DispatchInBackground
                    subMEX=ExperimentException(message('experiments:manager:InvalidTrainingOptDispBkgrnd',mode));
                    baseMEX=baseMEX.addCause(subMEX);
                    throw(baseMEX);
                end
            else

                if this.execInfo.runBatch
                    mode=message('experiments:manager:ExpExectionMode_Batch_Sequential').getString();
                    if strcmpi(this.input{end}.ExecutionEnvironment,'multi-gpu')
                        subMEX=ExperimentException(message('experiments:manager:InvalidTrainingOptExecEnvBatchSeq',mode));
                        baseMEX=baseMEX.addCause(subMEX);
                        throw(baseMEX);
                    end
                end
                if this.execInfo.runBatch&&...
                    this.execInfo.trialID>0&&...
                    (strcmpi(this.input{end}.ExecutionEnvironment,'parallel')||...
                    strcmpi(this.input{end}.ExecutionEnvironment,'multi-gpu'))
                    experiments.internal.PCTLicenseCheck();
                end

            end
        end

        function[workerError,currentTrialTrainingType,usesValidation]=getInputAndTrainingType(this,mockTraining)
            workerError=[];
            currentTrialTrainingType='Unknown';
            usesValidation=false;
            try
                this.executeSetupFcn();
                currentTrialTrainingType=experiments.internal.determineTrainingType(mockTraining,this.input{:});
                usesValidation=~isempty(this.input{end}.ValidationData);
            catch ME
                workerError.ME=experiments.internal.ExperimentException(ME);
                workerError.report=this.getErrorReport(workerError.ME);
            end
        end

        function result=runTrialInParallel(this,mockTraining)
            try
                this.sendStopDataQueue();


                this.sendRunningStatus();

                rng(this.rngState);


                cleanupPath=this.executeSetupFcn();
                currentTrialTrainingType=experiments.internal.determineTrainingType(mockTraining,this.input{:});
                if~strcmp(currentTrialTrainingType,this.trainingType)
                    mex=message(['experiments:manager:ErrorModifyingProblemTypeAcrossTrial_',currentTrialTrainingType],...
                    this.execInfo.trialID);
                    throw(mex);
                end


                trOpts=this.input{end};


                trOpts.Plots=this.trainingPlotter;


                if isempty(trOpts.OutputFcn)
                    trOpts.OutputFcn=@this.processTrainingInfo_parallel;
                elseif isa(trOpts.OutputFcn,'function_handle')
                    trOpts.OutputFcn={trOpts.OutputFcn,@this.processTrainingInfo_parallel};
                elseif isa(trOpts.OutputFcn,'cell')
                    trOpts.OutputFcn{end+1}=@this.processTrainingInfo_parallel;
                end
                this.input{end}=trOpts;

                if~isempty(mockTraining)
                    [nnet,trInfo]=mockTraining(this.input{:});
                else
                    [nnet,trInfo]=trainNetwork(this.input{:});
                end
            catch ME

                result=NaN;
                this.sendErrorStatus(ME);
                return;
            end
            result=this.trialPostProcessing(nnet,trInfo,currentTrialTrainingType);

        end

        function result=trialPostProcessing(this,trainedNetwork,trInfo,trainingType)
            if~this.isParallel
                val=this.stopFunction(10);
                this.stopTrial=val(1);
                this.cancelTrial=val(2);
            end
            status='Complete';
            text='';
            if this.stopTrial
                if(trInfo.OutputNetworkIteration==0||this.execInfo.isBayesOptExp||this.cancelTrial)
                    result=NaN;
                    this.sendCanceledStatus();
                    return;
                else
                    status='Stopped';
                end

            else
                if this.trainingPlotter.StopReason==nnet.internal.cnn.util.TrainingStopReason.LossIsNaN
                    text="LossIsNan";
                elseif this.trainingPlotter.StopReason==nnet.internal.cnn.util.TrainingStopReason.OutputFcn
                    text="OutputFcn";
                elseif this.trainingPlotter.StopReason==nnet.internal.cnn.util.TrainingStopReason.ValidationStopping
                    text="ValidationStopping";
                elseif this.trainingPlotter.StopReason==nnet.internal.cnn.util.TrainingStopReason.FinalIteration
                    this.curRowData{2}.progressPercent=100;
                    text="FinalIteration";
                end
            end

            this.curRowData{2}.status=status;
            this.curRowData{2}.text=text;
            this.curRowData{2}.errorText='';
            this.curRowData{2}.resultInCluster=this.execInfo.runBatch;


            usesValidation=~isempty(this.input{end}.ValidationData);
            stdMetrics=experiments.internal.getStandardMetricsFromTrainingInfo(trInfo,trainingType,usesValidation);
            trainingAccuracyOrRMSE_indx=4+length(fieldnames(this.paramStruct));
            last_indx=trainingAccuracyOrRMSE_indx+length(stdMetrics)-1;
            this.curRowData(trainingAccuracyOrRMSE_indx:last_indx)=stdMetrics;


            import experiments.internal.ExperimentException;
            trialInfo.trainedNetwork=trainedNetwork;
            trialInfo.trainingInfo=trInfo;
            trialInfo.parameters=this.paramStruct;
            for i=1:length(this.metrics)
                indx=i+last_indx;
                try
                    val=feval(this.metrics(i).name,trialInfo);
                    outputClass=class(val);

                    if ischar(val)
                        val=string(val);
                    end
                    if~isscalar(val)
                        ME=ExperimentException(message('experiments:editor:MetricEvalErrorDim',this.metrics(i).name));
                        throw(ME);
                    end
                    if isfi(val)
                        ME=ExperimentException(message('experiments:editor:MetricEvalErrorFixPointType',this.metrics(i).name));
                        throw(ME);
                    end
                    if iscell(val)||~(isstring(val)||isnumeric(val)||isenum(val)||islogical(val))
                        ME=ExperimentException(message('experiments:editor:MetricEvalErrorType',this.metrics(i).name));
                        throw(ME);
                    end
                    if isempty(this.metrics(i).type)
                        this.metrics(i).type=outputClass;
                        this.updateStdMetrics(this.metrics);
                    end
                    if~strcmp(this.metrics(i).type,outputClass)
                        ME=ExperimentException(message('experiments:editor:MetricEvalErrorTypeMismatch',...
                        this.metrics(i).name,this.metrics(i).type,outputClass));
                        throw(ME);
                    end
                    data=val;
                catch ME
                    causeME=ExperimentException(message('experiments:editor:MetricEvalError',this.metrics(i).name));
                    causeME=causeME.addCause(ExperimentException(ME));
                    errorText=causeME.getReport();
                    data=struct('value',0,'error',errorText,'state','error');
                end
                this.curRowData{indx}=data;
            end

            try
                XVal=[];
                TVal=[];
                Xt=[];
                Tt=[];
                errorFromSdk='';
                if(~isempty(this.input{end}.ValidationData))
                    [Xt,Tt,XVal,TVal]=deep.internal.sdk.trainNetwork.extractInputsAndResponses(this.input{:});
                else
                    [Xt,Tt]=deep.internal.sdk.trainNetwork.extractInputsAndResponses(this.input{:});
                end
            catch ME
                errorFromSdk=ME.identifier;
            end

            [cmValidationData.matrixForValidationData,...
            cmValidationData.truePredictedLabelsForValidation,...
            cmValidationData.falsePositiveRatesArrayForValidation,...
            cmValidationData.truePositiveRatesArrayForValidation,...
            cmValidationData.thresholdsArrayForValidation,...
            cmValidationData.aucArrayForValidation,...
            cmValidationData.errorLabelConfusionMatrixValidation,...
            cmValidationData.errorLabelROCCurveValidation]=experiments.internal.generateConfusionMatrixAndROCData(trainedNetwork,XVal,TVal,trainingType,errorFromSdk);

            cmValidationData.orderForValidation=cmValidationData.truePredictedLabelsForValidation;

            [cmTrainingData.matrixForTrainingData,...
            cmTrainingData.truePredictedLabelsForTraining,...
            cmTrainingData.falsePositiveRatesArrayForTraining,...
            cmTrainingData.truePositiveRatesArrayForTraining,...
            cmTrainingData.thresholdsArrayForTraining,...
            cmTrainingData.aucArrayForTraining,...
            cmTrainingData.errorLabelConfusionMatrix,...
            cmTrainingData.errorLabelROCCurve]=experiments.internal.generateConfusionMatrixAndROCData(trainedNetwork,Xt,Tt,trainingType,errorFromSdk);

            cmTrainingData.orderForTraining=cmTrainingData.truePredictedLabelsForTraining;

            if this.execInfo.isBayesOptExp
                assert(~isempty(this.execInfo.OptimizableMetricData));
                optMtrx=this.execInfo.OptimizableMetricData(1);
                isMinimize=this.execInfo.OptimizableMetricData(2);
                result=this.curRowData{optMtrx{1}+trainingAccuracyOrRMSE_indx};

                if strcmp(isMinimize{1},'Maximize')
                    result=-result;
                end
            else
                result=NaN;
            end

            trialOutput.validationData=cmValidationData;
            trialOutput.trainingData=cmTrainingData;
            trialOutput.nnet=trainedNetwork;
            trialOutput.trInfo=trInfo;

            this.sendTrialOutput(trialOutput);
        end
    end
end

