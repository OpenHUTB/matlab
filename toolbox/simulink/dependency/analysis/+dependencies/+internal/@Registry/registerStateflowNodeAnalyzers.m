function analyzers=registerStateflowNodeAnalyzers(~)




    analyzers=dependencies.internal.analysis.NodeAnalyzer.empty;

    if dependencies.internal.util.isProductInstalled('SF','stateflow')
        analyzers(end+1)=dependencies.internal.analysis.simulink.StateflowNodeAnalyzer;
    end

end

