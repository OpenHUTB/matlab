function CuboidTo3DSimulation(obj)

    if isR2019bOrEarlier(obj.ver)

        blks=findBlocksWithMaskType(obj,'driving.scenario.internal.CuboidTo3DSimulation');
        obj.replaceWithEmptySubsystem(blks);
    end