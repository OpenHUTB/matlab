function slddFiles=getDataDictionariesUsedByModel(modelName)




    modelAnalyzer=dependencies.internal.analysis.simulink.SimulinkNodeAnalyzer([...
    dependencies.internal.analysis.simulink.ModelReferenceAnalyzer,...
    dependencies.internal.analysis.simulink.DataDictionaryAnalyzer]);

    slddAnalyzer=dependencies.internal.analysis.simulink.DataDictionaryNodeAnalyzer;

    analyzer=dependencies.internal.engine.BasicAnalyzer([modelAnalyzer,slddAnalyzer]);
    analyzer.ExceptionHandler=@(n,ME)locDepAnalysisError(n,ME,modelName);
    analyzer.GraphFactory=@dependencies.internal.graph.DigraphFactory;

    node=dependencies.internal.graph.Node.createFileNode(which(modelName));
    depGraph=analyzer.analyze(node);
    filePaths=depGraph.Nodes.Name;


    slddFiles=filePaths(endsWith(filePaths,'.sldd','IgnoreCase',true));
end

function locDepAnalysisError(n,ME,modelName)
    err=MException(message('Simulink:Commands:ErrorAnalyzingFile',n.Location{1}));
    msld=MSLDiagnostic(err);
    msld=msld.addCause(MSLDiagnostic(ME));
    msld.reportAsError(modelName,false);
end