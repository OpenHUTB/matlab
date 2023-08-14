function cpw=getAssertBlockInputLenght(ModelName,BlkPathStr)













    ph=get_param(BlkPathStr,'PortHandles');
    iph=ph.Inport;
    assert(length(iph)==1,'(hdlv internal) basic Assertion block should have only 1 input port');

    cpw=get_param(iph,'CompiledPortWidth');
    if cpw==0
        assert(~is_in_compiled_state(ModelName),'(hdlv internal) no compiled port width but model is in compiled state');
        on_cleanup=l_put_in_compiled_state(ModelName);%#ok<NASGU>
        cpw=get_param(iph,'CompiledPortWidth');
    end

    assert(cpw>0,'(hdlv internal) could not obtain proper port width for assertion input');

end

function oc=l_put_in_compiled_state(ModelName)

    warnMaxStepSize=warning('off','Simulink:Engine:UsingDefaultMaxStepSize');
    warnFixedStepSize=warning('off','Simulink:SampleTime:FixedStepSizeHeuristicWarn');
    warnTermDefer=warning('off','Simulink:Engine:SFcnAPITerminationDeferred');
    warnCompiled=warning('off','Simulink:Engine:ModelAlreadyCompiled');
    oc.ocw2=onCleanup(@()warning(warnMaxStepSize.state,'Simulink:Engine:UsingDefaultMaxStepSize'));
    oc.ocw3=onCleanup(@()warning(warnFixedStepSize.state,'Simulink:SampleTime:FixedStepSizeHeuristicWarn'));
    oc.ocw4=onCleanup(@()warning(warnTermDefer.state,'Simulink:Engine:SFcnAPITerminationDeferred'));
    oc.ocw5=onCleanup(@()warning(warnCompiled.state,'Simulink:Engine:ModelAlreadyCompiled'));


    cached_simmode=get(get_param(ModelName,'handle'),'SimulationMode');
    if~strcmp(cached_simmode,'normal')

        set(get_param(ModelName,'handle'),'SimulationMode','normal');

    end

    try

        feval(ModelName,[],[],[],'compile');
        oc.oc2=onCleanup(@()feval(ModelName,[],[],[],'term'));
        oc.ocw6=onCleanup(@()set(get_param(ModelName,'handle'),'SimulationMode',cached_simmode));
    catch ME_Compile
        throw(ME_Compile);
    end


end

function tf=is_in_compiled_state(modelName)
    if strcmpi(get_param(modelName,'SimulationStatus'),'paused')||...
        strcmpi(get_param(modelName,'SimulationStatus'),'running')||...
        strcmpi(get_param(modelName,'SimulationStatus'),'compiled')||...
        strcmpi(get_param(modelName,'SimulationStatus'),'restarting')

        tf=true;
    else
        tf=false;
    end
end