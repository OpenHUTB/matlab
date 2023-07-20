




function parentBlocks=i_getAllParentBlksExcludingRoot(refBlkForTmpBlk)






    hierLevels=Simulink.variant.utils.splitPathInHierarchy(refBlkForTmpBlk);
    parentBlocks=cell(1,numel(hierLevels)-2);
    for iter=1:numel(hierLevels)-2
        parentBlocks{iter}=strjoin(hierLevels(1:iter+1),'/');
    end
end


