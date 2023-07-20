function analyzers=registerSimulinkFunctionAnalyzers(~)





    import dependencies.internal.analysis.matlab.handlers.*;

    analyzers=dependencies.internal.analysis.matlab.FunctionAnalyzer.empty;

    if dependencies.internal.util.isProductInstalled('SL','simulink')
        analyzers=[
ModelOpenAnalyzer
DataDictionaryOpenAnalyzer
SimulinkProjectAnalyzer
AddBlockAnalyzer
InGlobalScopeAnalyzer
        ];
    end

end

