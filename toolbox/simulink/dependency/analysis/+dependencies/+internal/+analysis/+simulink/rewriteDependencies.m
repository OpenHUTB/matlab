function deps=rewriteDependencies(deps,newNode,oldName,newName)




    import dependencies.internal.graph.Component;

    for n=1:length(deps)
        dep=deps(n);

        upComp=dep.UpstreamComponent;
        if upComp~=Component.createRoot(dep.UpstreamNode)
            newPath=regexprep(dep.UpstreamComponent.Path,['^',oldName],newName);
            newBlockPath=regexprep(dep.UpstreamComponent.BlockPath,['^',oldName],newName);
            upComp=Component(newNode,newPath,upComp.Type,upComp.LineNumber,upComp.EnclosingFunction,newBlockPath);
        end

        deps(n)=dependencies.internal.graph.Dependency(...
        upComp,dep.DownstreamComponent,dep.Type,dep.Relationship);
    end

end
