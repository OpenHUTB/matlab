function SVMPredict(obj)




    if isR2020aOrEarlier(obj.ver)


        blks=findBlocksWithMaskType(obj,'ClassificationSVM Predict');
        obj.replaceWithEmptySubsystem(blks);

        blks=findBlocksWithMaskType(obj,'RegressionSVM Predict');
        obj.replaceWithEmptySubsystem(blks);
    end