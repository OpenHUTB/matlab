function compileNoSubsasgn(visitor,treei,treeIdx,~,treeIndex)





    dosubs=visitor.doSubsref(treeIndex,size(treei));



    if~dosubs


        compileNoSubasgnNoSubsref(visitor,treeIdx);
    else


        treeIdxStr=compileIndexingString(visitor,treeIndex);

        compileNoSubsasgnWithSubsref(visitor,treeIdx,...
        treeIdxStr);
    end

end
