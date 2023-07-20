function[fileDeps,prodDeps,tbxDeps]=getDownstreamDependencies(this,fileNode)




    import dependencies.internal.graph.DependencyFilter;
    import dependencies.internal.graph.NodeFilter;
    import dependencies.internal.graph.Type;
    deps=this.Graph.getDownstreamDependencies(fileNode);

    fileFilter=NodeFilter.nodeType(Type.FILE);
    fileDepFilter=DependencyFilter.downstream(fileFilter);

    prodFilter=NodeFilter.nodeType(Type.PRODUCT);
    prodDepFilter=DependencyFilter.downstream(prodFilter);
    tbxFilter=NodeFilter.nodeType(Type.TOOLBOX);
    tbxDepFilter=DependencyFilter.downstream(tbxFilter);

    fileDeps=deps(fileDepFilter.apply(deps));
    prodDeps=deps(prodDepFilter.apply(deps));
    tbxDeps=deps(tbxDepFilter.apply(deps));
end
