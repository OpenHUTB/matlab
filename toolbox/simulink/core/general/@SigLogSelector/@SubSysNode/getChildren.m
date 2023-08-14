function children=getChildren(h)






    persistent empty_sig_obj;
    if isempty(empty_sig_obj)
        empty_sig_obj=SigLogSelector.EmptySigObj;
    end
    children=empty_sig_obj;



    me=SigLogSelector.getExplorer;
    if~h.isLoaded||isempty(me)||me.getRoot.isClosing||...
        isequal(me.getRoot.delayCallback,true)
        return;
    end


    if h.signalsPopulated
        if~isempty(h.signalChildren)
            children=h.signalChildren;
        end
        return;
    end


    mi=h.getModelLoggingInfo;
    fullPath=h.getFullMdlRefPath;
    [~,sigs]=mi.getSignalsForSubsystem(fullPath);
    if isempty(sigs)
        h.signalsPopulated=true;
        return;
    end


    children=[];
    for idx=1:length(sigs)
        if isempty(children)
            children=SigLogSelector.LogSignalObj(sigs(idx));
        else
            children(end+1)=SigLogSelector.LogSignalObj(sigs(idx));%#ok<AGROW>
        end
        children(end).hParent=h;
    end


    h.signalChildren=children;
    h.signalsPopulated=true;

end
