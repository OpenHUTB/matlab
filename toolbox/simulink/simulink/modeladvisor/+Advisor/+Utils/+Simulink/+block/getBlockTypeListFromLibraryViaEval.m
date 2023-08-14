function blkTypes=getBlockTypeListFromLibraryViaEval(liblist)
    blkTypes={};
    LibList=eval(liblist);
    for i=1:length(LibList.current)
        currentBlkList=Advisor.Utils.Simulink.block.getBlockTypeListFromLibrary(LibList.current{i});
        blkTypes=union(blkTypes,currentBlkList);
    end
    blkTypes=blkTypes';
end