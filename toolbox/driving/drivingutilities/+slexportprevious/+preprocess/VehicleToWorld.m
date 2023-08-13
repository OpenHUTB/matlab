function VehicleToWorld(obj)

    if isR2019bOrEarlier(obj.ver)
        blks=findBlocksWithMaskType(obj,'driving.scenario.internal.VehicleToWorld');
        obj.replaceWithEmptySubsystem(blks);
    end
