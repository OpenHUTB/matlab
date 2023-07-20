function result=evaluateAssessments(assessmentsInfo,ccInput,callbackInfo)




    persistent versionInfo;
    if isempty(versionInfo)
        versionInfo=ver('matlab');
    end
    persistent releaseString;
    if isempty(releaseString)
        releaseString=versionInfo.Release;
    end

    try
        result={};
        workspace=struct;
        unsupportedMRTResults=cell(1,2);








        if isfield(ccInput,'testCaseID')
            workspace.sltest_testCase=sltest.testmanager.TestCase([],ccInput.testCaseID);
            isOnCurrentRelease=sltest.internal.isRunningOnCurrentReleaseOnly(workspace.sltest_testCase);
            if~isOnCurrentRelease&&...
                strcmp(stm.internal.assessmentsFeature('AllowMRTAssessments'),'off')
                return;
            end
            if isempty(ccInput.sltest_iterationName)
                workspace.TestResult=sltest.testmanager.TestCaseResult(ccInput.testCaseResultID);
            else
                workspace.TestResult=sltest.testmanager.TestIterationResult(ccInput.testCaseResultID);
            end
        end


        evaluator=sltest.assessments.internal.AssessmentsEvaluator(assessmentsInfo);
        if~evaluator.hasAssessments()
            return;
        end


        assessmentsToRunArg={};
        if isfield(ccInput,'testCaseResultID')
            iterationAssessments=getIterationAssessments(ccInput.testCaseResultID,evaluator.getAssessmentsNames());
            if iscell(iterationAssessments)
                if isempty(iterationAssessments)
                    return;
                else
                    assessmentsToRunArg={'AssessmentsToRun',iterationAssessments};
                end
            else
                if~evaluator.hasEnabledAssessments()
                    return;
                end
            end
        end



        if isfield(ccInput,'testCaseID')

            if isfield(ccInput,'assessmentsData')
                if(iscell(ccInput.assessmentsData))
                    for i=1:length(ccInput.assessmentsData)
                        if isfield(ccInput.assessmentsData{i},'parameterValues')
                            parameters{i}=ccInput.assessmentsData{i}.parameterValues;%#ok<AGROW>
                        end
                        if isfield(ccInput.assessmentsData{i},'unsupportedMRTAssessments')
                            unsupportedMRTMsgId='stm:AssessmentsStrings:CannotEvaluateAssessments';
                            unsupportedMRTException=MException(unsupportedMRTMsgId,message(unsupportedMRTMsgId).getString());
                            unsupportedMRTResults{i}=getErrorInfo(message(unsupportedMRTMsgId).getString(),unsupportedMRTException);
                        end
                    end
                else
                    error(message('sltest:assessments:SimulationError'));
                end
            else
                error(message('sltest:assessments:SimulationError'));
            end
        else



            parameters{1}=evaluator.evaluateParameters(evaluator.parseParameters(1,'',struct()));
        end

        quantitativeArgs={};
        if(isfield(ccInput,'quantitative'))
            quantitativeArgs={'Quantitative',ccInput.quantitative};
        end



        if(isfield(ccInput,'WorkspaceVars'))
            varNames=fieldnames(ccInput.WorkspaceVars);
            for i=1:numel(varNames)
                workspace.(char(varNames(i)))=ccInput.WorkspaceVars.(char(varNames(i)));
            end
        end

        try


            if strcmp(stm.internal.assessmentsFeature('ShowAssessmentsCallback'),'on')&&nargin>2
                if~isempty(callbackInfo)
                    vars=evalCallback(callbackInfo,ccInput);
                    if~isempty(vars)
                        varNames=fieldnames(vars);
                        for i=1:numel(varNames)
                            workspace.(char(varNames(i)))=vars.(char(varNames(i)));
                        end
                    end
                end
            end
        catch ME
            callbackErrorMsgId='sltest:assessments:AssessmentsCallbackError';
            callbackErrorException=MException(callbackErrorMsgId,append(message(callbackErrorMsgId).getString(),' : ',ME.message));
            result={getErrorInfo(message(callbackErrorMsgId).getString(),callbackErrorException)};
            return;
        end

        assessmentsUUID='';
        testfileLocation='';

        if isfield(ccInput,'sltest_bdroot')


            if isfield(ccInput,'testCaseID')
                assessmentsUUID=stm.internal.getAssessmentsUUID(ccInput.testCaseID);
                testfileLocation=stm.internal.getTestCaseProperty(ccInput.testCaseID,'Location');
            end

            standaloneAssessments=~isfield(ccInput,'testCaseID');
            assert(length(ccInput.sltest_bdroot)<=2,'Invalid number of simulations');
            for i=1:length(ccInput.sltest_bdroot)

                logsoutArgs={};
                logsout={};

                constantSignalDataSet=Simulink.SimulationData.Dataset;

                discreteEventSignalDataSet=Simulink.SimulationData.Dataset;
                simout={};
                if standaloneAssessments
                    if~isempty(ccInput.sltest_simout)
                        simout=ccInput.sltest_simout{i};
                    end
                    if~isempty(simout)
                        if isfield(ccInput,'assessmentsData')&&isfield(ccInput.assessmentsData{i},'sigLoggingName')
                            logsoutName=ccInput.assessmentsData{i}.sigLoggingName;
                        else
                            logsoutName=get_param(ccInput.sltest_bdroot{i},'SignalLoggingName');
                        end
                        logsout=ccInput.sltest_simout{i}.get(logsoutName);
                    else
                        signalLoggingMsgId='sltest:assessments:InvalidSignalLoggingSetting';
                        signalLoggingException=MException(signalLoggingMsgId,message(signalLoggingMsgId).getString());
                        result{end+1}=getErrorInfo(message(signalLoggingMsgId).getString(),signalLoggingException);%#ok<AGROW>
                        continue;
                    end
                else
                    tcr=sltest.testmanager.TestCaseResult(ccInput.testCaseResultID);


                    if~isempty(tcr.ErrorMessages.Simulation(i).messages)
                        signalLoggingMsgId='sltest:assessments:SimulationError';
                        signalLoggingException=MException(signalLoggingMsgId,message(signalLoggingMsgId).getString());
                        result{end+1}=getErrorInfo(message(signalLoggingMsgId).getString(),signalLoggingException);%#ok<AGROW>
                        continue;
                    end

                    tcr_runs=tcr.getOutputRuns(i);
                    if~isempty(tcr_runs)
                        logsout=tcr_runs.export;
                        if~isempty(logsout)&&strcmp(logsout.get(1).Name,'simOut')&&isa(logsout.get(1),'Simulink.SimulationData.Dataset')

                            logsout=logsout.get(1).get(1);
                        end
                        engine=Simulink.sdi.Instance.engine;
                        paramStr=message('simulation_data_repository:sdr:ParamSampleTime').getString();







                        [wereConstSigsCached,wereDESigsCached]=...
                        needToCacheSigsSeparatelyForMRT(tcr,ccInput,releaseString,i);
                        if wereConstSigsCached
                            constantSignalDataSet=createConstSigDSFromMRTRun...
                            (ccInput.assessmentsData{i}.constantSignalIndices,ccInput.sltest_simout{i});
                        end


                        for signalObj=tcr_runs.getAllSignals
                            if~wereConstSigsCached&&strcmp(signalObj.SampleTime,paramStr)
                                signalElement=engine.exportSignalData(signalObj.ID);
                                constantSignalDataSet=constantSignalDataSet.addElement(signalElement);
                            end
                            sourceBlock=struct('BlockPath',signalObj.FullBlockPath,'PortIndex',signalObj.PortIndex);
                            if(wereDESigsCached&&isDiscreteEventSignal(sourceBlock,ccInput.assessmentsData{i}.discreteEventSignalPorts))...
                                ||engine.sigRepository.getSignalIsEventBased(signalObj.ID)
                                signalElement=engine.exportSignalData(signalObj.ID);
                                discreteEventSignalDataSet=discreteEventSignalDataSet.addElement(signalElement);
                            end
                        end


                        if~isempty(ccInput.sltest_simout)
                            simout=ccInput.sltest_simout{min(i,length(ccInput.sltest_simout))};
                        end
                    end
                end
                if~isempty(logsout)
                    logsoutArgs={'LogsOut',logsout,'ConstantSignals',constantSignalDataSet,'DiscreteEventSignals',discreteEventSignalDataSet};
                end

                simIndexArgs={'SimIndex',i};
                workspace.sltest_simout=simout;
                workspace.sltest_bdroot=ccInput.sltest_bdroot{i};
                workspace.sltest_sut=ccInput.sltest_sut{i};
                workspace.sltest_isharness=ccInput.sltest_isharness;
                if isfield(ccInput,'sltest_iterationName')
                    workspace.sltest_iterationName=ccInput.sltest_iterationName;
                end

                if isempty(unsupportedMRTResults{i})
                    resultList=evaluator.evaluate(logsoutArgs{:},'Parameters',parameters,'Workspace',workspace,assessmentsToRunArg{:},quantitativeArgs{:},simIndexArgs{:});

                    resultList=arrayfun(@(r)processResult(r,assessmentsUUID,testfileLocation),resultList);

                    result{end+1}=resultList;%#ok<AGROW>
                else
                    result{end+1}=unsupportedMRTResults{i};%#ok<AGROW> 
                end
            end

            if isOnCurrentRelease
                result=flip(result);
            end

        else
            logsoutArgs={};
            resultList=evaluator.evaluate(logsoutArgs{:},'Parameters',parameters,'Workspace',workspace,assessmentsToRunArg{:},quantitativeArgs{:});

            result={arrayfun(@(r)processResult(r,assessmentsUUID,testfileLocation),resultList)};
        end


    catch ME
        result={getErrorInfo(message('sltest:assessments:AssessmentsError').getString(),ME)};
    end
end




function vars=evalCallback(cbStrIn,ccInput)
    if nargin>1

        if~isempty(ccInput.sltest_simout)
            sltest_simout=ccInput.sltest_simout{1};
        else
            sltest_simout=ccInput.sltest_simout;
        end
        sltest_bdroot=ccInput.sltest_bdroot;
        sltest_sut=ccInput.sltest_sut;
        sltest_isharness=ccInput.sltest_isharness;
        if isfield(ccInput,'sltest_iterationName')
            sltest_iterationName=ccInput.sltest_iterationName;
        end
        if isempty(ccInput.sltest_iterationName)
            TestResult=sltest.testmanager.TestCaseResult(ccInput.testCaseResultID);
        else
            TestResult=sltest.testmanager.TestIterationResult(ccInput.testCaseResultID);
        end
        if isfield(ccInput,'testCaseID')
            sltest_testCase=sltest.testmanager.TestCase([],ccInput.testCaseID);
        end

        clear ccInput;
    end

    cbStrIn=sprintf('clear cbStrIn;\n%s',cbStrIn);
    eval(cbStrIn);
    tmp=whos;

    vars={};
    for i=1:numel(tmp)

        if~ismember(tmp(i).name,{'sltest_simout','sltest_bdroot','sltest_sut','sltest_isharness','sltest_iterationName','TestResult','cbStrIn'})
            vars.(tmp(i).name)=eval(tmp(i).name);
        end
    end
end

function res=processResult(x,assessmentsUUID,testfileLocation)
    res.Name=x.Name;
    res.Definition=jsonencode(x.Definition);
    if isa(x.Details,'MException')
        resultJSON.type='error';
        resultJSON.error=x.Details.getReport();
    else
        resultJSON=x.Details;
        resultJSON.type='result';
    end
    res.ResultJSON=jsonencode(resultJSON);
    res.Outcome=int32(x.Outcome);
    res.Result=x.Assessment;
    if isempty(res.Result)
        assert(isa(x.Details,'MException'));
        res.Result=x.Details;
    end
    if(isfield(x,'Robustness'))
        res.Robustness=x.Robustness;
    else
        res.Robustness=[];
    end
    if~isempty(assessmentsUUID)&&~isempty(testfileLocation)
        res.Requirements=getRequirements(assessmentsUUID,x.Id,testfileLocation);
    else
        res.Requirements=[];
    end
    if~isempty(assessmentsUUID)
        res.UUID=[assessmentsUUID,':',num2str(x.Id)];
    else
        res.UUID='no-uuid';
    end
end

function iterationAssessments=getIterationAssessments(testCaseResultID,assessmentsNames)
    iterationAssessments='';


    testCaseResult=sltest.testmanager.TestCaseResult(testCaseResultID);
    try
        testParams=testCaseResult.IterationSettings.testParameters;
    catch

        return;
    end
    iterationAssessmentsStr='';
    for i=1:length(testParams)
        if strcmp(testParams(i).parameterName,'Assessments')
            iterationAssessmentsStr=testParams(i).value;
            break;
        end
    end
    if isempty(iterationAssessmentsStr)
        return;
    end

    try
        iterationAssessments=jsondecode(iterationAssessmentsStr);
    catch
        error(message('sltest:assessments:InvalidAssessmentIterationSetting'));
    end

    if isempty(iterationAssessments)

        iterationAssessments={};
    end

    if~iscell(iterationAssessments)
        error(message('sltest:assessments:InvalidAssessmentIterationSetting'));
    end

    invalidAssessments=setdiff(iterationAssessments,assessmentsNames);
    if~isempty(invalidAssessments)
        error(message('sltest:assessments:InvalidAssessmentNameInIteration',strjoin(invalidAssessments,', ')));
    end
end

function error=getErrorInfo(msg,ME)
    assessmentsException=sltest.assessments.internal.AssessmentsException(ME);
    error.Name=msg;
    resultJSON.type='error';
    resultJSON.error=assessmentsException.getReport();
    error.ResultJSON=jsonencode(resultJSON);
    error.Outcome=int32(slTestResult.Fail);
    error.Result=assessmentsException;
    error.Requirements=[];
    error.Robustness=[];
    error.UUID='no-uuid';
    error.Definition=jsonencode([]);
end

function reqs=getRequirements(assessmentsUUID,assessmentId,testfileLocation)
    reqId=[assessmentsUUID,':',num2str(assessmentId)];
    reqs=stm.internal.util.getReqs(testfileLocation,reqId);
end

function[wereConstSigsCached,wereDESigsCached]=...
    needToCacheSigsSeparatelyForMRT(tcr,ccInput,releaseString,i)

    successSim=...
...
    ~strcmp(releaseString,tcr.SimulationMetadata(i).simulinkRelease)...
...
...
...
    &&isfield(ccInput,'sltest_simout')...
    &&(~isempty(ccInput.sltest_simout))...
    &&isa(ccInput.sltest_simout{i},'Simulink.SimulationOutput')...
...
...
    &&isfield(ccInput,'assessmentsData');

    wereConstSigsCached=successSim...
    &&isfield(ccInput.assessmentsData{i},'constantSignalIndices')...
    &&(~isempty(ccInput.assessmentsData{i}.constantSignalIndices));

    wereDESigsCached=successSim...
    &&isfield(ccInput.assessmentsData{i},'discreteEventSignalPorts');
end

function constSigDS=createConstSigDSFromMRTRun(idxStruct,simOut)
    constSigDS=Simulink.SimulationData.Dataset;


    logsoutName=idxStruct.sigLoggingName;
    outSaveName=idxStruct.outLoggingName;



    if any(strcmp(simOut.who,logsoutName))&&isfield(idxStruct,logsoutName)
        logsout=simOut.get(logsoutName);
        idx=idxStruct.(logsoutName);

        assert(isa(logsout,'Simulink.SimulationData.Dataset'));

        assert(numel(idx)<=logsout.numElements);
        for i=1:numel(idx)
            constSigDS=constSigDS.addElement(logsout{idx(i)});
        end
    end
    if any(strcmp(simOut.who,outSaveName))&&isfield(idxStruct,outSaveName)
        yout=simOut.get(outSaveName);
        idx=idxStruct.(outSaveName);
        if numel(idx)==0
            return;
        end
        assert(isa(yout,'Simulink.SimulationData.Dataset'));
        assert(numel(idx)<=yout.numElements);
        for i=1:numel(idx)
            constSigDS=constSigDS.addElement(yout{idx(i)});
        end
    end
end

function res=isDiscreteEventSignal(sourceBlock,cachedStruct)
    res=false;
    for i=1:numel(cachedStruct)
        if isequal(sourceBlock,cachedStruct(i))
            res=true;
            break;
        end
    end
end