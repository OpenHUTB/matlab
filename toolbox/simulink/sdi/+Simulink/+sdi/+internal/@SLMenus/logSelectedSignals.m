function schema=logSelectedSignals(cbinfo)




    schema=sl_action_schema;
    schema.tag='Simulink:LogSelectedSignals';
    schema.icon='Simulink:LogSelectedSignals';


    [bAreAllLogged,ports]=localAreAllPortsLogged(cbinfo);
    if bAreAllLogged
        schema.label=DAStudio.message('SDI:sdi:SLMenuStopLogSelectedSignals');
    else
        schema.label=DAStudio.message('SDI:sdi:SLMenuLogSelectedSignals');
    end


    schema.state='Hidden';


    schema.callback=@localLogSelectedSignals;
end

function localLogSelectedSignals(cbinfo)
    schema=SLStudio.SimulationMenu('LogSelectedSignals',cbinfo);
    schema.callback(cbinfo);
end

function[ret,validSrcPortHs]=localAreAllPortsLogged(~)
    validSrcPortHs=Simulink.sdi.internal.SignalObserverMenu.getSetLastSelectedPorts();
    if isempty(validSrcPortHs)
        ret=false;
        return
    end

    for idx=1:length(validSrcPortHs)
        val=get_param(validSrcPortHs(idx),'DataLogging');
        if strcmpi(val,'off')
            ret=false;
            return
        end
    end

    ret=true;
end
