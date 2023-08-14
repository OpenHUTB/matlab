function loop_restoreState(h,oldState)





    set_param(0,'CurrentSystem',oldState.CurrentSystem);

    set(rptgen_sl.appdata_sl,oldState.adsl{:});