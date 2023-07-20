function[v]=validateBlock(~,hC)


    v=hdlvalidatestruct;

    bfp=hC.SimulinkHandle;
    state_port=get_param(bfp,'ShowStatePort');
    if strcmpi(state_port,'on')
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:StatePortsNotAllowed'));
    end


    initial_condition_source=get_param(bfp,'InitialConditionSource');
    if strcmpi(initial_condition_source,'external')
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:ExternalInitialConditionNotAllowed'));
    end


    extResetSetting=get_param(bfp,'ExternalReset');
    if~any(strcmpi(extResetSetting,{'none','level','rising','falling'}))
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:ExternalResetModeNotSupported'));
    end

    if any(strcmpi(extResetSetting,{'rising','falling'}))&&...
        strcmpi(get_param(bfp,'InitialConditionMode'),'Output')
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:EdgeResetICMode'));
    end

    if~strcmpi(extResetSetting,'none')
        if~hC.SLInputSignals(2).Type.is1BitType
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:ExternalResetNotBoolean'));
        end
        if hC.SLInputSignals(2).Type.isArrayType
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:ExternalResetVectorType'));
        end
    end

    if hC.PirInputSignals(1).SimulinkRate==0
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:ContinuousSampleTimeUnsupported'));
    end

end

