function slxcFiles=getSlxcFilesForModel(modelName)




    modelAnalyzer=dependencies.internal.analysis.simulink.SimulinkNodeAnalyzer([
    dependencies.internal.analysis.simulink.ModelReferenceAnalyzer
    dependencies.internal.analysis.simulink.PackagedModelAnalyzer]);

    analyzer=dependencies.internal.engine.BasicAnalyzer(modelAnalyzer);
    analyzer.ExceptionHandler=@(n,ME)locDepAnalysisError(n,ME,modelName);
    analyzer.GraphFactory=@dependencies.internal.graph.DigraphFactory;

    node=dependencies.internal.graph.Node.createFileNode(which(modelName));
    depGraph=analyzer.analyze(node);
    filePaths=depGraph.Nodes.Name;


    slxcFiles=filePaths(cellfun(@(s)~isempty(s),strfind(filePaths,'.slxc')));
end

function locDepAnalysisError(n,ME,modelName)
    err=MException(message('Simulink:Commands:ErrorAnalyzingFile',n.Location{1}));
    msld=MSLDiagnostic(err);
    msld=msld.addCause(MSLDiagnostic(ME));
    msld.reportAsError(modelName,false);
end