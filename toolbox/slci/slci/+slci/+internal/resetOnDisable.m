function reset=resetOnDisable(obj)


    reset=0;
    if isa(obj.getParent,'Simulink.SubSystem')
        ssType=slci.internal.getSubsystemType(obj.getParent);
        switch ssType
        case{'Enable','EnableTrigger','Function-call','Action'}
            if strcmpi(obj.OutputWhenDisabled,'reset')
                reset=1;
            end
        end
    end
end
