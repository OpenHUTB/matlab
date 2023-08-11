function RadarDetectionGenerator(obj)

    if isR2018bOrEarlier(obj.ver)
        newRef='drivingscenarioandsensors/Radar Detection Generator';
        oldRef='drivinglib/Radar Detection Generator';
        obj.appendRule(['<ExternalFileReference<Reference|"',newRef,'":repval "',oldRef,'">>']);
        obj.appendRule(['<Block<SourceBlock|"',newRef,'":repval "',oldRef,'">>']);
    end

    if isR2017aOrEarlier(obj.ver)



        blks=findBlocksWithMaskType(obj,'radarDetectionGenerator');
        obj.replaceWithEmptySubsystem(blks);
    end