function addCompiledBlocksToDataset(runObj,mdl)






    interface=get_param(mdl,'Object');

    subsys=find(interface,'-isa','Simulink.SubSystem');
    blks=interface.getCompiledBlockList;

    if Simulink.internal.useFindSystemVariantsMatchFilter()
        ssBlks=find_system(blks,'MatchFilter',@Simulink.match.activeVariants,'BlockType','SignalSpecification');
        findSignalSpecificationFunction=@(mdl)find_system(mdl,'MatchFilter',@Simulink.match.activeVariants,'BlockType','SignalSpecification');
    else
        ssBlks=find_system(blks,'BlockType','SignalSpecification');
        findSignalSpecificationFunction=@(mdl)find_system(mdl,'BlockType','SignalSpecification');
    end


    for idx=1:length(subsys)
        if isa(subsys(idx),'Simulink.Object')
            subsysInterface=get_param(subsys(idx).getFullName,'Object');
            subsysblks=subsysInterface.getCompiledBlockList;
            ssBlksinSubsys=findSignalSpecificationFunction(subsysblks);
            ssBlks=[ssBlks;ssBlksinSubsys];%#ok<AGROW>
        end
    end


    for i=1:length(ssBlks)
        blkObj=get_param(ssBlks(i),'Object');
        isHiddenSigSpec=blkObj.isSynthesized;

        if isHiddenSigSpec

            [newResult,~,dHandler]=runObj.getResult(blkObj,'1');
            if isempty(newResult)

                runObj.createAndUpdateResult(dHandler);
            end
        end
    end
