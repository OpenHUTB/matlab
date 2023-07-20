function filter=analyzeNodes(nodes)




    import dependencies.internal.graph.NodeFilter.isMember
    import dependencies.internal.graph.DependencyFilter.acceptDependency
    import dependencies.internal.engine.filters.DelegateFilter

    filter=DelegateFilter(isMember(nodes),acceptDependency(false));

end

