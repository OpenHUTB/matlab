function loop_restoreState(h,oldState)





    set_param(0,'CurrentSystem',oldState.CurrentSystem);

    set(rptgen_sf.appdata_sf,oldState.adsf{:});