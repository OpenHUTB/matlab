function node=addNode(this,model,id)

    node=rmidd.Node(this.graph);
    node.id=id;

    model.nodes.append(node);
end


