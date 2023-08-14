





































































classdef SimplifyModel<dynamicprops


    properties(Access='public')
        outModel;
        numBlocksDeleted;
    end


    methods(Access='public')


        function this=SimplifyModel(mdlName,conditionFunction,varargin)
            if slfeature('ModelSimplifier')==0
                return;
            end
            [this.outModel,this.numBlocksDeleted]=Simulink.SimplifyModel.startSimplification(mdlName,conditionFunction,varargin{:});
        end

    end


    methods(Access='private',Static=true)


        [reductionOK,numBlocksDeleted,sopts]=checkCondition(mdlName,conditionFunction,sopts,BlocksList,numBlocksDeleted,messageText);


        [reductionOK,blocksNumRemoved,sopts,canRewire]=deleteBlockAndCheck(blocksList,FullPath,sopts,passThroughBlock,conditionFunction,blocksNumRemoved);


        [numBlocksDeleted,sopts]=flattenHierarchy(mdlName,FullPath,sopts,conditionFunction,numBlocksDeleted);


        [allBlocks,cutLocations]=getBlocksList(FullPath,excludeBlocks,maxIterations);


        [blockPortHandles,blockHandles,isaSource]=getPortConnections(portHandle,deleteLine);


        [srcPortList,dstPortList,srcBlkList,dstBlkList]=getSrcDstList(currentBlock,deleteLines);


        [ioBlks_list,portsConnectingToSubsystem,prtList]=getSubsystemConnections(subSys);


        [first_part,last_part]=getSubsystemName(subsysName);


        [numBlocksDeleted,sopts]=removeFromGotoBlocks(FullPath,mdlName,conditionFunction,sopts,numBlocksDeleted);


        removeUnconnectedLines(FullPath);


        [topModel,totalNumBlocksDeleted]=startSimplification(mdlName,conditionFunction,varargin);


        [newModel,newTopModel,excludeBlocks]=saveSystemAndMdlRefs(mdlName,topModel,testModelExtn,extend,excludeBlocks);


        undoCreateSubsystem(subSys);


        [simplifiable,subsystemOrMdl]=canBeSimplified(blocksList,sopts);

    end
end
