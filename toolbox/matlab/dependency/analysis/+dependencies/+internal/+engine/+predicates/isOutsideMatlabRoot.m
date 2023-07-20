function accept=isOutsideMatlabRoot(dependency)




    import dependencies.internal.graph.NodeFilter.nodeType;
    import dependencies.internal.graph.NodeFilter.fileWithin;
    import dependencies.internal.graph.DependencyFilter.downstream;

    filter=downstream(all(...
    nodeType({'File','Product','Toolbox'}),...
    not(fileWithin({matlabroot}))));
    accept=filter.apply(dependency);

end
