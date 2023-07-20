function analyzeButtonRefresher(cbinfo,action)




    appContext=multicoredesigner.internal.toolstrip.getappcontextobj(cbinfo);
    if isempty(appContext)
        action.enabled=false;
        return;
    end

    action.enabled=appContext.AnalysisEnabled;
end


