function dfgId=getDfgIdForBlock(this,blockH)





    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    ir=this.ir;
    dfgId=getDfgIds(blockH);


    function blkIds=getDfgIds(bh)
        bt=get(bh,'BlockType');
        if strcmp(bt,'SubSystem')&&strcmp(...
            get(bh,'TreatAsAtomicUnit'),'on')

            blkIds=getDescendantDfgIds(bh);
        elseif strcmp(bt,'ModelReference')&&strcmp(...
            get(bh,'SimulationMode'),'Normal')
            blkIds=getDescendantDfgIds(bh);
        elseif strcmp(bt,'SubSystem')&&strcmp(...
            get(bh,'TreatAsAtomicUnit'),'off')
            blkIds=getNVChildrenDfgIds(bh);
        elseif strcmp(bt,'DataStoreMemory')
            blkIds=ir.dsmToDfgVarIdx(bh);
        else

            if ir.handleToDfgIdx.isKey(bh)
                blkIds=ir.handleToDfgIdx(bh);
            else
                blkIds=[];
            end
        end
    end

    function dfgId=getDescendantDfgIds(bh)
        dfgId=[];
        if isKey(ir.handleToTreeIdx,bh)
            sysId=ir.handleToTreeIdx(bh);
            desNodes=ir.tree.descendantsFor(MSUtils.treeNodes(sysId));
            desHdl=arrayfun(@(x)ir.treeIdxToHandle(x.Id),desNodes);
            dfgId=arrayfun(@(x)ir.handleToDfgIdx(x),desHdl);
            dfgId=reshape(dfgId,numel(dfgId),1);
        end
    end

    function dfgId=getNVChildrenDfgIds(sysh)

        sysO=get(sysh,'Object');
        children=sysO.getCompiledBlockList;
        dfgId=[];
        for j=1:length(children)
            dfgId=[dfgId;getDfgIds(children(j))];%#ok<AGROW>
        end
    end

end

