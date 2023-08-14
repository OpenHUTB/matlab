function[inactiveV,inactiveE,activeCtx,inactiveHandles]=identifyInactiveElements(obj,groups)




    import Analysis.*;

    ir=obj.ir;
    mdl=obj.model;


    analysisData=obj.getAnalysisData();
    assert(~isempty(analysisData));

    getAllTransforms(obj);

    transforms=obj.transforms;
    for i=1:length(transforms)
        transforms(i).reset;
    end

    inactiveHdls=[];
    inactiveInH=[];
    context=[];

    allHdls=getAllBlocks(ir.tree,ir.treeIdxToHandle);
    allContexts=obj.getNonRootContexts;


    forEachSSH=[];
    for i=1:length(allContexts)
        ssType=Simulink.SubsystemType(allContexts(i));
        if ssType.isForEachSubsystem
            forEachSSH(end+1)=allContexts(i);%#ok<AGROW>
        end
    end
    noForEach=isempty(forEachSSH);

    blkTypeMap=containers.Map('KeyType','char','ValueType','any');


    for i=1:length(allHdls)
        bt=get(allHdls(i),'BlockType');
        if blkTypeMap.isKey(bt)
            blkTypeMap(bt)=[blkTypeMap(bt);allHdls(i)];
        else
            blkTypeMap(bt)=allHdls(i);
        end
    end


    for i=1:length(transforms)

        if blkTypeMap.isKey(transforms(i).pivotBlockType)
            hdls=blkTypeMap(transforms(i).pivotBlockType);
            for j=1:length(hdls)
                bh=hdls(j);



                if~ismember(bh,obj.designInterests.blocks)...
                    &&~groups.toParent.isKey(bh)
                    if transforms(i).applicable(bh,analysisData)
                        try
                            if noForEach||~hasForEach(bh,forEachSSH)
                                if isa(analysisData,'Sldv.DeadLogicData')
                                    if~analysisData.hasAnalysisData(bh)
                                        context=makeContextAllActive(bh,context,allContexts,ir);
                                        continue;
                                    end
                                end
                                [v,vIn,c]=transforms(i).analyze(bh,mdl,analysisData,...
                                obj.mdlStructureInfo);

                                if~isempty(v)
                                    assert(size(v,2)==1);
                                    inactiveHdls=[inactiveHdls;v];%#ok<AGROW>
                                end
                                if~isempty(vIn)
                                    assert(size(vIn,2)==1);
                                    inactiveInH=[inactiveInH;vIn];%#ok<AGROW>
                                end
                                if~isempty(c)
                                    assert(size(c,2)==1);
                                    ctxH=getNonleafDescendants(c,ir);
                                    context=[context;c;ctxH];%#ok<AGROW>
                                end
                            else

                                context=makeContextAllActive(bh,context,allContexts,ir);
                            end
                        catch Mex %#ok<NASGU>


                            context=makeContextAllActive(bh,context,allContexts,ir);
                        end
                    end
                elseif ismember(bh,allContexts)



                    context=makeContextAllActive(bh,context,allContexts,ir);
                end
            end
        end
    end


    if obj.inSteppingMode&&obj.showCtrlDep
        inactiveInH=removeCtrlPorts(inactiveInH);
        context=allContexts;
    end
    context=unique(context);
    if~isempty(context)
        ctxIds=arrayfun(@(x)ir.handleToTreeIdx(x),context);
        activeCtxIds=[];
        for n=1:length(ctxIds)
            activeCtxNodes=ir.tree.ancestors(MSUtils.treeNodes(ctxIds(n)));
            activeCtxIds=[activeCtxIds,[activeCtxNodes.Id]];%#ok<AGROW>
        end
        activeCtxIds=reshape(activeCtxIds,numel(activeCtxIds),1);
        activeCtxIds=unique([activeCtxIds;ctxIds]);
        activeCtx=arrayfun(@(x)ir.treeIdxToHandle(x),activeCtxIds);
    else
        activeCtx=[];
    end



    inactiveTreeIndices=arrayfun(@(x)(ir.handleToTreeIdx(x)),inactiveHdls);
    inactiveTreeNodes=ir.tree.descendantsFor(MSUtils.treeNodes(inactiveTreeIndices));
    inactiveHandles=zeros(numel(inactiveTreeNodes),1);
    for i=1:length(inactiveTreeNodes)
        inactiveHandles(i)=ir.treeIdxToHandle(inactiveTreeNodes(i).Id);
    end
    inactiveProc=getDfgIDs(inactiveHandles,ir.handleToDfgIdx);

    inactiveVIn=getDfgIDs(inactiveInH,ir.dfgInportHToInputIdx);

    inactiveV=[inactiveProc;inactiveVIn];
    inactiveE=[];
end

function context=makeContextAllActive(bh,context,allContexts,ir)
    switch get_param(bh,'BlockType')
    case{'If','SwitchCase'}


        ph=get_param(bh,'PortHandles');
        for n=1:length(ph.Outport)
            pObj=get(ph.Outport(n),'Object');
            aDstS=pObj.getActualDst;
            ctxH=[];
            for j=1:size(aDstS,1)
                ctxH=getNonleafDescendants(get(aDstS(1),'ParentHandle'),ir);
            end
            context=[context;bh;ctxH];%#ok<AGROW>
        end
    otherwise
        if ismember(bh,allContexts)
            ctxH=getNonleafDescendants(bh,ir);
            context=[context;bh;ctxH];
        end
    end
end

function yesno=hasForEach(bh,forEachSSH)
    yesno=false;
    if any(strcmp(get_param(bh,'BlockType'),{'If','SwitchCase'}))
        bObj=get(bh,'Object');
        aDst=bObj.getActualDst;
        for i=1:size(aDst,1)
            bh(i)=get(aDst(i,1),'ParentHandle');
        end
    end
    for i=1:length(bh)


        sysH=find_system(bh,'FindAll','on','LookUnderMasks','all','FollowLinks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'BlockType','SubSystem');
        if~isempty(ismember(sysH,forEachSSH))
            yesno=true;
            break;
        end
    end
end

function dfgIDs=getDfgIDs(handles,dfgMap)








    dfgIDs=zeros(numel(handles),1);
    for i=1:numel(handles)
        dfgIDs(i)=dfgMap(handles(i));
    end
end

function ctxH=getNonleafDescendants(bh,ir)

    ctxH=[];
    for n=1:length(bh)
        if ir.handleToTreeIdx.isKey(bh(n))
            tId=ir.handleToTreeIdx(bh(n));
            ctxTId=ir.tree.nonleafDescendants(MSUtils.treeNodes(tId));
            thisCtxH=arrayfun(@(x)ir.treeIdxToHandle(x),[ctxTId.Id]);
            ctxH=[ctxH;reshape(thisCtxH,numel(thisCtxH),1)];%#ok<AGROW>
        end
    end
end

function inH=removeCtrlPorts(inH)
    idx=arrayfun(@(p)~isCtrlPort(p),inH);
    inH=inH(idx);
end

function yesno=isCtrlPort(ph)
    yesno=false;
    portType=get_param(ph,'PortType');
    if any(strcmpi(portType,{'enable','trigger'}))
        yesno=true;
        return;
    elseif~strcmpi(portType,'inport')
        return;
    end
    po=get_param(ph,'Object');
    idx=po.PortNumber;
    blkh=get_param(ph,'ParentHandle');
    bo=get_param(blkh,'object');
    if(strcmp(bo.BlockType,'MultiPortSwitch')&&idx==1)||...
        (strcmp(bo.BlockType,'Switch')&&idx==2)||...
        (strcmp(bo.BlockType,'Interpolation_n-D')&&idx==1)
        yesno=true;
        return
    end
end
