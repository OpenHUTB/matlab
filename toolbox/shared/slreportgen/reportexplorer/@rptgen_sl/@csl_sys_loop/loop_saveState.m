function currState=loop_saveState(h)





    currState.CurrentSystem=get_param(0,'CurrentSystem');

    adSL=rptgen_sl.appdata_sl;
    currState.adsl={'Context',adSL.Context};