function res=hasIndexedPath(node,idxPath)





    import simscape.logging.internal.*

    res=~isempty(indexedNode(node,idxPath));
end