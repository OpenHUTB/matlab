function[subsystemBoundaryIds,subsystemEdgeIds,unconstraintBlkMap]=getSubsystemBoundaryIds(sliceSubSystemH,ir,dir)





















    subsystemBoundaryIds=[];
    subsystemEdgeIds=[];
    unconstraintBlkMap=containers.Map('KeyType','double','ValueType','double');
    if~isKey(ir.handleToDfgIdx,sliceSubSystemH)&&...
        isKey(ir.origBlkHToSynBlkHMap,sliceSubSystemH)


        sliceSubSystemH=ir.origBlkHToSynBlkHMap(sliceSubSystemH);
    end

    sysPH=get_param(sliceSubSystemH,'PortHandles');
    ssTreeId=ir.handleToTreeIdx(sliceSubSystemH);
    treeDescendansIdinSS=ir.tree.descendants(MSUtils.treeNodes(ssTreeId));

    blksInSS=cell2mat(ir.treeIdxToHandle.values({treeDescendansIdinSS.Id}));
    blkObj=get_param(sliceSubSystemH,'Object');
    isMdlBlk=isa(blkObj,'Simulink.ModelReference');

    if any(strcmp(dir,{'back','either'}))

        if~isempty(sysPH.Enable)&&isKey(ir.dfgInportHToInputIdx,sysPH.Enable)
            subsystemBoundaryIds(end+1)=ir.dfgInportHToInputIdx(sysPH.Enable);
        end

        if~isempty(sysPH.Trigger)&&isKey(ir.dfgInportHToInputIdx,sysPH.Trigger)
            subsystemBoundaryIds(end+1)=ir.dfgInportHToInputIdx(sysPH.Trigger);
        end




        if~isa(blkObj,'Simulink.ModelReference')
            inpBlkH=find_system(sliceSubSystemH,'FindAll','on','LookUnderMasks','all',...
            'FollowLinks','on','SearchDepth',1,'BlockType','Inport');
        else
            refMdlH=get_param(get_param(sliceSubSystemH,'NormalModeModelName'),'Handle');
            inpBlkH=find_system(refMdlH,'FindAll','on','LookUnderMasks','all',...
            'FollowLinks','on','SearchDepth',1,'BlockType','Inport');
        end
        for i=1:length(inpBlkH)
            inportH=get_param(inpBlkH(i),'PortHandles');
            pObj=get(inportH.Outport(1),'Object');
            aDst=pObj.getActualDst;
            dstOk=[];
            for j=1:size(aDst,1)
                parentBlkH=get(aDst(j,1),'ParentHandle');
                if ismember(parentBlkH,blksInSS)

                    if ir.dfgInportHToInputIdx.isKey(aDst(j,1))
                        dstOk(end+1)=aDst(j,1);%#ok<AGROW>
                    end
                else




                    unconstraintBlkMap(parentBlkH)=inpBlkH(i);
                end
            end
            subsystemEdgeIds=[subsystemEdgeIds,getSrcEdgesBack(inpBlkH(i),dstOk)];%#ok<AGROW>
        end
        if~isa(blkObj,'Simulink.ModelReference')

            dsmMap=Sldv.SubsystemLogger.deriveDSWExecPriorToSubsystem(sliceSubSystemH);
            dsNames=dsmMap.keys;
            for i=1:length(dsNames)
                dsrH=dsmMap(dsNames{i});
                for j=1:length(dsrH)
                    if ir.handleToDfgIdx.isKey(dsrH(j))...
                        &&ismember(dsrH(j),blksInSS)
                        subsystemBoundaryIds(end+1)=ir.handleToDfgIdx(dsrH(j));%#ok<AGROW>
                    end
                end
            end
        else
            subsystemBoundaryIds=[subsystemBoundaryIds,...
            Transform.ModelRefUtils.getDatastoreUserBoundaries(ir,treeDescendansIdinSS,false)];
        end
    end
    if any(strcmp(dir,{'forward','either'}))




        if~isa(blkObj,'Simulink.ModelReference')
            outpBlkH=find_system(sliceSubSystemH,'FindAll','on','LookUnderMasks','all',...
            'FollowLinks','on','SearchDepth',1,'BlockType','Outport');
        else
            refMdlH=get_param(blkObj.ModelName,'Handle');
            outpBlkH=find_system(refMdlH,'FindAll','on','LookUnderMasks','all',...
            'FollowLinks','on','SearchDepth',1,'BlockType','Outport');
        end
        for i=1:length(outpBlkH)
            outportH=get_param(outpBlkH(i),'PortHandles');
            pObj=get(outportH.Inport(1),'Object');
            aSrc=pObj.getActualSrc;
            srcOk=[];
            for j=1:size(aSrc,1)
                parentBlkH=get(aSrc(j,1),'ParentHandle');
                if ismember(parentBlkH,blksInSS)

                    if ir.portHandleToDfgVarIdx.isKey(aSrc(j,1))
                        srcOk(end+1)=aSrc(j,1);%#ok<AGROW>
                    end
                else




                    unconstraintBlkMap(parentBlkH)=outpBlkH(i);
                end
            end
            subsystemEdgeIds=[subsystemEdgeIds,getDstEdgesFw(outpBlkH(i),srcOk)];%#ok<AGROW>
        end

        if~isa(blkObj,'Simulink.ModelReference')
            dsmMap=Transform.SubsystemSliceUtils.deriveDSRExecPosteriorToSubsystem(sliceSubSystemH);
            dsNames=dsmMap.keys;
            for i=1:length(dsNames)
                dswH=dsmMap(dsNames{i});
                for j=1:length(dswH)
                    if ir.handleToDfgIdx.isKey(dswH(j))
                        subsystemBoundaryIds(end+1)=ir.handleToDfgIdx(dswH(j));%#ok<AGROW>
                    end
                end
            end
        else
            subsystemBoundaryIds=[subsystemBoundaryIds,...
            Transform.ModelRefUtils.getDatastoreUserBoundaries(ir,treeDescendansIdinSS,true)];
        end
    end
    subsystemBoundaryIds=unique(subsystemBoundaryIds);
    subsystemBoundaryIds=reshape(subsystemBoundaryIds,numel(subsystemBoundaryIds),1);
    subsystemEdgeIds=reshape(subsystemEdgeIds,[],1);

    function edgeIds=getSrcEdgesBack(inBlkH,dstPs)
        edgeIds=[];
        for jdx=1:length(dstPs)
            dstP=dstPs(jdx);
            dstV=MSUtils.graphVertices(ir.dfgInportHToInputIdx(dstP));
            if~isMdlBlk
                inBlkObj=get_param(inBlkH,'Object');
                srcs=inBlkObj.getActualSrc;
                srcs=srcs(:,1);
                srcIds=arrayfun(@(p)ir.portHandleToDfgVarIdx(p),srcs);
                for idx=1:length(srcIds)
                    edge=ir.dfg.getEdge(MSUtils.graphVertices(srcIds(idx)),...
                    dstV);
                    if~isempty(edge)
                        edgeIds(end+1)=edge.eId;%#ok<AGROW>
                    end
                end
            else


                nodeV=ir.dfg.pre(dstV);
                for idx=1:length(nodeV)
                    n=nodeV(idx);
                    if isKey(ir.dfgInputIdxToInportH,n.vId)
                        ipH=ir.dfgInputIdxToInportH(n.vId);
                        if get_param(ipH,'ParentHandle')==sliceSubSystemH
                            edge=ir.dfg.getEdge(n,dstV);
                            if~isempty(edge)
                                edgeIds(end+1)=edge.eId;%#ok<AGROW>
                            end
                        end
                    end
                end
            end
        end
    end

    function edgeIds=getDstEdgesFw(outBlkH,srcPs)
        edgeIds=[];
        for jdx=1:length(srcPs)
            srcP=srcPs(jdx);
            srcV=MSUtils.graphVertices(ir.portHandleToDfgVarIdx(srcP));
            if~isMdlBlk
                outBlkObj=get_param(outBlkH,'Object');
                dsts=outBlkObj.getActualDst;
                dsts=dsts(:,1);
                dstIds=arrayfun(@(p)ir.dfgInportHToInputIdx(p),dsts);
                for idx=1:length(dstIds)
                    edge=ir.dfg.getEdge(srcV,...
                    MSUtils.graphVertices(dstIds(idx)));
                    if~isempty(edge)
                        edgeIds(end+1)=edge.eId;%#ok<AGROW>
                    end
                end
            else




                nodeV=ir.dfg.succ(srcV);
                for idx=1:length(nodeV)
                    n=nodeV(idx);
                    ipH=ir.dfgInputIdxToInportH(n.vId);
                    parentObj=get_param(get_param(ipH,'ParentHandle'),'Object');
                    if isa(parentObj,'Simulink.Outport')
                        edge=ir.dfg.getEdge(srcV,n);
                        if~isempty(edge)
                            edgeIds(end+1)=edge.eId;%#ok<AGROW>
                        end
                    end
                end
            end
        end
    end
end
