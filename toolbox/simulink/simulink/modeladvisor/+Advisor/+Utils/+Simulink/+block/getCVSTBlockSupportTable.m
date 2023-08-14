function output=getCVSTBlockSupportTable
    persistent blkTypes;
    if isempty(blkTypes)
        blkTypes=Advisor.Utils.Simulink.block.getBlockTypeListFromLibraryViaEval('vision.internal.librarylist');
        blkTypes=Advisor.Utils.Simulink.block.convertcell_into_BlkTypeList(blkTypes);
    end
    output=blkTypes;
end









