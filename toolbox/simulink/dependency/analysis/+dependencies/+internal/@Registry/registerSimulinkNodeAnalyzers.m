function analyzers=registerSimulinkNodeAnalyzers(~)




    analyzers=dependencies.internal.analysis.NodeAnalyzer.empty;

    if dependencies.internal.util.isProductInstalled('SL','simulink')
        analyzers=[
        dependencies.internal.analysis.simulink.SimulinkNodeAnalyzer
        dependencies.internal.analysis.simulink.TestHarnessNodeAnalyzer
        dependencies.internal.analysis.simulink.DataDictionaryNodeAnalyzer
        dependencies.internal.analysis.simulink.RTWMakeConfigAnalyzer
        dependencies.internal.analysis.simulink.ProtectedModelAnalyzer
        dependencies.internal.analysis.simulink.TLCNodeAnalyzer
        dependencies.internal.analysis.simulink.RequirementSetNodeAnalyzer
        dependencies.internal.analysis.simulink.RequirementLinkSetNodeAnalyzer
        ];
    end

    if dependencies.internal.util.isProductInstalled('SS','simscape')
        analyzers(end+1)=dependencies.internal.analysis.simulink.SimscapeNodeAnalyzer;
        analyzers(end+1)=dependencies.internal.analysis.simulink.SimscapeProtectedNodeAnalyzer;
    end

    if dependencies.internal.util.isProductInstalled('SZ','simulinktest')
        analyzers(end+1)=dependencies.internal.analysis.simulink.TestManagerNodeAnalyzer;
    end

end

