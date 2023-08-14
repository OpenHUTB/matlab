function hasSrcPort=getEnableObserveSignals(selection,modelName)
    hasSrcPort=false;
    if bdIsLibrary(modelName)
        return;
    elseif get_param(modelName,'FastRestart')=="on"
        return;
    elseif sltest.internal.menus.isSupportedState(selection)
        hasSrcPort=true;
        return;
    end

    for j=1:numel(selection)
        if~(isa(selection(j),'Simulink.Segment')&&selection(j).LineType=="signal")
            return;
        end
        hasSrcPort=selection(j).SrcPortHandle~=-1&&get_param(selection(j).SrcPortHandle,'PortType')=="outport";
        if hasSrcPort
            return;
        end
    end
end
