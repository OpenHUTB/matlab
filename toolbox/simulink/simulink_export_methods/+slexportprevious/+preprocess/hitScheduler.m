function hitScheduler(obj)





    if isReleaseOrEarlier(obj.ver,'R2022a')
        blkType='HitScheduler';
        allBlksOfAType=slexportprevious.utils.findBlockType(obj.modelName,blkType);
        obj.replaceWithEmptySubsystem(allBlksOfAType);
    end

end

