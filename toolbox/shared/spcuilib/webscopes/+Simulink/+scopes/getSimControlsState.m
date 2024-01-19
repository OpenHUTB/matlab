function[simControlsState,updateSimulationControlsMsg]=getSimControlsState(clientId,varargin)
    modelH=bdroot(matlabshared.scopes.clientIDToHandle(clientId));

    isInModelReference=false;

    simModeDisableSchemas=false;
    if(nargin>1)&&(varargin{1})
        getLAScopeInstance=@()Simulink.scopes.LAScope.GetInstanceForModel(modelH,get_param(modelH,'Name'));

        topModelH=Simulink.scopes.getTopLevelMdl(modelH,getLAScopeInstance);
        if(topModelH~=modelH)
            isInModelReference=true;
            modelH=topModelH;
        end
    end
    simState=get_param(modelH,'SimulationStatus');
    sim_mode=get_param(modelH,'SimulationMode');
    pacingEnabled=strcmp(get_param(modelH,'EnablePacing'),'on');
    isSimSteppingEnabled=SLM3I.SLCommonDomain.isSimulationStartPauseContinueEnabled(modelH);
    isSimRunningCallback=SLM3I.SLCommonDomain.isSimulationRunningCallback(modelH);
    switch sim_mode
    case{'normal'}
        isSimSteppingAvailable=true;
    case{'accelerator'}
        isSimSteppingAvailable=true;
        simModeDisableSchemas=true;
    otherwise
        isSimSteppingAvailable=false;
        pacingEnabled=false;
        simModeDisableSchemas=true;
    end
    stepBackSchema=getStepBackSchema(modelH,simState,isSimSteppingEnabled,...
    isSimSteppingAvailable,isSimRunningCallback);
    startSchema=getStartSchema(modelH,simState,isSimSteppingEnabled,isSimRunningCallback,pacingEnabled);
    stepForwardSchema=getStepForwardSchema(modelH,simState,isSimSteppingEnabled,...
    isSimSteppingAvailable,isSimRunningCallback);
    stopSchema=getStopSchema(modelH);

    if any(strcmpi(simState,{'compiling','initializing'}))||...
        (isInModelReference&&simModeDisableSchemas)
        stepBackSchema.state='Disabled';
        startSchema.state='Disabled';
        stepForwardSchema.state='Disabled';
        stopSchema.state='Disabled';
    end
    params.stepBackState=stepBackSchema.state;
    params.stepBackLabel=stepBackSchema.label;
    params.stepBackIcon=stepBackSchema.icon;
    params.startState=startSchema.state;
    params.startLabel=startSchema.label;
    params.startIcon=startSchema.icon;
    params.stepForwardState=stepForwardSchema.state;
    params.stepForwardLabel=stepForwardSchema.label;
    params.stopState=stopSchema.state;

    updateSimulationControlsMsg.action=['updateSimulationControls',clientId];
    updateSimulationControlsMsg.params=params;

    paramsCell=struct2cell(params);
    simControlsState=[paramsCell{:}];

end


function schema=getStepBackSchema(modelH,simState,isSimSteppingEnabled,...
    isSimSteppingAvailable,isSimRunningCallback)
    schema.label='stepBack';

    if~isSimSteppingAvailable
        schema.state='Hidden';
    elseif~isSimSteppingEnabled
        schema.state='Disabled';
    else
        schema.state='Enabled';
    end
    enabled=get_param(modelH,'EnableRollback');
    compliance=get_param(modelH,'SimulationRollbackCompliance');
    if(isequal(compliance,'noncompliant-fatal'))
        schema.icon='options';
        schema.label='steppingOptionsNonCompliant';
    elseif(isequal(enabled,'off')||...
        isequal(compliance,'uninitialized'))
        schema.icon='options';
        schema.label='steppingOptions';
    else
        stepper=Simulink.SimulationStepper(modelH);
        numsteps=get_param(modelH,'NumberOfSteps');
        validity=stepper.validNumberOfStepsToRollback(numsteps);
        switch(validity)
        case-1
            schema.icon='options';
            schema.label='steppingOptions';
        case 0
            schema.icon='stepBack';
            schema.state='Disabled';
            schema.label='stepBackEnd';
        case 1
            schema.icon='stepBack';
            schema.label='stepBack';
        end
    end
    if strcmpi(simState,'running')||isSimRunningCallback
        schema.state='Disabled';
    end
end


function schema=getStartSchema(modelH,simState,isSimSteppingEnabled,...
    isSimRunningCallback,pacingEnabled)
    schema.state='Enabled';
    if~isSimSteppingEnabled||isSimRunningCallback
        schema.state='Disabled';
    end

    if strcmpi(simState,'running')
        schema.label='pause';
        schema.icon='pause';
    else
        if((strcmpi(simState,'paused')&&...
            get_param(modelH,'InteractiveSimInterfaceExecutionStatus')==1)||...
            strcmpi(simState,'paused-in-debugger'))
            schema.label='continue';
        else
            if pacingEnabled
                schema.label='startPaced';
            else
                schema.label='start';
            end
        end
        if pacingEnabled
            schema.icon='runPaced';
        else
            schema.icon='run';
        end
    end
end


function schema=getStepForwardSchema(modelH,simState,isSimSteppingEnabled,...
    isSimSteppingAvailable,isSimRunningCallback)
    schema.label='stepForward';
    if~isSimSteppingAvailable
        schema.state='Hidden';
    else
        if isSimSteppingEnabled
            schema.state='Enabled';
        else
            schema.state='Disabled';
        end
    end

    if(strcmpi(simState,'running')||isSimRunningCallback)
        schema.state='Disabled';
    elseif(strcmpi(simState,'paused')&&...
        Simulink.SimulationStepper(modelH).finishedFinalStep()==1)
        schema.state='Disabled';
        schema.label='stepForwardTerminate';
    end
end


function schema=getStopSchema(modelH)
    schema.state='Enabled';
    if~SLM3I.SLCommonDomain.isSimulationStopEnabled(modelH)
        schema.state='Disabled';
    end
end

