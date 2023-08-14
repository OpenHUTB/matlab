function midiObjectCallback(midiHandle,obj,paramName,func,interface)





    if skipSync(interface)
        return;
    end

    val=midiread(midiHandle);
    val=func(val);
    if ischar(val)

        val=deblank(val);
    end
    obj.(paramName)=val;

    notify(interface,'ParameterChangedViaMIDI',audio.testbench.internal.ParameterChangedEventData(obj,paramName));

end