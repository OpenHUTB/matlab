function LidarPointCloudGenerator(obj)

    if isR2019bOrEarlier(obj.ver)
 blks=findBlocksWithMaskType(obj,'lidarPointCloudGenerator');
        obj.replaceWithEmptySubsystem(blks);

    end
end