function[deps,resolved,updatable]=findCaseSensitiveDependencies(file)




    unresolved=i_findUnresolvedDependencies(file);
    [deps,resolved]=i_findCaseInsensitiveMatches(unresolved);
    updatable=i_findAutoUpdatable(deps);

end


function deps=i_findUnresolvedDependencies(file)


    import dependencies.internal.graph.NodeFilter.*;
    import dependencies.internal.graph.DependencyFilter.*;
    nodeFilter=nodeType("TestHarness");
    unresolvedFilter=downstream(~isResolved);
    depFilter=any(unresolvedFilter,dependencyType("TestHarness"));

    node=dependencies.internal.graph.Node.createFileNode(file);

    nodeAnalyzers=[
    dependencies.internal.analysis.matlab.MatlabNodeAnalyzer
    dependencies.internal.analysis.simulink.SimulinkNodeAnalyzer
    dependencies.internal.analysis.simulink.TestHarnessNodeAnalyzer
    ];

    analyzer=dependencies.internal.engine.BasicAnalyzer(nodeAnalyzers);
    analyzer.NodePredicate=@(n)n==node|apply(nodeFilter,n);
    analyzer.DependencyPredicate=@(d)apply(depFilter,d);

    graph=analyzer.analyze(node);
    deps=graph.Dependencies;
    deps=deps(apply(unresolvedFilter,deps));

end


function[deps,resolved]=i_findCaseInsensitiveMatches(unresolved)


    deps=dependencies.internal.graph.Dependency.empty;
    resolved={};

    for dep=unresolved
        path=i_resolve(dep.DownstreamNode.Location{1});
        if~isempty(path)
            [~,name,ext]=fileparts(path);
            if ismember(ext,[".slx",".mdl",".slxp",".mdlp"])
                deps(end+1)=dep;%#ok<AGROW>
                resolved{end+1}=name;%#ok<AGROW>
            end
        end
    end

end

function path=i_resolve(symbol)



    try
        path=which(symbol);
    catch
        path='';
    end

end


function accept=i_findAutoUpdatable(deps)


    if isempty(deps)
        accept=false(0);
        return;
    end

    depTypes=[deps.Type];
    depTypes=[depTypes.ID];
    refTypes=dependencies.internal.Registry.Instance.getRefactoringTypes;
    accept=ismember(depTypes,refTypes);

end
