function imageBlocks(obj)




    if isReleaseOrEarlier(obj.ver,'R2021a')
        blkType={'ToImage','FromImage'};
        for i=1:numel(blkType)
            allBlksOfAType=slexportprevious.utils.findBlockType(obj.modelName,blkType{i});
            obj.replaceWithEmptySubsystem(allBlksOfAType);
        end
    end

    if isReleaseOrEarlier(obj.ver,'R2021b')



        typeAttributesBlocks=slexportprevious.utils.findBlockType(obj.modelName,"TypeAttributes");
        obj.replaceWithEmptySubsystem(typeAttributesBlocks);
    end

end