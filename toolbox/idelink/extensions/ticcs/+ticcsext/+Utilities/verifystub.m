function verified=verifystub(cc)




    reqdpath=ticcsext.Utilities.LfCProperty('inprocFile-current-client');
    stubpath=cc.invokeIdeModule('GetStubPath');
    verified=(strcmpi(reqdpath,stubpath)==1);

