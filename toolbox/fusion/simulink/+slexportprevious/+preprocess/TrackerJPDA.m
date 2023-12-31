function TrackerJPDA(obj)



    exportVer=obj.ver;


    if isR2021bOrEarlier(obj.ver)

        srcBlock='motalgorithmslib/Joint Probabilistic Data Association Multi Object Tracker';


        paramsToRemove={'MaxNumOOSMSteps',...
        'EnableMemoryManagement',...
        'AssignmentClustering',...
        'MaxNumDetectionsPerSensor',...
        'MaxNumDetectionsPerCluster',...
        'MaxNumTracksPerCluster',...
        'ClusterViolationHandling'};
        RemoveRule={...
        slexportprevious.rulefactory.removeInstanceParameter(...
        ['<SourceBlock|"',srcBlock,'">'],paramsToRemove,exportVer)};
        obj.appendRules(RemoveRule);


        if exportVer.isSLX
            rule=['<Block<SourceBlock|"',srcBlock,'"><InstanceData<OOSMHandling:repval "Terminate">>>'];
        else
            rule=slexportprevious.rulefactory.replaceInSourceBlock(...
            'OOSMHandling',...
            srcBlock,...
            'Terminate');
        end
        obj.appendRule(rule);
    end


    if isR2020bOrEarlier(obj.ver)



        newRef='motalgorithmslib/Joint Probabilistic Data Association Multi Object Tracker';
        oldRef='fusionlib/Joint Probabilistic Data Association Multi Object Tracker';
        obj.appendRule(['<Block<SourceBlock|"',newRef,'":repval "',oldRef,'">>']);

        Rules={...
        slexportprevious.rulefactory.renameInstanceParameter(...
        ['<SourceBlock|"',oldRef,'">'],...
        'StateParametersSimulink','StateParams',exportVer),...
        slexportprevious.rulefactory.removeInstanceParameter(...
        ['<SourceBlock|"',oldRef,'">'],...
        'TrackerIndex',exportVer),...
        slexportprevious.rulefactory.removeInstanceParameter(...
        ['<SourceBlock|"',oldRef,'">'],...
        'OOSMHandling',exportVer),...
        slexportprevious.rulefactory.removeInstanceParameter(...
        ['<SourceBlock|"',oldRef,'">'],...
        'HasStateParametersInput',exportVer),...
        slexportprevious.rulefactory.removeInstanceParameter(...
        ['<SourceBlock|"',oldRef,'">'],...
        'StateParams',exportVer),...
        slexportprevious.rulefactory.removeInstanceParameter(...
        ['<SourceBlock|"',oldRef,'">'],...
        'MaxNumEvents',exportVer),...
        };
        obj.appendRules(Rules);
    end

end
