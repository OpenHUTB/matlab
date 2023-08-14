

function simInStruct=filterSignalLoggingOnTriggers(streamedRunId,simInStruct,simOut)
    simInOTIStruct=simInStruct.OutputTriggering;
    run=Simulink.sdi.getRun(streamedRunId);
    signals=run.getAllSignals;
    simInOTIStruct.TimeDiff=0;

    import sltest.testmanager.*;

    noTriggering=simInOTIStruct.StartTriggerMode==TriggerMode.SameAsSim&&simInOTIStruct.StopTriggerMode==TriggerMode.SameAsSim;
    if~isempty(signals)&&~noTriggering

        for i=1:length(signals)
            signals(i).cacheDeinterleavedData(false);
            signals(i).expand();
        end

        orgStartTime=run.StartTime;
        orgStopTime=run.StopTime;

        assessmentsInfo=jsondecode(simInOTIStruct.SymbolData);

        if simInOTIStruct.StartTriggerMode==TriggerMode.Condition
            assessmentsInfo=addConditionAsAssessments(simInOTIStruct.StartTriggerCondition,assessmentsInfo);
        end
        if simInOTIStruct.StopTriggerMode==TriggerMode.Condition
            assessmentsInfo=addConditionAsAssessments(simInOTIStruct.StopTriggerCondition,assessmentsInfo);
        end

        if simInOTIStruct.StartTriggerMode==TriggerMode.Condition||simInOTIStruct.StopTriggerMode==TriggerMode.Condition
            results=evaluateAssessments(assessmentsInfo,simOut,simInStruct,signals);
        else
            results={};
        end

        [startTime,stopTime]=getStartStopTime(orgStartTime,orgStopTime,simInOTIStruct,results);

        stm.internal.trigger.filterOutSignalData(startTime,stopTime,orgStartTime,run.getAllSignals(),simInOTIStruct.ShiftTimeToZero);

        if simInOTIStruct.ShiftTimeToZero
            run.StartTime=0;
            run.StopTime=stopTime-startTime;
            simInOTIStruct.TimeDiff=startTime;
        else
            run.StartTime=startTime;
            run.StopTime=stopTime;
            simInOTIStruct.TimeDiff=0;
        end

        simInStruct.OutputTriggering=simInOTIStruct;
    end

    simInStruct.OutputTriggering=simInOTIStruct;
end

function[startTime,stopTime]=getStartStopTime(orgStartTime,orgStopTime,simInOTIStruct,assessementResults)

    startTime=orgStartTime;
    stopTime=orgStopTime;

    import sltest.testmanager.*;

    if simInOTIStruct.StartTriggerMode==TriggerMode.Condition
        startTimes=getTimeFromAssessment(assessementResults(1),startTime);
        startTime=startTimes(1);
    elseif simInOTIStruct.StartTriggerMode==TriggerMode.Duration
        startTime=simInOTIStruct.StartTriggerDuration+startTime;
    end

    if simInOTIStruct.StopTriggerMode==TriggerMode.Condition
        [validTimes]=getTimeFromAssessment(assessementResults(end),stopTime);

        stopTimeInd=find(validTimes>startTime,1);
        if(isempty(stopTimeInd))
            stopTime=validTimes(end);
        else
            stopTime=validTimes(stopTimeInd);
        end
    elseif simInOTIStruct.StopTriggerMode==TriggerMode.Duration
        stopTime=simInOTIStruct.StopTriggerDuration+startTime;
    end

    if stopTime<startTime
        stopTime=orgStopTime;
    end
end

function[validTimes]=getTimeFromAssessment(assessementResult,oldTime)
    validTimes=[];
    if assessementResult.Outcome==slTestResult.Pass

        sigID=assessementResult.Details.children{1}.children{1}.signalID;
        signalObj=Simulink.sdi.getSignal(sigID);
        indices=find(signalObj.Values.Data==true);

        if~isempty(indices)
            validTimes=signalObj.Values.Time(indices);
        else
            validTimes=oldTime;
        end
    elseif assessementResult.Outcome==slTestResult.Fail

        ME=MException(assessementResult.Details.cause{1}.identifier,assessementResult.Details.cause{1}.message);
        throw(ME);
    elseif assessementResult.Outcome==slTestResult.Untested

        validTimes=oldTime;
    end
end

function results=evaluateAssessments(assessmentsInfo,simOut,simInStruct,signals)
    constantSignalDataSet=Simulink.SimulationData.Dataset;
    paramStr=message('simulation_data_repository:sdr:ParamSampleTime').getString();
    engine=Simulink.sdi.Instance.engine;

    for signalObj=signals
        if strcmp(signalObj.SampleTime,paramStr)
            signalElement=engine.exportSignalData(signalObj.ID);
            constantSignalDataSet=constantSignalDataSet.addElement(signalElement);
        end
    end



    logsout=simOut.get(simOut.who{1});
    logsoutArgs={'LogsOut',logsout,'ConstantSignals',constantSignalDataSet,'DiscreteEventSignals',Simulink.SimulationData.Dataset};

    workspace.sltest_simout=simOut;
    workspace.sltest_bdroot=simInStruct.Model;
    workspace.sltest_sut=simInStruct.Model;
    workspace.sltest_isharness=false;

    evaluator=sltest.assessments.internal.AssessmentsEvaluator(jsonencode(assessmentsInfo));
    results=evaluator.evaluate(logsoutArgs{:},'Workspace',workspace);
end


function data=addConditionAsAssessments(condition,assessmentsInfo)
    data=assessmentsInfo;
    assessmentInfo=cell(6,1);
    assessmentInfo{1}=getRootAssessmentData(1);
    assessmentInfo{2}=getOperatorAssessmentData(1,2,'trigger','whenever is true');
    assessmentInfo{3}=getOperatorAssessmentData(1,3,'delay','with no delay');
    assessmentInfo{4}=getOperatorAssessmentData(1,4,'response','must be true');
    assessmentInfo{5}=getConditionAssessmentData(2,5,condition);
    assessmentInfo{6}=getConditionAssessmentData(4,6,condition);
    data.AssessmentsInfo=[data.AssessmentsInfo,assessmentInfo];
end


function data=getRootAssessmentData(id)
    data=getBaseAssessmentData(-1,id);
    data.assessmentName='';
    data.placeHolder='';
    data.dataType='assessment';
    data.type='operator';
    data.operator='trigger delay response';
end

function data=getOperatorAssessmentData(parent,id,type,operator)
    data=getBaseAssessmentData(parent,id);
    data.placeHolder=type;
    data.dataType=[type,'-clause'];
    data.type='operator';
    data.operator=operator;
end

function data=getConditionAssessmentData(parent,id,condition)
    data=getBaseAssessmentData(parent,id);
    data.label=condition;
    data.placeHolder='condition';
    data.dataType='boolean';
    data.type='expression';
    data.operator='';
end

function data=getBaseAssessmentData(parent,id)
    data.id=id;
    data.parent=parent;
    data.enabled=1;
end
