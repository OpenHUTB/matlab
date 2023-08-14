function blkH=isMatlabSystemBlockSubsystem(slbh)







    blkH=0;
    typ=get_param(slbh,'BlockType');
    blk=get_param(slbh,'Object');



    if strcmp(typ,'SubSystem')&&blk.isSynthesized
        bl=getCompiledBlockList(get_param(slbh,'ObjectAPI_FP'));
        bt=get_param(bl(1),'BlockType');
        if numel(bl)==1&&strcmp(bt,'MATLABSystem')
            blkH=bl;
        end
    end
end
