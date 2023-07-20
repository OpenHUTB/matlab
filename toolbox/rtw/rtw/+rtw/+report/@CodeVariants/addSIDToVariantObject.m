function variantObject=addSIDToVariantObject(~,variantObject)
    blockPaths=variantObject.ReferencedByBlockPaths;
    numRefBlocks=size(blockPaths,1);
    for rb=1:numRefBlocks
        variantObject.ReferencedByBlockSID{rb}=Simulink.ID.getSID(blockPaths(rb,:));
    end
end
