function[isSupported,errmsg]=isSupportedAtomicSS(subsys)




    errmsg='';
    isSupported=false;
    if~coder.internal.connectivity.featureOn('SILPILAtomicSubsystem')
        return;
    end

    model=bdroot(subsys);

    [errmsg,warnmsg]=rtw.pil.AtomicSubsystemManager.compatibilityCheck(model,...
    subsys);

    if isempty(errmsg)
        isSupported=true;

        rtw.pil.SubsystemManager.reportWarningsAndErrors([],warnmsg);
    end

end
