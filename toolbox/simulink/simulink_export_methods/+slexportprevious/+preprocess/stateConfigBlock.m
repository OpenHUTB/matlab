function stateConfigBlock(obj)




    if isR2014bOrEarlier(obj.ver)
        blkType='StateControl';
        scBlks=slexportprevious.utils.findBlockType(obj.modelName,blkType);
        obj.replaceWithEmptySubsystem(scBlks);
    end
end
