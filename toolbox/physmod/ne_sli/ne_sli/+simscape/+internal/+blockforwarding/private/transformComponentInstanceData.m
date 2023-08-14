function[newInstanceData,newBlockPath]=transformComponentInstanceData(instanceData,blkVersion,targetVersion,newBlockPath)



    import simscape.internal.blockforwarding.BlockSettings;
    import simscape.internal.componentforwarding.VersionTransformSequence
    import simscape.internal.componentforwarding.applyTransformSequence
    import simscape.internal.componentforwarding.ComponentData


    blkSettings=...
    BlockSettings({instanceData.Name},{instanceData.Value},blkVersion,newBlockPath);

    versionTransforms=...
    VersionTransformSequence.get(blkSettings.getClass(),...
    blkSettings.getVersion(),...
    targetVersion);

    blkSettings=applyTransformSequence(blkSettings,versionTransforms);

    cd=ComponentData(blkSettings.getClass(),targetVersion);

    cd=cd.applySettings(blkSettings);

    newInstanceData=translateComponentDataToBlockData(cd);
    newBlockPath=blkSettings.getNewBlockPath();

end