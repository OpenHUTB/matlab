function varargout=standalone_sim(simulationInput)








    model=convertStringsToChars(simulationInput.ModelName);
    startTime=clock;

    isRacDep=Simulink.isRaccelDeployed;
    c=onCleanup(@()Simulink.isRaccelDeployed(isRacDep));
    Simulink.isRaccelDeployed(true);

    mi=Simulink.RapidAccelerator.getStandaloneModelInterface(model);
    mi.startTime=startTime;





    c2=onCleanup(@()Simulink.RapidAccelerator.getStandaloneModelInterface(model).setIsInitializedForDeployment(false));


    c3=onCleanup(@()Simulink.sdi.clear());

    mi.initializeForDeployment();

    mi.debugLog(1,'Starting standalone_sim');




    lValidateSimscapeLogging(model);



    if(mi.modelCallbacksLevel>1)
        locCallCallback(model,mi,'PreLoadFcn');
        locCallCallback(model,mi,'PostLoadFcn');
    end
    if(mi.modelCallbacksLevel>0)
        locCallCallback(model,mi,'InitFcn');
        locCallCallback(model,mi,'StartFcn');
    end

    processedSimulationInput=locProcessSimulationInput(mi,simulationInput);
    locSimulationInputInterface(model,mi,processedSimulationInput);

    mi.debugLog(1,'Calling init_up_to_date_check_off');
    simOpts.RapidAcceleratorUpToDateCheck='off';
    timeout=[];
    try
        timeout=simulationInput.getModelParameter('TimeOut');
    catch
    end
    if(~isempty(timeout))
        simOpts.TimeOut=timeout;
    end

    val=getenv('RAPID_ACCELERATOR_OPTIONS_VERBOSE');
    if(~isempty(val)&&isequal(val,'1'))
        save('simOpts');
    end
    mf0Model=mf.zero.Model;
    buildData=sl('rapid_accel_target_utils','init_up_to_date_check_off',...
    model,...
    [],...
    simOpts,...
    processedSimulationInput.ExternalInput,...
    0,...
    true,...
    true,...
    false,...
    false,...
    [],...
    startTime,...
    processedSimulationInput.InitialState,...
    processedSimulationInput.Variables,...
    processedSimulationInput.ExperimentalProperties.RapidAccelExternalInputsFcn,...
    processedSimulationInput.ExperimentalProperties.RapidAccelExternalOutputsFcn,...
    processedSimulationInput.ExperimentalProperties.RapidAccelLiveOutputsFcn,...
    processedSimulationInput.RuntimeFcns,...
mf0Model...
    );
    mi.debugLog(1,'Checking current arch against build arch');
    Simulink.RapidAccelerator.internal.crossPlatformCheck(buildData.computer.arch);
    initTime=clock;
    mi.debugLog(1,'Calling run');
    [status,result]=sl('rapid_accel_target_utils','run',buildData);
    for idx=1:length(status)
        mi.debugLog(1,['Rapid accelerator process status{',...
        num2str(idx),'}: ',num2str(status{idx})]);
    end
    for idx=1:length(result)
        mi.debugLog(1,['Rapid accelerator process result{',...
        num2str(idx),'}: ',result{idx}]);
    end
    mi.debugLog(1,'Calling load_mat_file');
    load_results=sl('rapid_accel_target_utils','load_mat_file',...
    buildData,1,false,[],[]);
    load_results=locAddDatasetRef(load_results,buildData);

    simMetadataStruct=locLoadMetaData(buildData);

    mi.debugLog(1,'Calling get_exe_error');

    sl('rapid_accel_target_utils','get_exe_error',...
    buildData,status,result);

    execTime=clock;
    mi.debugLog(1,'Calling cleanup');
    rapid_accel_target_utils('cleanup',buildData,false);



    if(mi.modelCallbacksLevel>0)
        locCallCallback(model,mi,'StopFcn');
    end
    if(mi.modelCallbacksLevel>1)
        locCallCallback(model,mi,'CloseFcn');
    end

    stopTime=clock;
    simMetadataStruct=locMetaDataAddTimingInfo(simMetadataStruct,...
    startTime,initTime,execTime,stopTime);
    [varargout{1:nargout}]=Simulink.SimulationOutput(load_results,simMetadataStruct);

    mi.debugLog(1,'Finished standalone_sim');

end


function simulationInput=locProcessExternalInputs(simulationInput,mi)
    if(~isempty(simulationInput.ExternalInput))
        mi.debugLog(1,'External inputs were found in SimulationInput');

        simulationInput=simulationInput.setModelParameter(...
        'LoadExternalInput',...
'on'...
        );

        if(ischar(simulationInput.ExternalInput))
            mi.debugLog(2,'External input value was a string');

            simulationInput=simulationInput.setModelParameter(...
            'ExternalInput',...
            simulationInput.ExternalInput...
            );

            simulationInput.ExternalInput=[];
        end
    end
end









function processedSimulationInput=...
    locProcessSimulationInput(mi,simulationInput)
    mi.debugLog(1,'Setting up external inputs from SimulationInput');
    processedSimulationInput=simulationInput;

    processedSimulationInput=locProcessExternalInputs(...
    processedSimulationInput,...
mi...
    );

    mi.debugLog(1,'Setting up InitialState from SimulationInput');
    if(~isempty(simulationInput.InitialState))
        processedSimulationInput=...
        processedSimulationInput.setModelParameter(...
        'LoadInitialState','on');
        locInitialState=simulationInput.InitialState;
        if(ischar(locInitialState))
            processedSimulationInput=...
            processedSimulationInput.setModelParameter(...
            'InitialState',locInitialState);
            processedSimulationInput.InitialState=[];
        end
    end

end


function locSimulationInputInterface(model,mi,simulationInput)
    simulationModeOnSimulationInput='';
    rapidUpToDateCheckOnSimulationInput='';

    mi.debugLog(1,'Setting up model parameters from SimulationInput');


    allowedTunableModelParameters=mi.getTunableModelParameters();
    if(~isempty(simulationInput.ModelParameters))
        for i=1:length(simulationInput.ModelParameters)
            p=simulationInput.ModelParameters(i);
            if(strcmpi('RapidAcceleratorUpToDateCheck',p.Name))
                rapidUpToDateCheckOnSimulationInput=p.Value;
            elseif(any(strcmpi(allowedTunableModelParameters,p.Name)))
                mi.debugLog(1,['Setting ',p.Name,' to ',p.Value]);
                set_param(model,p.Name,p.Value);
                if(strcmpi('LoggingFileName',p.Name))
                    mi.debugLog(1,['Also setting ','ResolvedLoggingFileName',' to ',p.Value]);
                    locTuneLoggingFileName(model,p.Value);
                end
            else
                error(message('simulinkcompiler:runtime:ModelParameterNotTunable',p.Name));
            end
            if(strcmpi('SimulationMode',p.Name))
                simulationModeOnSimulationInput=p.Value;
            end
        end
    end

    if(isempty(simulationModeOnSimulationInput)||...
        ~startsWith('rapid-accelerator',lower(simulationModeOnSimulationInput)))
        error(message('simulinkcompiler:runtime:UnsupportedSimulationMode'));
    end
    if(isempty(rapidUpToDateCheckOnSimulationInput)||...
        ~strcmpi(rapidUpToDateCheckOnSimulationInput,'off'))
        error(message('simulinkcompiler:runtime:RapidAcceleratorMustBeUpToDateCheckOff'));
    end

    locTuneParameters(mi,simulationInput);
end


function locTuneParameters(modelInterface,simulationInput)
    modelInterface.debugLog(1,'Setting up parameter variables from SimulationInput');
    rtp=modelInterface.getRtp();

    haveParametersInRtp=~isempty(rtp)&&~isempty(rtp.parameters);
    haveVariablesToTune=~isempty(simulationInput.Variables);
    if(~haveParametersInRtp)
        modelInterface.debugLog(1,'No parameters are tunable!');
    elseif(~haveVariablesToTune)
        modelInterface.debugLog(1,'No variables to tune!');
    else
        verbosityLevel=modelInterface.verbosityLevel;
        for i=1:length(simulationInput.Variables)
            modelParameterIdentifier=simulationInput.Variables(i).Name;
            modelParameterValue=simulationInput.Variables(i).Value;
            if(verbosityLevel>0)
                modelInterface.debugLog(1,['### Tuning parameter: ',modelParameterIdentifier]);
            end

            try
                rtp=sl(...
                'modifyRTP',...
                rtp,...
                modelParameterIdentifier,...
modelParameterValue...
                );
            catch ME
                switch ME.identifier
                case 'RTW:rsim:SetRTPParamBadIdentifier'




                otherwise
                    throw(ME)
                end
            end
        end
    end

    if haveVariablesToTune

        modelInterface.debugLog(1,'Adding simulation input variables to rtp.internal.simInputVariables');
        rtp.internal.simInputVariables={simulationInput.Variables.Name};

        modelInterface.debugLog(1,'Setting rtp on modelInterface');
        modelInterface.setRtp(rtp);
    end
end











function locCallCallback(model,mi,callback)
    callbackFcn=get_param(model,callback);
    if(~isempty(callbackFcn))
        mi.debugLog(1,['Invoking ',callback]);
        try
            evalin('base',callbackFcn);
        catch ME
            disp([callback,' of ',model,' threw an exception']);
            getReport(ME)
            disp(ME)
        end
    end
end



function metaData=locLoadMetaData(buildData)
    simMetadataFile=[buildData.buildDir,filesep,'md',buildData.tmpVarPrefix{1},'.mat'];
    try
        vars=load(simMetadataFile);
        simMetadataStruct=vars.SimMetadataStruct;
    catch E %#ok to ignore the error
        metaData.ModelInfo=struct();
        metaData.ExecutionInfo=struct();
        metaData.TimingInfo=struct();
        return;
    end

    if isstruct(simMetadataStruct)&&~isfield(simMetadataStruct,'ModelInfo')&&~isempty(simMetadataStruct)
        metaData=struct();
        metaData.ModelInfo.ModelName=buildData.mdl;
        metaData.ModelInfo.UserID=getenv('USER');
        if isempty(metaData.ModelInfo.UserID)
            metaData.ModelInfo.UserID=getenv('USERNAME');
        end
        metaData.ModelInfo.MachineName=getenv('HOST');
        if isempty(metaData.ModelInfo.MachineName)
            metaData.ModelInfo.MachineName=getenv('HOSTNAME');
        end
        if isempty(metaData.ModelInfo.MachineName)
            metaData.ModelInfo.MachineName=getenv('COMPUTERNAME');
        end
        metaData.ModelInfo.Platform=computer;
        metaData.ModelInfo.ModelStructuralChecksum=uint32(zeros(4,1));
        metaData.ModelInfo.ModelStructuralChecksum(1)=uint32(simMetadataStruct.StructuralChecksum0);
        metaData.ModelInfo.ModelStructuralChecksum(2)=uint32(simMetadataStruct.StructuralChecksum1);
        metaData.ModelInfo.ModelStructuralChecksum(3)=uint32(simMetadataStruct.StructuralChecksum2);
        metaData.ModelInfo.ModelStructuralChecksum(4)=uint32(simMetadataStruct.StructuralChecksum3);
        metaData.ModelInfo.SimulationMode='rapid-accelerator';
        metaData.ModelInfo.StartTime=simMetadataStruct.StartTime;
        metaData.ModelInfo.StopTime=simMetadataStruct.StopTime;
        metaData.ModelInfo.SolverInfo.Solver=simMetadataStruct.SolverName;
        if simMetadataStruct.IsVariableStepSolver
            metaData.ModelInfo.SolverInfo.Type='Variable-Step ';
            metaData.ModelInfo.SolverInfo.MaxStepSize=simMetadataStruct.StepSize;
        else
            metaData.ModelInfo.SolverInfo.Type='Fixed-Step ';
            metaData.ModelInfo.SolverInfo.FixedStepSize=simMetadataStruct.StepSize;
        end
        metaData.ModelInfo.LoggingInfo=struct();
        if strcmpi(get_param(buildData.mdl,'LoggingToFile'),'on')
            metaData.ModelInfo.LoggingInfo.LoggingToFile='on';
            metaData.ModelInfo.LoggingInfo.LoggingFileName=get_param(buildData.mdl,'LoggingFileName');
        else
            metaData.ModelInfo.LoggingInfo.LoggingToFile='off';
        end

        metaData.TimingInfo=struct();

        metaData.ExecutionInfo=struct('StopEvent','');
        if simMetadataStruct.ReachedStopTime
            metaData.ExecutionInfo.StopEvent='ReachedStopTime';
            metaData.ExecutionInfo.StopEventDescription=...
            getString(message('Simulink:Simulation:SimMetadataReachedStopTime',...
            num2str(simMetadataStruct.StopTime)));
        elseif simMetadataStruct.StopRequested
            metaData.ExecutionInfo.StopEvent='ModelStop';
            metaData.ExecutionInfo.StopEventDescription=...
            getString(message('Simulink:Simulation:SimMetadataStopCommand',...
            num2str(simMetadataStruct.StopTime)));
        else
            metaData.ExecutionInfo.StopEvent='';
        end
        metaData.ExecutionInfo.ErrorDiagnostic=[];
        WarningDiagnostics.Diagnostic=[];
        WarningDiagnostics.SimulationPhase=[];
        WarningDiagnostics.SimulationTime=[];
        metaData.ExecutionInfo.WarningDiagnostics=WarningDiagnostics([],1);

    end
end


function simMetadataStruct=locMetaDataAddTimingInfo(...
    simMetadataStruct,...
    startTime,initTime,execTime,stopTime)
    simMetadataStruct.TimingInfo.WallClockTimestampStart=...
    [num2str(startTime(1)),'-',num2str(startTime(2)),'-',num2str(startTime(3)),...
    ' ',num2str(startTime(4)),':',num2str(startTime(5)),':',num2str(startTime(6),'%2.0f')];
    simMetadataStruct.TimingInfo.WallClockTimestampStop=...
    [num2str(stopTime(1)),'-',num2str(stopTime(2)),'-',num2str(stopTime(3)),...
    ' ',num2str(stopTime(4)),':',num2str(stopTime(5)),':',num2str(stopTime(6),'%2.0f')];
    simMetadataStruct.TimingInfo.InitializationElapsedWallTime=etime(initTime,startTime);
    simMetadataStruct.TimingInfo.ExecutionElapsedWallTime=etime(execTime,initTime);
    simMetadataStruct.TimingInfo.TerminationElapsedWallTime=etime(stopTime,execTime);
    simMetadataStruct.TimingInfo.TotalElapsedWallTime=etime(stopTime,startTime);
end


function out=locAddDatasetRef(out,buildData)
    if strcmpi(get_param(buildData.mdl,'LoggingToFile'),'on')
        fileName=get_param(buildData.mdl,'ResolvedLoggingFileName');
        out=sl('rapid_accel_target_utils',...
        'add_datasetref_to_simoutstruct',...
        buildData.logging,fileName,out);
    end
end

function locTuneLoggingFileName(model,filename)
    [fpath,fname,fext]=fileparts(filename);
    if isempty(fext)
        fname=[fname,'.mat'];
    end
    fname=fullfile(fpath,fname);
    set_param(model,'ResolvedLoggingFileName',fname);
end

function lValidateSimscapeLogging(model)



    logType=get_param(model,'SimscapeLogType');
    if~isempty(logType)&&~strcmpi(logType,'none')
        error(message('simulinkcompiler:runtime:UnsupportedSimscapeLogging',string(model)));
    end
end
