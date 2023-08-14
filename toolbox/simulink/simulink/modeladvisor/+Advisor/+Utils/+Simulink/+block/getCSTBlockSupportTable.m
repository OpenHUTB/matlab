function output=getCSTBlockSupportTable
    persistent blkTypes;
    if isempty(blkTypes)
        blkTypes=Advisor.Utils.Simulink.block.getBlockTypeListFromLibraryViaEval('commliblist');
        blkTypes=Advisor.Utils.Simulink.block.convertcell_into_BlkTypeList(blkTypes);
    end
    output=blkTypes;
end

