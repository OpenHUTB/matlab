function ScopeLaunchStatus(blockHandle,setUEStatusBar)


    persistent origStatusStringValue;

    if setUEStatusBar
        matlabshared.scopes.UnifiedScope.useWaitbar(false);
        origStatusStringValue=get_param(bdroot(blockHandle),'StatusString');
        statusMsg=message('Spcuilib:scopes:ScopeLoadingStatus').getString;
        set_param(bdroot(blockHandle),'StatusString',statusMsg);
    else
        set_param(bdroot(blockHandle),'StatusString',origStatusStringValue);


        origStatusStringValue='';
    end



