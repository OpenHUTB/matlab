function KNNPredict(obj)




    if isR2020aOrEarlier(obj.ver)


        blks=findBlocksWithMaskType(obj,'ClassificationKNN Predict');
        obj.replaceWithEmptySubsystem(blks);
    end