function[dfgIds,invalidBlk,invalidSig]=getDesignInterestsDfgIds(obj)




    import slslicer.internal.*
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

    dI=obj.designInterests;
    ir=obj.ir;

    blkIds=[];
    invalidBlk=[];
    for i=1:length(dI.blocks)
        bId=getDfgIds(dI.blocks(i));
        if~isempty(bId)
            blkIds=[blkIds;bId];%#ok<AGROW>
        else

            invalidBlk=[invalidBlk;dI.blocks(i)];%#ok<AGROW>
        end
    end
    blkIds=unique(blkIds);

    sigIds=[];
    invalidSig=[];
    for i=1:length(dI.signals)
        sId=obj.getSigDfgIds(dI.signals(i));
        if~isempty(sId)
            sigIds=[sigIds;sId];%#ok<AGROW>
        else

            invalidSig=[invalidSig;dI.signals(i)];%#ok<AGROW>
        end
    end
    sigIds=unique(sigIds);

    dfgIds=[blkIds;sigIds];


    function blkIds=getDfgIds(bh)
        blkIds=[];
        if~obj.isBlockValidTarget(bh)
            return;
        end
        bt=get(bh,'BlockType');
        if strcmp(bt,'SubSystem')&&strcmp(...
            get(bh,'TreatAsAtomicUnit'),'on')

            blkIds=getDescendantDfgIds(bh);
        elseif strcmp(bt,'ModelReference')&&strcmp(...
            get(bh,'SimulationMode'),'Normal')
            bObj=get(bh,'Object');
            if~isempty(bObj.PortHandles.Trigger)...
                &&strcmp(get(bObj.PortHandles.Trigger,'CompiledPortDataType'),'fcn_call')



                blockPath=getfullname(bh);
                values=obj.refMdlToMdlBlk.values;
                for j=1:length(values)
                    if strcmp(blockPath,getfullname(values{j}))
                        blkIds=getDescendantDfgIds(values{j});
                    end
                end
            else
                blkIds=getDescendantDfgIds(bh);
            end
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
            for j=1:length(desNodes)
                if isKey(ir.treeIdxToHandle,desNodes(j).Id)
                    desHdl=ir.treeIdxToHandle(desNodes(j).Id);
                    dfgId=[dfgId;ir.handleToDfgIdx(desHdl)];%#ok<AGROW>
                end
            end
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
