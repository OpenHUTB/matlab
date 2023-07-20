function isBEblock=isBusExpansionBlock(slbh)




    isBEblock=false;
    if isempty(slbh)||~isprop(get_param(slbh,'Object'),'BlockType')
        return;
    end

    typ=get_param(slbh,'BlockType');
    blk=get_param(slbh,'ObjectAPI_FP');


    if blk.isSynthesized&&~strcmp(typ,'SubSystem')&&...
        strcmp(blk.getSyntReason,'SL_SYNT_BLK_REASON_BUSEXPANSION')
        isBEblock=true;
    end
end
