function NeuralNetworkPredict(obj)

    if isR2021aOrEarlier(obj.ver)
        blks=findBlocksWithMaskType(obj,'ClassificationNeuralNetwork Predict');
        obj.replaceWithEmptySubsystem(blks);

        blks=findBlocksWithMaskType(obj,'RegressionNeuralNetwork Predict');
        obj.replaceWithEmptySubsystem(blks);
    end