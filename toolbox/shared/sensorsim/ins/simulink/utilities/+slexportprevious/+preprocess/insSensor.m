function insSensor(obj)




    if isR2021aOrEarlier(obj.ver)
        blocks=obj.findBlocksWithMaskType('fusion.internal.simulink.insSensor');
        for blkIdx=1:numel(blocks)
            blk=blocks{blkIdx};










            shouldRemove=false;
            shouldRemove=shouldRemove|strcmpi(get_param(blk,'TimeInput'),'on');
            shouldRemove=shouldRemove|strcmpi(get_param(blk,'UseAccelAndAngVel'),'on');
            shouldRemove=shouldRemove|~isequal(slResolve(get_param(blk,'MountingLocation'),blk),[0,0,0]);
            shouldRemove=shouldRemove|~isscalar(slResolve(get_param(blk,'PositionAccuracy'),blk));

            msg=DAStudio.message('shared_sensorsim_ins:insSensor:EmptySubsystemINSNewFeatures');
            err=DAStudio.message('shared_sensorsim_ins:insSensor:NewFeaturesNotAvailable');
            if shouldRemove
                obj.replaceWithEmptySubsystem(blk,msg,err);
            end
        end
    end

end

