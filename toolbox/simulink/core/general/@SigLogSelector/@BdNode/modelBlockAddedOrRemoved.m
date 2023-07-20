function modelBlockAddedOrRemoved(h)






    assert(isempty(h.hParent));
    if h.isClosing
        return;
    end


    me=SigLogSelector.getExplorer;
    me.displayMdlRefHelp=h.containsModelReference;


    h.firePropertyChange;


    me=SigLogSelector.getExplorer;
    val=h.getOverrideMode;
    me.setOverrideModeValue(val);

end

