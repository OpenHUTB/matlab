function blkH=isConcExecSubsystem(slbh,modelName)




    blkH=0;
    typ=get_param(slbh,'BlockType');
    blk=get_param(slbh,'Object');



    if strcmp(typ,'SubSystem')&&blk.isSynthesized&&...
        strcmp(get_param(modelName,'EnableConcurrentExecution'),'on')&&...
        strcmp(get_param(modelName,'ConcurrentTasks'),'on')&&...
        strcmp(get_param(modelName,'ExplicitPartitioning'),'on')
        bl=getCompiledBlockList(get_param(slbh,'ObjectAPI_FP'));
        bt=get_param(bl,'BlockType');
        if numel(bl)==1
            if strcmp(bt,'ModelReference')
                blkH=bl;
            end
        else







            notTTB=~strcmp(bt,'TaskTransBlk');
            bt_filt=bt(notTTB);
            if numel(bt_filt)==1&&strcmp(bt_filt,'ModelReference')
                blkH=bl(notTTB);
            end
        end
    end
end


