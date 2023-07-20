



function highlightSet=backAnnotateToSimulink(criticalPathSet,pp)

    highlightSet=struct('path',{});

    for i=1:length(criticalPathSet)
        if(~isempty(criticalPathSet(i).cp))
            highlightPath=struct('latency',{},'owner',{},'drivers',{},'receivers',{},'notes',{});
            for j=1:length(criticalPathSet(i).cp)
                curS=qoroptimizations.retrieveSignal(j,criticalPathSet(i).cp,pp);
                highlightNode.latency=criticalPathSet(i).cp(j).latency;
                highlightNode.owner=getOwner(curS.signal);
                if(isempty(highlightNode.owner.exactPath))
                    pirDrivers=[];
                else
                    pirDrivers=curS.signal.getDrivers();
                end
                highlightNode.drivers=getDriverReceiver(pirDrivers);
                if(isempty(highlightNode.owner.exactPath))
                    pirReceivers=[];
                else
                    pirReceivers=curS.signal.getReceivers();
                end
                highlightNode.receivers=getDriverReceiver(pirReceivers);
                [~,highlightNode.notes]=qoroptimizations.isValidInsertionPoint(curS);

                highlightPath(end+1)=highlightNode;
            end
        end
        highlightSet(end+1).path=highlightPath;
    end
end

function owner=getOwner(pirSignal)

    if(isempty(pirSignal))
        owner.exactPath='';
        owner.closestLocatableAncesterPath='';
    else
        sh=pirSignal.Owner.SimulinkHandle;
        if(sh>0)
            owner.exactPath=validateBlockHandle(sh);
            owner.closestLocatableAncesterPath='';
        else
            owner.exactPath='';
            ash=pirSignal.Owner.getClosestAncesterInstanceSimulinkHandle();
            owner.closestLocatableAncesterPath=validateBlockHandle(ash);
        end
    end
end

function drBlocks=getDriverReceiver(pirDriverReceivers)

    drBlocks=struct('portIdx',{},'original',{});
    for k=1:length(pirDriverReceivers)
        dr=pirDriverReceivers(k);
        drBlock.portIdx=dr.PortIndex;
        if(dr.Owner.SimulinkHandle==-1)
            continue;
        end
        blkPath=validateBlockHandle(dr.Owner.SimulinkHandle);
        if(isempty(blkPath))
            continue;
        end
        drBlock.original=blkPath;
        drBlock=consolidateForPort(drBlock,dr,blkPath);
        drBlocks(end+1)=drBlock;
    end
end

function blkPath=validateBlockHandle(handle)



    parentPath=get_param(handle,'parent');
    if(isempty(parentPath))
        blkPath=get_param(handle,'name');
    else
        blkPath=[get_param(handle,'parent'),'/',get_param(handle,'name')];
    end


    blk=find_system(blkPath,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
    candidateIdx=find(strcmp(blk,blkPath));
    if(length(candidateIdx)~=1)
        blkPath='';
    end
end

function drBlock=consolidateForPort(drBlock,cand,blkPath)



    if(strcmp(cand.Owner.ClassName,'network'))
        portPath=[blkPath,'/',cand.name];
        portBlk=find_system(portPath);
        try


            portBlk=find_system(portPath,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
        catch me
            if(strcmpi(me.identifier,'Simulink:Commands:FindSystemInvalidPVPair')||...
                strcmpi(me.identifier,'Simulink:Commands:FindSystemNoBlock'))
                portBlk='';
            else
                rethrow(me);
            end
        end


        portBlk=find_system(portPath,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
        candidateIdx=find(strcmp(portBlk,portPath));
        if(length(candidateIdx)~=1)
            drBlock.portIdx=-drBlock.portIdx;
        else
            drBlock.portIdx=0;
            drBlock.original=portPath;
        end
    end
end


