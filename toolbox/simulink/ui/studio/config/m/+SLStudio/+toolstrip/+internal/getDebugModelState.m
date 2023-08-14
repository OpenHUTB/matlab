function state=getDebugModelState(cbinfo)
    persistent mwt_available;
    if isempty(mwt_available),mwt_available=isempty(javachk('mwt'));end

    sim_mode=get_param(cbinfo.model.handle,'SimulationMode');
    sim_mode_checked=strcmpi(sim_mode,'rapid-accelerator')||strcmpi(sim_mode,'external');
    fast_restart_disabled=strcmpi(get_param(cbinfo.model.Handle,'InitializeInteractiveRuns'),'off');
    enabled=strcmpi(get_param(0,'SlDebugEnable'),'on');

    if enabled&&~sim_mode_checked&&mwt_available&&...
        ~SLStudio.Utils.isBlockDiagramCompiled(cbinfo)&&fast_restart_disabled

        state=true;
    else
        state=false;
    end
end