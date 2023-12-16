function imuSensor(obj)

    if isR2021aOrEarlier(obj.ver)
        blocks=obj.findBlocksWithMaskType('fusion.simulink.imuSensor');
        for blkIdx=1:numel(blocks)
            blk=blocks{blkIdx};

            numElements=9;
            accelVal=slResolve(get_param(blk,'AccelParamsAxesMisalignment'),blk);
            gyroVal=slResolve(get_param(blk,'GyroParamsAxesMisalignment'),blk);
            magVal=slResolve(get_param(blk,'MagParamsAxesMisalignment'),blk);
            shouldRemove=false;
            shouldRemove=shouldRemove|isequal(numel(accelVal),numElements);
            shouldRemove=shouldRemove|isequal(numel(gyroVal),numElements);
            shouldRemove=shouldRemove|isequal(numel(magVal),numElements);

            msg=DAStudio.message('shared_positioning:imuSensor:EmptySubsystemIMUNewFeatures');
            err=DAStudio.message('shared_positioning:imuSensor:NewFeaturesNotAvailable');
            if shouldRemove
                obj.replaceWithEmptySubsystem(blk,msg,err);
            end
        end
    end


end
