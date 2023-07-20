function loop_restoreState(h,oldState)






    set(rptgen_sl.appdata_sl,oldState.adsl{:});

    if~isempty(oldState.CurrentSystem)


        set_param(0,'currentsystem',oldState.CurrentSystem);
    end
