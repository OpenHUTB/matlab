function mappingType=checkMappingOfNodes(refMdl,topMdl)













    import Simulink.DistributedTarget.internal.NodeMappingType

    refMdl=convertStringsToChars(refMdl);
    topMdl=convertStringsToChars(topMdl);


    mappingType=NodeMappingType.AllSoftware;

    if~isempty(topMdl)&&~contains(topMdl,':')

        if~bdIsLoaded(topMdl)
            return;
        end

        if strcmp(get_param(topMdl,'EnableConcurrentExecution'),'off')||...
            strcmp(get_param(topMdl,'ExplicitPartitioning'),'off')||...
            (strcmp(get_param(topMdl,'EnableConcurrentExecution'),'on')&&...
            strcmp(get_param(topMdl,'ConcurrentTasks'),'off'))
            return;
        end

        mgr=get_param(topMdl,'MappingManager');
        if isempty(mgr)
            return;
        end

        mapping=mgr.getActiveMappingFor('DistributedTarget');
        if isempty(mapping)
            return;
        end

        blockToNodes=mapping.BlockToNodesMap;




        [~,allBlks]=find_mdlrefs(topMdl,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'AllLevels',false);

        foundSW=false;
        foundHW=false;
        for idx=1:length(allBlks)
            blk=allBlks(idx);

            if strcmp(get_param(blk,'ModelNameInternal'),refMdl)

                found=false;
                for j=1:length(blockToNodes)
                    if strcmp(blockToNodes(j).Block,blk)
                        found=true;
                        if~isa(blockToNodes(j).MappingEntities(1),...
                            'Simulink.DistributedTarget.HardwareNode')&&...
                            blockToNodes(j).MappingEntities(1).requiresRTWBuild
                            foundSW=true;
                        else
                            foundHW=true;
                        end
                    end
                end


                if~found
                    foundSW=true;
                end


                if foundSW&&foundHW
                    break;
                end
            end
        end


        if foundSW&&foundHW
            mappingType=NodeMappingType.MixedHardwareSoftware;
        elseif foundSW
            mappingType=NodeMappingType.AllSoftware;
        elseif foundHW
            mappingType=NodeMappingType.AllHardware;
        end
    end
end
