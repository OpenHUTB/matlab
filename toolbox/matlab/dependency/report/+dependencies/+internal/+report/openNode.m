function openNode(location)

    node=dependencies.internal.graph.Node.createFileNode(location);
    dependencies.internal.action.open(node);

end
