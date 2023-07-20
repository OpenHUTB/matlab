function[blocks,toRemoveBlocksAndSysH]=computeDeadBlocks(obj,mode,dfgIds,...
    inactiveVId,inactiveEId,activeC)




    import Analysis.*;

    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    ir=obj.ir;

    switch mode
    case 'back'
        [signalPaths,blocksReachable]=obj.computeDependence(mode,dfgIds,...
        inactiveVId,inactiveEId,activeC);
    otherwise
        error('ModelSlicer:DeadBlocks:UnknownMode',...
        getString(message('Sldv:ModelSlicer:ModelSlicer:UnknownDependenceModeSpecified')));
    end



    procV=MSUtils.graphVertices(ir.getDfgIDs(blocksReachable));
    unreachableProcIds=ir.dfg.allProcsBut(procV);
    blockHandles=ir.getHandles(unreachableProcIds);



    toRemove=blockHandles;


    toRemove=toRemove(arrayfun(@(x)ir.handleToTreeIdx.isKey(x),toRemove));
    toRemoveTreeIdx=arrayfun(@(x)ir.handleToTreeIdx(x),toRemove);



    toRemoveTreeNodes=ir.tree.removePartiallyContainedAncestors(...
    MSUtils.treeNodes(toRemoveTreeIdx));
    toRemoveBlocksAndSysH=arrayfun(@(x)ir.treeIdxToHandle(x.Id),toRemoveTreeNodes);


    treeNodes=ir.tree.ancestorSubset(toRemoveTreeNodes);
    blocks=arrayfun(@(x)ir.treeIdxToHandle(x.Id),treeNodes);


    transforms=obj.transforms;
    keeps=[];

    for i=1:length(transforms)
        keeps=[keeps;transforms(i).filterDeadBlocks(toRemoveBlocksAndSysH)];
    end


    blocks=setdiff(blocks,keeps);

    if~isempty(obj.virtualStarts)


















        ancestorHandleToKeep=slslicer.internal.SLCompGraphUtil.Instance.getBlockAncestors(obj.virtualStarts,obj.refMdlToMdlBlk);

        inactiveActionSubsysIndex=arrayfun(@(x)slslicer.internal.identifyInactiveSubsys(x),toRemoveBlocksAndSysH);

        inactiveActionSubsys=toRemoveBlocksAndSysH(inactiveActionSubsysIndex);
        ancestorHandleToKeep=setdiff(ancestorHandleToKeep,inactiveActionSubsys);

        toRemoveSysH=unique([toRemoveBlocksAndSysH,blocks]);



        tempToRemove=intersect(toRemoveSysH,ancestorHandleToKeep);

        childrenHandles=slslicer.internal.getNVChildrenInSubsys(tempToRemove);
        toRemoveBlocksAndSysH=[toRemoveBlocksAndSysH,childrenHandles'];
        toKeepBlocksAndSysH=[ancestorHandleToKeep,obj.virtualStarts];
        toRemoveBlocksAndSysH=setdiff(toRemoveBlocksAndSysH,toKeepBlocksAndSysH);

        blocks=[blocks,childrenHandles'];
        blocks=setdiff(blocks,toKeepBlocksAndSysH);
    end


    deadRootInports=getDeadRootInports(obj.mdlStructureInfo.rootInportHandles,signalPaths);

    if~isempty(obj.virtualStarts)


        blktokeepindex=arrayfun(@(x)...
        ismember(x,obj.mdlStructureInfo.rootInportHandles)...
        &&~ismember(x,obj.virtualStarts),obj.designInterests.blocks);
        blktokeep=obj.designInterests.blocks(blktokeepindex);
        deadRootInports=setdiff(deadRootInports,blktokeep);
    end

    deadRootInports=reshape(deadRootInports,1,[]);

    blocks=[blocks,deadRootInports];

end

function deadRootInports=getDeadRootInports(rootInportHandles,signalPaths)
    srcParentHandles=arrayfun(@(ph)get(ph,'ParentHandle'),signalPaths.src);
    deadRootInports=setdiff(rootInportHandles,srcParentHandles);

end


