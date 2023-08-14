function node=addNodeFromSpecification(this,component)


    node=this.instanceModel.addInstanceForSpecification(component);
    node.setName(component.getName);
    this.children.add(node);
    node.populateDescendants();
end


