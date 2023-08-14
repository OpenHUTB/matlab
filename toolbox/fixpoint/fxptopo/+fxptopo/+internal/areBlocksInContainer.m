function blocksInContainer=areBlocksInContainer(blockPaths,aContainer)





    blockSID=Simulink.ID.getSID(blockPaths);
    blocksInContainer=ismember(blockSID,aContainer.Graph.Nodes.SID);
end
