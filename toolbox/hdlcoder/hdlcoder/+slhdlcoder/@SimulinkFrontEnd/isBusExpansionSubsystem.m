function isBESS=isBusExpansionSubsystem(slbh)



    if isempty(slbh)||~isprop(get_param(slbh,'Object'),'BlockType')
        isBESS=false;
        return;
    end

    typ=get_param(slbh,'BlockType');
    blk=get_param(slbh,'ObjectAPI_FP');


    if strcmp(typ,'SubSystem')&&blk.isSynthesized&&...
        strcmp(blk.getSyntReason,'SL_SYNT_BLK_REASON_BUSEXPANSION')&&...
        ~strncmp(blk.Name,'BusConversion_InsertedFor',25)
        isBESS=true;
    else
        isBESS=false;
    end
end
