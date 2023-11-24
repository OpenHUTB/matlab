function TreePredict(obj)

    if isR2020bOrEarlier(obj.ver)
        blks=findBlocksWithMaskType(obj,'ClassificationTree Predict');
        obj.replaceWithEmptySubsystem(blks);
        blks=findBlocksWithMaskType(obj,'RegressionTree Predict');
        obj.replaceWithEmptySubsystem(blks);
    end