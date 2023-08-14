function compileWithSubsasgn(visitor,treei,treeIdx,forestIndex,treeIndex)





    dosubs=visitor.doSubsref(treeIndex,size(treei));



    if~dosubs

        forestIdxStr=compileIndexingString(visitor,forestIndex);


        compileWithSubasgnNoSubsref(visitor,treeIdx,forestIdxStr);
    else


        [treeIdxStr,forestIdxStr]=compileIdxStrings(visitor,treeIndex,forestIndex);

        compileWithSubsasgnWithSubsref(visitor,treeIdx,...
        forestIdxStr,treeIdxStr);
    end

end




function[treeIdxStr,forestIdxStr]=compileIdxStrings(visitor,treeIndex,forestIndex)


    treeIdxStr=compileIndexingString(visitor,treeIndex);

    forestIdxStr=compileIndexingString(visitor,forestIndex);
end
