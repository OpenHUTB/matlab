function deleteEvolutionTree(projectInfo,treeInfo)





    projectInfo.EvolutionTreeManager.deleteEvolutionTree(treeInfo);
    projectInfo.EvolutionTreeManager.save;

    evolutions.internal.session.EventHandler.publish('EtmChanged');
end


