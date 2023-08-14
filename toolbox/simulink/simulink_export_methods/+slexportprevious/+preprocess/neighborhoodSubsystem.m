function neighborhoodSubsystem(obj)



    blkType='Neighborhood';

    if isR2022aOrEarlier(obj.ver)

        neighborhoodBlks=slexportprevious.utils.findBlockType(obj.modelName,blkType);
        if~isempty(neighborhoodBlks)
            for i=1:length(neighborhoodBlks)
                blk=neighborhoodBlks{i};
                obj.replaceWithEmptySubsystem(blk);
            end
        end
    end



