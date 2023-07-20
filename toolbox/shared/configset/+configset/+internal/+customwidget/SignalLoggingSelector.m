function updateDeps=SignalLoggingSelector(cs,~)



    updateDeps=false;
    mdl=cs.getModel;
    if~isempty(mdl)
        SigLogSelector.launch('Create',mdl);
    end
