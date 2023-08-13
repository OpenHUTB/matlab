function WorldToVehicle(obj)

    if isR2019bOrEarlier(obj.ver)
        blks=findBlocksWithMaskType(obj,'driving.scenario.internal.WorldToVehicle');
        obj.replaceWithEmptySubsystem(blks);
    end