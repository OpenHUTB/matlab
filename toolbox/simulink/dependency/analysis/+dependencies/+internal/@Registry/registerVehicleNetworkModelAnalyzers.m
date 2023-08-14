function analyzers=registerVehicleNetworkModelAnalyzers(~)




    analyzers=dependencies.internal.analysis.simulink.ModelAnalyzer.empty(1,0);

    if dependencies.internal.util.isProductInstalled('VN')
        analyzers=dependencies.internal.analysis.simulink.VehicleNetworkAnalyzer;
    end

end

