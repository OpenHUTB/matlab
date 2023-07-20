function RGPPredict(obj)




    if isR2021bOrEarlier(obj.ver)



        blks=findBlocksWithMaskType(obj,'RegressionGP Predict');
        obj.replaceWithEmptySubsystem(blks);
    end