function success=processTestCaseSettings(obj,simInput)




    success=true;


    obj.testSettings.sut=[];
    obj.testIteration=simInput.TestIteration;

    set_params={};
    if(simInput.IsStartTimeEnabled)
        set_params{end+1}={'StartTime',num2str(simInput.StartTime)};
    end
    if(simInput.IsInitialStateEnabled)
        set_params{end+1}={'LoadInitialState','on'};
        set_params{end+1}={'InitialState',simInput.InitialState};
    end
    if~isempty(simInput.InputType)&&simInput.InputType==4&&~isempty(simInput.StopTime)
        set_params{end+1}={'StopTime',num2str(simInput.StopTime)};
    elseif(simInput.IsStopTimeEnabled)
        set_params{end+1}={'StopTime',num2str(simInput.StopTime)};
    end
    if(simInput.GenerateReport)
        set_params{end+1}={'GenerateReport','on'};
    end
    if(~isempty(set_params))
        obj.testSettings.sut.set_params=set_params;
    end


    obj.testSettings.output=[];
    set_params={};
    if(simInput.SaveOutput)
        set_params{end+1}={'SaveOutput','on'};
    else
        set_params{end+1}={'SaveOutput','off'};
    end
    if(simInput.SaveState)
        set_params{end+1}={'SaveState','on'};
    else
        set_params{end+1}={'SaveState','off'};
    end
    if(simInput.SaveFinalState)
        set_params{end+1}={'SaveFinalState','on'};
    else
        set_params{end+1}={'SaveFinalState','off'};
    end

    if(simInput.SignalLogging)
        set_params{end+1}={'SignalLogging','on'};
    else
        set_params{end+1}={'SignalLogging','off'};
    end



    if(~simInput.SignalLogging)
        set_params{end+1}={'InstrumentedSignals',[]};
    end
    if(simInput.DSMLogging)
        set_params{end+1}={'DSMLogging','on'};
    else
        set_params{end+1}={'DSMLogging','off'};
    end
    if(~isempty(set_params))
        obj.testSettings.output.set_params=set_params;
    end
    obj.testSettings.output.outputCtrlEnabled=simInput.OutputCtrlEnabled;


    obj.testSettings.configSet.ConfigName=simInput.ConfigName;
    obj.testSettings.configSet.ConfigRefPath=simInput.ConfigRefPath;
    obj.testSettings.configSet.VarName=simInput.VarName;
    obj.testSettings.configSet.ConfigSetOverrideSetting=simInput.ConfigSetOverrideSetting;


    obj.testSettings.input=[];
    obj.testSettings.input.SigBuilderGroupName=simInput.SigBuilderGroupName;
    obj.testSettings.input.IsSigBuilderUsed=simInput.IsSigBuilderUsed;
    if(~isempty(obj.testIteration.TestParameter.SigBuilderGroupName))
        TestParameter=obj.testIteration.TestParameter;
        obj.testSettings.input.SigBuilderGroupName=TestParameter.SigBuilderGroupName;
        obj.testSettings.input.IsSigBuilderUsed=true;
    end
    obj.testSettings.input.TestSequenceBlock=simInput.TestSequenceBlock;
    obj.testSettings.input.TestSequenceScenario=simInput.TestSequenceScenario;
    if(~isempty(obj.testIteration.TestParameter.TestSequenceScenario))
        TestParameter=obj.testIteration.TestParameter;
        obj.testSettings.input.TestSequenceScenario=TestParameter.TestSequenceScenario;
    end
    obj.testSettings.input.InputFilePath=simInput.InputFilePath;
    obj.testSettings.input.InputMappingString=simInput.InputMappingString;
    obj.testSettings.input.InputType=simInput.InputType;
    obj.testSettings.input.ExcelSheet=simInput.ExcelSheet;
    obj.testSettings.input.Ranges=simInput.Ranges;
    obj.testSettings.input.UseXls=simInput.UseXls;
    obj.testSettings.input.InputMappingStatus=simInput.InputMappingStatus;
    obj.testSettings.input.IncludeExternalInputs=simInput.IncludeExternalInputs;
    obj.testSettings.input.StopSimAtLastTimePoint=simInput.StopSimAtLastTimePoint;
    obj.testSettings.input.Model=simInput.Model;
    obj.testSettings.input.PermutationId=simInput.PermutationId;


    obj.testSettings.parameterOverrides=[];
    bFromIteration=false;
    currentParameterSetId=-1;
    if(isfield(simInput,'ParameterSetId'))
        if(~isempty(simInput.ParameterSetId))
            currentParameterSetId=simInput.ParameterSetId;
        end
        if(~isempty(obj.testIteration.TestParameter.ParameterSetId))
            currentParameterSetId=obj.testIteration.TestParameter.ParameterSetId;
            bFromIteration=true;
        end
    end

    if(currentParameterSetId>0)
        obj.testSettings.parameterOverrides.parameterSetId=currentParameterSetId;
        obj.testSettings.parameterOverrides.fromIteration=bFromIteration;

        if(obj.runningOnPCT)
            tmpOverrides=stm.internal.getParameterOverrideDetails(obj.testSettings.parameterOverrides.parameterSetId);
            if~isempty(tmpOverrides.Errors)
                for k=1:length(tmpOverrides.Errors)
                    obj.out.messages{end+1}=tmpOverrides.Errors{k};
                    obj.out.errorOrLog{end+1}=true;
                    success=false;
                end
            end
            obj.testSettings.parameterOverrides.OverridesStruct=tmpOverrides.ParameterOverrides;
        end
    end



    if(isfield(simInput,'IsRunningOnCurrentRelease'))
        obj.testSettings.input.IsRunningOnCurrentRelease=simInput.IsRunningOnCurrentRelease;
    else
        obj.testSettings.input.IsRunningOnCurrentRelease=true;
    end
    if(~success)
        return;
    end


    obj.testSettings.signalLogging=[];

    bFromIteration=false;
    loggedSignalSetId=simInput.LoggedSignalSetId;
    if(~isempty(obj.testIteration.TestParameter.LoggedSignalSetId))
        loggedSignalSetId=obj.testIteration.TestParameter.LoggedSignalSetId;
        bFromIteration=true;
    end
    if(~isempty(loggedSignalSetId)&&loggedSignalSetId>0)
        loggedSignals=stm.internal.getLoggedSignals(loggedSignalSetId,true,true);
        obj.testSettings.signalLogging.loggedSignalSetId=loggedSignalSetId;
        obj.testSettings.signalLogging.loggedSignals=loggedSignals;
        obj.testSettings.signalLogging.fromIteration=bFromIteration;
    end
end
