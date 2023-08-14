function target=resolveProfile(handler,node,name)




    target=handler.Resolver.findFile(node,name,dependencies.internal.analysis.sysarch.ProfileNodeAnalyzer.Extensions);
    if target.Resolved&&~dependencies.internal.analysis.sysarch.isProfile(target.Location{1})

        target=dependencies.internal.graph.Node.createFileNode(name);
    end

end
