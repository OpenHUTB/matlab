function EnsemblePredict(obj)




    if isR2020bOrEarlier(obj.ver)


        blks=findBlocksWithMaskType(obj,'ClassificationEnsemble Predict');
        obj.replaceWithEmptySubsystem(blks);

        blks=findBlocksWithMaskType(obj,'RegressionEnsemble Predict');
        obj.replaceWithEmptySubsystem(blks);
    end