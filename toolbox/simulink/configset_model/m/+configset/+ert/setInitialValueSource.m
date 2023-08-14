function actVal=setInitialValueSource(~,newVal)

    actVal=newVal;

    persistent PERSISTENT_WARN_STATE
    if(isempty(PERSISTENT_WARN_STATE))
        wState=warning('backtrace','off');
        warning(DAStudio.message('RTW:configSet:ERTTargetWarning'));
        warning(wState);



        PERSISTENT_WARN_STATE=1;
    end
end
