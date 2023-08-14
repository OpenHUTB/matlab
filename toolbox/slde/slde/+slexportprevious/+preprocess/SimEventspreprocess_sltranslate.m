function SimEventspreprocess_sltranslate(obj)



    if isR2020aOrEarlier(obj.ver)

        obj.removeBlocksOfType('DataTable');
        obj.removeBlocksOfType('DataTableReader');
        obj.removeBlocksOfType('DataTableWriter');
    end

    if isR2019bOrEarlier(obj.ver)
        obj.removeBlocksOfType('Scenario');

        obj.removeBlocksOfType('DataTableBlock');
        obj.removeBlocksOfType('DataTableWrite');
        obj.removeBlocksOfType('DataTableRead');
    end

    if isR2018aOrEarlier(obj.ver)
        obj.removeBlocksOfType('FindEntity');
    end

    if isR2017bOrEarlier(obj.ver)
        obj.replaceWithEmptySubsystem(obj.findBlocksWithMaskType('desSelector'));
        obj.removeBlocksOfType('EntityStore');
    end

    if isR2017aOrEarlier(obj.ver)
        obj.replaceWithEmptySubsystem(obj.findBlocksWithMaskType('desConveyorSystem'));
    end

    if isR2015bOrEarlier(obj.ver)
        obj.replaceWithEmptySubsystem(obj.findBlocksWithMaskType('SimEvents Debugger (Tech Preview)'));
        charts=obj.findBlocksWithMaskType('Stateflow');
        numBlks=length(charts);
        indexToBeRemoved=[];
        for i=1:numBlks
            if(sfprivate('is_des_chart_block',charts{i}))
                indexToBeRemoved=[indexToBeRemoved,i];
            end
        end
        for i=indexToBeRemoved
            obj.replaceWithEmptySubsystem(charts{i});
        end
        obj.removeBlocksOfType('EntityGenerator');
        obj.removeBlocksOfType('EntityTerminator');
        obj.removeBlocksOfType('EntityGate');
        obj.removeBlocksOfType('EntityReplicator');
        obj.removeBlocksOfType('EntityMulticast');
        obj.removeBlocksOfType('EntityServer');
        obj.removeBlocksOfType('Queue');
        obj.removeBlocksOfType('EntityInputSwitch');
        obj.removeBlocksOfType('EntityOutputSwitch');
        obj.removeBlocksOfType('CompositeEntityCreator');
        obj.removeBlocksOfType('CompositeEntitySplitter');
        obj.removeBlocksOfType('EntityBatchCreator');
        obj.removeBlocksOfType('EntityBatchSplitter');
        obj.removeBlocksOfType('EntityResourcePool');
        obj.removeBlocksOfType('EntityResourceAcquirer');
        obj.removeBlocksOfType('EntityResourceReleaser');
        obj.removeBlocksOfType('MATLABDiscreteEventSystem');
        obj.removeBlocksOfType('MATLABDiscreteEventSystem');
        obj.removeBlocksOfType('Send');
        obj.removeBlocksOfType('Receive');
        obj.removeBlocksOfType('MessageViewer');
    end
end
