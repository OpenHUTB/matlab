function wasProcessed=onPropChangeEvent(h,~,event)





    wasProcessed=false;


    source=event.Source;
    if isa(source,"DAStudio.DAObjectProxy")
        source=source.getMCOSObjectReference;
    end
    if~isa(source,'Simulink.Line')
        return;
    end


    if~isequal(source.getParent,h.daobject)
        return;
    end
    wasProcessed=true;


    if~h.isLoaded||~h.signalsPopulated
        return;
    end


    port=source.getSourcePort;
    for idx=1:length(h.signalChildren)
        if isequal(h.signalChildren(idx).daobject,port)


            if~strcmp(port.DataLogging,'on')
                delete(h.signalChildren(idx));
                h.signalChildren(idx)=[];
                h.fireListChanged;
            else

                h.signalChildren(idx).refreshSettings;
            end

            return;
        end
    end



    if~strcmp(port.DataLogging,'on')
        return;
    end


    bpath=h.getFullMdlRefPath.convertToCell;
    if length(bpath)==1
        bpath=port.Parent;
    else
        bpath=[bpath(1:end-1);port.Parent];
    end




    sig=Simulink.SimulationData.SignalLoggingInfo;
    sig.BlockPath=bpath;
    sig.OutputPortIndex=port.PortNumber;


    child=SigLogSelector.LogSignalObj(sig);
    if isempty(h.signalChildren)
        h.signalChildren=child;
    else
        h.signalChildren(end+1)=child;
    end
    h.signalChildren(end).hParent=h;
    h.signalChildren(end).refreshSettings;


    h.fireListChanged;

end

