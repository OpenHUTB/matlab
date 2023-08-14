function analyzers=registerSystemComposerNodeAnalyzers(~)




    analyzers=dependencies.internal.analysis.NodeAnalyzer.empty;


    if dependencies.internal.analysis.findSymbol('systemcomposer.internal.arch.internal.getDependentProfiles').Resolved
        analyzers(end+1)=dependencies.internal.analysis.sysarch.ProfileNodeAnalyzer;
    end
    if dependencies.internal.analysis.findSymbol('systemcomposer.allocation.load').Resolved
        analyzers(end+1)=dependencies.internal.analysis.sysarch.AllocationSetNodeAnalyzer;
    end

end

