function fileNames=getDependentFiles(model)




    options=i_makeOptions();
    rootNode=dependencies.internal.graph.Node.createFileNode(which(model));

    nodeFilter=dependencies.internal.graph.NodeFilter.wrapNode(@(node)i_analyzeNode(node,rootNode));
    filters=dependencies.internal.engine.filters.DelegateFilter(nodeFilter);

    for filter=filters
        options.Filters(end+1)=filter;
    end
    graph=dependencies.internal.engine.analyze(rootNode,options);
    dependencySet=dependencies.internal.graph.DigraphFactory.createFrom(graph);

    fileNames=dependencySet.Nodes.Name;
end

function tf=i_analyzeNode(node,rootNode)
    tf=(node==rootNode)||i_isLibrary(node)||i_isMATLABCode(node);
end

function tf=i_isLibrary(node)
    try
        tf=node.isFile()&&endsWith(node.Location{1},[".slx",".mdl"])&&Simulink.MDLInfo(node.Location{1}).IsLibrary;
    catch
        tf=false;
    end
end

function tf=i_isMATLABCode(node)
    tf=node.isFile()&&endsWith(node.Location{1},[".m",".mlx"]);
end

function options=i_makeOptions()
    persistent sOptions;
    if isempty(sOptions)
        sOptions=dependencies.internal.engine.AnalysisOptions;
        sOptions=i_removeRedundantAnalyzers(sOptions);
    end
    options=sOptions;
end

function options=i_removeRedundantAnalyzers(options)
    analyzers=options.NodeAnalyzers;
    redundant=false(size(analyzers));

    redundantNodeAnalyzers=[
"dependencies.internal.analysis.simulink.DataDictionaryNodeAnalyzer"
"dependencies.internal.analysis.simulink.RequirementSetNodeAnalyzer"
"dependencies.internal.analysis.simulink.RequirementLinkSetNodeAnalyzer"
"dependencies.internal.analysis.simulink.RTWMakeConfigAnalyzer"
"dependencies.internal.analysis.simulink.TestManagerNodeAnalyzer"
"dependencies.internal.analysis.simulink.TestHarnessNodeAnalyzer"
"dependencies.internal.analysis.simulink.TLCNodeAnalyzer"
    ];

    for n=1:length(analyzers)
        analyzer=analyzers(n);
        redundant(n)=ismember(class(analyzer),redundantNodeAnalyzers);
    end

    analyzers=analyzers(~redundant);

    for n=1:length(analyzers)
        analyzer=analyzers(n);
        if isa(analyzer,...
            "dependencies.internal.analysis.simulink.SimulinkModelAnalyzer")
            analyzer=i_removeRedundantModelAnalyzers(analyzer);
            analyzer.AnalyzeUnsavedChanges=true;
            analyzers(n)=analyzer;
        elseif isa(analyzer,...
            "dependencies.internal.analysis.matlab.MatlabNodeAnalyzer")
            analyzer.FindRequirements=false;
            analyzers(n)=analyzer;
        end
    end

    options.NodeAnalyzers=analyzers;
end

function nodeAnalyzer=i_removeRedundantModelAnalyzers(nodeAnalyzer)
    modelAnalyzers=nodeAnalyzer.Analyzers;

    redundantModelAnalyzers=[
"dependencies.internal.analysis.simulink.CodeGenAnalyzer"
"dependencies.internal.analysis.simulink.TestHarnessAnalyzer"
"dependencies.internal.analysis.simulink.RequirementsAnalyzer"
    ];
    redundant=false(size(modelAnalyzers));
    for n=1:length(modelAnalyzers)
        analyzer=modelAnalyzers(n);
        redundant(n)=ismember(class(analyzer),redundantModelAnalyzers);
    end

    nodeAnalyzer=feval(class(nodeAnalyzer),modelAnalyzers(~redundant));
end
