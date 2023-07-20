function analyzers=registerSimulinkSharedAnalyzerFactories(~)




    analyzers=dependencies.internal.analysis.SharedAnalyzer.empty;

    if dependencies.internal.util.isProductInstalled('SL','simulink')
        analyzers=[dependencies.internal.analysis.simulink.DataDictionarySharedAnalyzerFactory
        dependencies.internal.analysis.simulink.SimulinkModelSharedAnalyzerFactory];
    end

end
