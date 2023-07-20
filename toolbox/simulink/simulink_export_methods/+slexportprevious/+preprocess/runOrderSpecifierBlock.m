function runOrderSpecifierBlock(obj)




    if isR2019bOrEarlier(obj.ver)
        blkType='RunOrderSpecifier';
        scBlks=slexportprevious.utils.findBlockType(obj.modelName,blkType);
        obj.replaceWithEmptySubsystem(scBlks);
    end
end

