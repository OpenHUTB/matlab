function basecodes=findProductDependenciesForModel(modelFullPath)



    import dependencies.internal.analysis.toolbox.ToolboxAnalyzer.analyzeToolboxes

    try
        node=dependencies.internal.graph.Node.createFileNode(modelFullPath);

        analyzer=dependencies.internal.engine.BasicAnalyzer;

        dependencies.internal.analysis.simulink.setupParameterAnalysis(analyzer);

        analyzer.Filters=[onlyAnalyze(node),analyzeToolboxes(false)];

        unfilteredGraph=analyzer.analyze(node);
        graph=dependencies.internal.analysis.toolbox.reduceOptionalProducts(unfilteredGraph);
        nodes=graph.Nodes;

        filter=dependencies.internal.graph.NodeFilter.nodeType("Product");
        productNodes=nodes(filter.apply(nodes));

        basecodes=arrayfun(@(node)join(node.Location,','),productNodes);
        if isempty(basecodes)
            basecodes={};
        end

    catch ME %#ok<NASGU>
        basecodes={};
    end

end

function filter=onlyAnalyze(node)
    import dependencies.internal.graph.NodeFilter.isMember;
    import dependencies.internal.graph.NodeFilter.nodeType;
    import dependencies.internal.engine.filters.DelegateFilter;
    nodeFilter=isMember(node)|nodeType("TestHarness");
    filter=DelegateFilter(nodeFilter);
end
