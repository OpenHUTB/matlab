function TrackerTOMHT(obj)



    exportVer=obj.ver;

    if isR2020bOrEarlier(obj.ver)


        newRef='motalgorithmslib/Track-Oriented Multi-Hypothesis Tracker';
        oldRef='fusionlib/Track-Oriented Multi-Hypothesis Tracker';
        obj.appendRule(['<Block<SourceBlock|"',newRef,'":repval "',oldRef,'">>']);

        Rules={...
        slexportprevious.rulefactory.removeInstanceParameter(...
        ['<SourceBlock|"',oldRef,'">'],...
        'HasStateParametersInput',exportVer)...
        ,slexportprevious.rulefactory.removeInstanceParameter(...
        ['<SourceBlock|"',oldRef,'">'],...
        'OOSMHandling',exportVer)...
        };

        obj.appendRules(Rules);
    end

end
