function analyzers=registerSystemComposerModelAnalyzers(~)




    analyzers=dependencies.internal.analysis.simulink.ModelAnalyzer.empty;


    if dependencies.internal.analysis.findSymbol('systemcomposer.internal.arch.internal.getDependentProfiles').Resolved
        analyzers=dependencies.internal.analysis.sysarch.ProfileAnalyzer;
    end

end

