function blocksInSUD=areBlocksUnderSUD(blockPaths,SUD)





    aContainer=fxptopo.internal.SLTopoWithMdlRefContainer();
    aContainer.buildGraph(SUD);
    blocksInSUD=fxptopo.internal.areBlocksInContainer(blockPaths,aContainer);
end
