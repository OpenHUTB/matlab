function midiObjectCallbackExternalPlugin(midiHandle,obj,param,interface)





    if skipSync(interface)
        return;
    end

    val=midiread(midiHandle);
    setParameter(obj,param.Index,val);

    notify(interface,'ParameterChangedViaMIDI',audio.testbench.internal.ParameterChangedEventData(obj,param.Property));

end