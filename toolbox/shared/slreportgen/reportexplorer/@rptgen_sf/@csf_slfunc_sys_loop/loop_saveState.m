function currState=loop_saveState(h)





    currState.CurrentSystem=get_param(0,'CurrentSystem');

    adSF=rptgen_sf.appdata_sf;
    currState.adsf={'Context',adSF.Context};