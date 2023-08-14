function changeEvolutionName(this,ei)





    node=this.EvolutionIdToNode(ei.Id);

    this.Syntax.modify(@(operations)operations.setTitle(node,ei.getName));
end
