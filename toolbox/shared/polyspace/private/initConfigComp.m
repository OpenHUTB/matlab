function[pslinkcc,configSet,oldSysToAnalyze]=initConfigComp(systemH,silentMode)

    narginchk(1,2);

    if nargin<2
        silentMode=false;
    end

    modelH=bdroot(systemH);

    oldSysToAnalyze=[];
    [pslinkcc,configSet]=getConfigComp(modelH);
    if isempty(pslinkcc)
        dirty=get_param(modelH,'Dirty');
        attachConfigComp(systemH,silentMode);
        set_param(modelH,'Dirty',dirty);
        [pslinkcc,configSet]=getConfigComp(modelH);
    else
        oldSysToAnalyze=pslinkcc.PSSystemToAnalyze;
        pslinkcc.PSSystemToAnalyze=get_param(systemH,'Object').getFullName();
    end

end
