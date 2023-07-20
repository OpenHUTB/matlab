function newNodeAnalyzers=setupAdditionalModelAnalyzers(oldNodeAnalyzers,additionalAnalyzersAsColumn)




    newNodeAnalyzers=oldNodeAnalyzers;

    idx=find(arrayfun(@i_isModelAnalyzer,oldNodeAnalyzers));
    for i=1:length(idx)
        j=idx(i);
        oldAnalyzer=oldNodeAnalyzers(j);
        mdlAnalyzers=[
        oldAnalyzer.Analyzers
additionalAnalyzersAsColumn
        ];
        class=metaclass(oldAnalyzer);
        newNodeAnalyzers(j)=feval(class.Name,mdlAnalyzers);
        newNodeAnalyzers(j).AnalyzeUnsavedChanges=oldAnalyzer.AnalyzeUnsavedChanges;
    end
end

function found=i_isModelAnalyzer(analyzer)
    found=isa(analyzer,'dependencies.internal.analysis.simulink.SimulinkModelAnalyzer')...
    &&~isa(analyzer,'dependencies.internal.analysis.simulink.StateflowNodeAnalyzer');
end
