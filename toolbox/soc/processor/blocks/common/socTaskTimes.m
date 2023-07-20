function out=socTaskTimes(modelName,SDIRun,varargin)





























    suppressPlot=false;
    narginchk(2,3);
    if(nargin==3)
        opt=string(varargin{1});
        suppressPlot=isequal(opt,"SuppressPlot");
        if~suppressPlot
            error(message('soc:scheduler:SOCTaskTimesInvalidArg'));
        end
    end
    mgrBlks=soc.internal.connectivity.getTaskManagerBlock(modelName);
    if~iscell(mgrBlks),mgrBlks={mgrBlks};end
    out=[];
    for i=1:numel(mgrBlks)
        if isequal(get_param(mgrBlks{i},'EnableTaskSimulation'),'on')
            out1=locProcessPUs(modelName,mgrBlks{i},SDIRun,suppressPlot);
            out=[out,out1];%#ok<AGROW>
        end
    end
end


function out=locProcessPUs(modelName,mgrBlk,SDIRun,suppressPlot)
    test=soc.internal.TaskExecutionTester(modelName,mgrBlk);
    if~iscell(SDIRun),SDIRun={SDIRun};end
    if(numel(SDIRun)>1)
        error(message('soc:scheduler:SOCTaskTimesTooManySDIRuns'));
    end
    test.SDIRuns=SDIRun;
    allResults=test.run;
    for i=1:numel(allResults)
        thisResult=allResults{i};
        thisStruct.Name=thisResult.Task;
        data=thisResult.Run1Data;
        thisStruct.Duration=data.Durations;
        thisStruct.StartTime=data.StartTimes;
        thisStruct.EndTime=data.EndTimes;
        thisStruct.Mean=mean(thisStruct.Duration);
        thisStruct.MaxDuration=max(thisStruct.Duration);
        thisStruct.MinDuration=min(thisStruct.Duration);
        thisStruct.StandardDeviation=std(thisStruct.Duration);
        thisStruct.Turnaround=thisStruct.EndTime-thisStruct.StartTime;
        thisStruct.MeanTurnaround=mean(thisStruct.Turnaround);
        thisStruct.MaxTurnaround=max(thisStruct.Turnaround);
        thisStruct.MinTurnaround=min(thisStruct.Turnaround);

        dropInfo=getDropRate(thisResult.Task,modelName,mgrBlk,SDIRun);
        thisStruct.NumDropped=dropInfo.numDropped;
        thisStruct.PercentDropped=dropInfo.droppedRate;
        thisStruct.DropTime=dropInfo.droppedTime;

        overrunInfo=getOverrunRate(thisResult.Task,thisStruct.DropTime,modelName,mgrBlk,SDIRun);
        thisStruct.NumOverran=overrunInfo.numOverran;
        thisStruct.PercentOverran=overrunInfo.percentOverran;
        thisStruct.OverrunTime=overrunInfo.overrunTimes';
        out(i)=thisStruct;%#ok<AGROW>
        if~suppressPlot
            figure;
            histogram(data.Durations,'BinMethod','fd',...
            'Normalization','probability');
            title('Histogram of task duration');
            ylabel('P');
            xlabel('duration (s)');
            f=gcf;
            f.Name=thisResult.Task;
        end
    end
end


function info=getDropRate(taskName,modelName,mgrBlk,SDIRun)
    import soc.internal.connectivity.*
    import soc.internal.sdi.*
    allTaskData=get_param(mgrBlk,'AllTaskData');
    taskMgrData=soc.internal.TaskManagerData(allTaskData,'evaluate',modelName);
    taskData=taskMgrData.getTask(taskName);
    run=getRun(SDIRun{1});
    dropSigSDIData=getSignalData(run.id,[taskName,'_drop']);
    info.numDropped=int32(numel(dropSigSDIData.Time));
    info.droppedTime=[];
    info.droppedRate=NaN;
    if isequal(taskData.taskType,'Timer-driven')
        stopTime=str2double(get_param(modelName,'StopTime'));
        period=taskData.taskPeriod;
        numExpected=floor(stopTime/period);
        if~isequal(numExpected,0)
            info.droppedTime=dropSigSDIData.Time;
            info.droppedRate=100*double(info.numDropped)/numExpected;
        end
    end
end


function info=getOverrunRate(taskName,dropTimes,modelName,mgrBlk,SDIRun)
    import soc.internal.connectivity.*
    import soc.internal.sdi.*
    allTaskData=get_param(mgrBlk,'AllTaskData');
    taskMgrData=soc.internal.TaskManagerData(allTaskData,'evaluate',modelName);
    taskData=taskMgrData.getTask(taskName);
    run=getRun(SDIRun{1});
    taskSDIData=soc.internal.sdi.getSignalData(run.id,taskName);
    info.numOverran=NaN;
    info.percentOverran=NaN;
    info.overrunTimes=[];
    if isequal(taskData.taskType,'Timer-driven')
        period=taskData.taskPeriod;
        stopTime=str2double(get_param(modelName,'StopTime'));
        [overrunTimes,numExpected]=...
        soc.internal.sdi.getTaskOverruns(taskSDIData,period,dropTimes,stopTime);
        if~isequal(numExpected,0)
            info.numOverran=int32(numel(overrunTimes));
            info.percentOverran=100*double(info.numOverran)/numExpected;
            info.overrunTimes=overrunTimes;
        end
    end
end