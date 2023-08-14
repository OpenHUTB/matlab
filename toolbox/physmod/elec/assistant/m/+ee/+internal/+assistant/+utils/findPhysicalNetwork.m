function physicalNetworks=findPhysicalNetwork(systemHandle)









    physicalBlocks=find_system(systemHandle,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','BlockType','SimscapeBlock');
    solverConfigurations=find_system(systemHandle,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','BlockType','SubSystem','MaskType','Solver Configuration');


    nSolver=numel(solverConfigurations);
    physicalNetworks={};
    if nSolver>0
        for idxSolver=1:nSolver


            thisSolver=solverConfigurations{idxSolver};
            blockList=ee.internal.graph.findConnectedBlocksSameLevel(thisSolver);


            physicalBlockList=ee.internal.graph.tracePhysicalBlocks(thisSolver,blockList);

            blockQueue=physicalBlockList;
            idxQueue=1;
            while idxQueue<=numel(blockQueue)
                thisBlock=blockQueue{idxQueue};
                newBlocks=ee.internal.graph.findConnectedPhysicalBlocks(thisBlock);
                for idxNewBlock=1:numel(newBlocks)
                    thisNewBlock=newBlocks{idxNewBlock};
                    if isempty(find(strcmp(blockQueue,thisNewBlock),1))
                        blockQueue{end+1}=thisNewBlock;
                    end
                end
                idxQueue=idxQueue+1;
            end
            physicalNetworks{idxSolver}.netWork=blockQueue;
            physicalNetworks{idxSolver}.solver='Connected';
            physicalNetworks{idxSolver}.solverName=thisSolver;
        end
    end


    for idx=numel(physicalNetworks):-1:1
        if isempty(physicalNetworks{idx}.netWork)
            physicalNetworks(idx)=[];
        end
    end


    nNetwork=numel(physicalNetworks);
    if nNetwork==0
        remainedPhysicalBlocks=physicalBlocks;
    elseif nNetwork>0
        remainedPhysicalBlocks=physicalBlocks;
        for idxNetwork=1:nNetwork
            blocks=physicalNetworks{idxNetwork}.netWork;
            for idxBlock=1:numel(blocks)
                thisBlock=blocks{idxBlock};
                idxFind=find(strcmp(remainedPhysicalBlocks,thisBlock),1);
                remainedPhysicalBlocks(idxFind)=[];
            end
        end
    end


    idxNetWork=nNetwork+1;
    while~isempty(remainedPhysicalBlocks)
        blockQueue=remainedPhysicalBlocks(1);
        idxQueue=1;
        while idxQueue<=numel(blockQueue)
            thisBlock=blockQueue{idxQueue};
            newBlocks=ee.internal.graph.findConnectedPhysicalBlocks(thisBlock);
            for idxNewBlock=1:numel(newBlocks)
                thisNewBlock=newBlocks{idxNewBlock};
                if isempty(find(strcmp(blockQueue,thisNewBlock),1))
                    blockQueue{end+1}=thisNewBlock;
                end
            end
            idxQueue=idxQueue+1;
        end
        physicalNetworks{idxNetWork}.netWork=blockQueue;
        physicalNetworks{idxNetWork}.solver='Unconnected';
        physicalNetworks{idxNetWork}.solverName='None';
        idxNetWork=idxNetWork+1;

        for idxBlock=1:numel(blockQueue)
            thisBlock=blockQueue{idxBlock};
            idxFind=find(strcmp(remainedPhysicalBlocks,thisBlock),1);
            remainedPhysicalBlocks(idxFind)=[];
        end
    end


    for idx=numel(physicalNetworks):-1:1
        if numel(physicalNetworks{idx}.netWork)==1
            physicalNetworks(idx)=[];
        end
    end


    for ii=1:numel(physicalNetworks)
        thisNetwork=physicalNetworks{ii}.netWork;
        hasElecRef=false;
        for jj=1:numel(thisNetwork)
            thisBlk=thisNetwork{jj};
            thisMaskType=get_param(thisBlk,'object').Masktype;
            if strcmp(thisMaskType,'Electrical Reference')
                hasElecRef=true;
                break
            end
        end
        if hasElecRef
            physicalNetworks{ii}.elecRef='Connected';
        else
            physicalNetworks{ii}.elecRef='Unconnected';
        end
    end
