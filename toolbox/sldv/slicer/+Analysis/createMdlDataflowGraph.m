function[g,maps,modelElements]=createMdlDataflowGraph(mdl,handles,...
    refMdlToMdlBlk,observerSinks,synthBlkHMap)












    import Analysis.*;



    [inputIdToInportH,inportHToInputId]=...
    createTwoWayMap('double','double');

    localDsmToIdx=containers.Map('KeyType','double',...
    'ValueType','double');
    globalDsmNameToDfgIdx=containers.Map('KeyType','char',...
    'ValueType','double');
    dfgIdxToGlobalDsmName=containers.Map('KeyType','double',...
    'ValueType','char');












    outputPortToInputPortEdges=containers.Map('KeyType','int32',...
    'ValueType','any');














    dataDependenceBetweenInputAndVar=containers.Map('KeyType','int32',...
    'ValueType','any');


    nSignalObserver=int32(0);
    signalObserversHandles=zeros(1,1000);

    utils=SystemsEngineering.Methods;

    inportBHs=[];
    mdlH=get_param(mdl,'Handle');





    nNodes=int32(0);
    nodeTypes=zeros(1000,1,'int32');
    nEdges=int32(0);
    edges=zeros(1000,2,'int32');
    edgeIdx=zeros(1000,1,'int32');

    blockHandles=zeros(1000,1);
    procId=zeros(1000,1,'int32');
    nProcs=int32(0);

    outportHandles=zeros(1000,1);
    varId=zeros(1000,1,'int32');
    nVars=int32(0);

    inputPortHandles=zeros(1000,1);
    inputId=zeros(1000,1,'int32');
    nInputs=int32(0);

    for i=1:length(handles)
        handle=handles(i);
        obj=get(handle,'Object');

        if strcmp(obj.type,'block')&&...
            ~isempty(obj.RuntimeObject)

            ph=obj.PortHandles;
            bt=obj.BlockType;
            if strcmpi(bt,'SubSystem')


                addProcForBlock(handle);

                addControlInputs(ph);
            elseif(strcmpi(bt,'ModelReference')&&...
                strcmpi(get(handle,'SimulationMode'),'Normal'))



                addVarForOutport(ph);


                addProcForBlock(handle);


                addDataInputs(ph);
                addControlInputs(ph);
            elseif strcmpi(bt,'Inport')

                [varStart,varEnd]=addVarForOutport(ph);

                addProcForBlock(handle);
                blkProcId=nNodes;

                addEdgesForBlockOutput(blkProcId,varStart:varEnd);
                parent=get_param(get(handle,'Parent'),'Handle');


                if~isKey(refMdlToMdlBlk,parent)

                    ph=get(parent,'PortHandles');
                    idx=str2double(get(handle,'Port'));
                    inportHandle=ph.Inport(idx);
                    addInput(inportHandle);
                end

            else

                [varStart,varEnd]=addVarForOutport(ph);



                if strcmpi(bt,'DataStoreMemory')
                    isGlobal=strcmp(get(handle,'GlobalDataStore'),'on');
                    addVarForDSM(handle,isGlobal);
                end

                addProcForBlock(handle);
                blkProcId=nNodes;

                addEdgesForBlockOutput(blkProcId,varStart:varEnd);

                [stVarStart,stVarEnd]=addVarForStatePort(ph);
                addEdgesForBlockState(blkProcId,stVarStart:stVarEnd);


                [inStart,inEnd]=addDataInputs(ph);
                addEdgesForBlockInput(blkProcId,obj.RuntimeObject,inStart:inEnd,...
                ph);
                addControlInputs(ph);
                if find(strcmp(observerSinks.BlockType,bt))
                    nSignalObserver=nSignalObserver+1;
                    signalObserversHandles(nSignalObserver)=handle;
                end
            end
        elseif isa(obj,'Simulink.Inport')
            parentObj=obj.getParent;
            if isa(parentObj,'Simulink.BlockDiagram')...
                &&isequal(obj.getParent.Handle,mdlH)

                inportBHs(end+1)=handle;%#ok<AGROW>
                ph=obj.PortHandles;
                [varStart,varEnd]=addVarForOutport(ph);

                addProcForBlock(handle);

                addEdgesForBlockOutput(nNodes,varStart:varEnd);
            end
        elseif strcmp(obj.type,'block')&&isempty(obj.RuntimeObject)



            addProcForBlock(handle);
        end
    end


    if(nVars<1)||(nInputs<1)
        error('ModelSlicer:EmptyModel',getString(message('Sldv:ModelSlicer:Analysis:ModelIsNearlyEmpty')));
    end


    varId=varId(1:nVars);
    outportHandles=outportHandles(1:nVars);
    portHandleToOid=containers.Map(outportHandles,varId);
    oidToPortHandle=containers.Map(varId,outportHandles);

    inputId=inputId(1:nInputs);
    inputPortHandles=inputPortHandles(1:nInputs);
    inputIdToInportH=containers.Map(inputId,inputPortHandles);
    inportHToInputId=containers.Map(inputPortHandles,inputId);

    procId=procId(1:nProcs);
    blockHandles=blockHandles(1:nProcs);
    blockHandleToProcid=containers.Map(blockHandles,procId);
    procidToBlockHandle=containers.Map(procId,blockHandles);



    observerSubsys=[];
    for d=1:length(observerSinks.Subsystem)


        subsys=find_system(mdl,'FindAll','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all','FollowLinks','on',...
        'ReferenceBlock',sprintf(observerSinks.Subsystem{d}));
        if(~isempty(subsys))
            observerSubsys=cat(2,observerSubsys,subsys');
        end
    end

    for d=1:length(observerSinks.Masktype)


        subsys=find_system(mdl,'FindAll','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all','FollowLinks','on',...
        'MaskType',sprintf(observerSinks.Masktype{d}));
        if(~isempty(subsys))
            observerSubsys=cat(2,observerSubsys,subsys');
        end
    end

    for o=1:length(observerSubsys)
        nSignalObserver=nSignalObserver+1;
        signalObserversHandles(nSignalObserver)=observerSubsys(o);


        children=find_system(observerSubsys(o),'FindAll','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all','FollowLinks','on','type','block');
        children(children==observerSubsys(o))=[];
        nChildren=numel(children);
        signalObserversHandles((nSignalObserver+1):...
        (nSignalObserver+nChildren))=children;
        nSignalObserver=nSignalObserver+nChildren;
    end







    synthBlks=synthBlkHMap.values;
    synthBlks=[synthBlks{:}];
    for i=1:length(synthBlks)
        toAdd=false;
        synthBlkPath=getfullname(synthBlks(i));
        blkLength=length(synthBlkPath);
        for o=1:length(observerSubsys)
            obsSysPath=getfullname(observerSubsys(o));
            sysLength=length(obsSysPath);
            if(sysLength>=blkLength)
                continue;
            end

            if strcmp(obsSysPath,synthBlkPath(1:sysLength));
                toAdd=true;
                break;
            end
        end
        if toAdd
            nSignalObserver=nSignalObserver+1;
            signalObserversHandles(nSignalObserver)=synthBlks(i);
        end
    end

    signalObserversHandles=signalObserversHandles(1:nSignalObserver);
    signalObserversHandles=intersect(signalObserversHandles,blockHandles);
    signalObservers=values(blockHandleToProcid,num2cell(signalObserversHandles));
    signalObservers=cell2mat(signalObservers);


    for i=1:nProcs
        bh=blockHandles(i);
        bO=get(bh,'Object');
        ph=bO.PortHandles;
        bt=bO.BlockType;
        if strcmpi(bt,'SubSystem')


            addEnableOrTriggerPorts(ph.Enable,procId(i));
            addEnableOrTriggerPorts(ph.Trigger,procId(i));
            addEnableOrTriggerPorts(ph.Ifaction,procId(i));
        elseif strcmpi(bt,'ModelReference')
            ph=get(bh,'PortHandles');
            if strcmpi(get(bh,'SimulationMode'),'Normal')
                addEnableOrTriggerPorts(ph.Enable,procId(i));
                addEnableOrTriggerPorts(ph.Trigger,procId(i));
                addEnableOrTriggerPorts(ph.Ifaction,procId(i));

                refMdl=get(bh,'NormalModeModelName');
                addInputDFGEdges(ph);






                for ii=1:length(ph.Outport)
                    bh=findOutportBlockInReferencedModel(refMdl,ii);
                    assert(isKey(blockHandleToProcid,bh));
                    outportProc=blockHandleToProcid(bh);
                    varId=portHandleToOid(ph.Outport(ii));

                    nEdges=nEdges+1;
                    if nEdges>length(edgeIdx)
                        edgeIdx=[edgeIdx;zeros(size(edgeIdx))];%#ok<AGROW>
                        edges=[edges;zeros(size(edges))];%#ok<AGROW>
                    end
                    edges(nEdges,:)=[outportProc,varId];
                    edgeIdx(nEdges)=-1;
                end

                virtBusInportInfo=bO.VirtualBusInportInformation;
                nPort=0;
                for ii=1:length(ph.Inport)
                    if isempty(virtBusInportInfo{ii}.busName)






                        nPort=nPort+1;
                        bh=findInportBlock(refMdl,nPort);

                        if isempty(bh)



                            ip=ph.Inport(ii);
                            addEnableOrTriggerPorts(ip,procId(i));
                            continue;
                        end
                        if~isKey(blockHandleToProcid,bh)


                            inportPH=get(bh,'PortHandles');
                            outObject=get(inportPH.Outport,'Object');
                            actDst=outObject.getActualDst;

                            portH=ph.Inport(ii);
                            srcId=inportHToInputId(portH);
                            for k=1:size(actDst,1)
                                dstPH=actDst(k,1);

                                dstInputId=inportHToInputId(dstPH);

                                addDFGEdge(srcId,dstInputId,-1);

                                inputOff=actDst(k,2);
                                widthOfEdge=actDst(k,3);

                                if size(actDst,1)==1
                                    varOff=0;
                                else
                                    varOff=-1;
                                end

                                outputPortToInputPortEdges(nEdges)={varOff,...
                                inputOff,widthOfEdge};
                            end
                        end
                    else




                        srcId=inportHToInputId(ph.Inport(ii));


                        if~isempty(virtBusInportInfo{ii})
                            nPort=virtBusInportInfo{ii}.originalPort;
                        else
                            nPort=nPort+1;
                        end

                        refInBlkH=findInportBlock(refMdl,nPort);
                        if~isKey(blockHandleToProcid,refInBlkH)
                            ppH=get_param(refInBlkH,'PortHandles');
                            ppObj=get(ppH.Outport,'Object');

                            aDst=ppObj.getActualDst;
                            nDest=size(aDst,1);
                            for nn=1:nDest
                                dstPortH=[];
                                dstPObj=get(aDst(nn,1),'Object');
                                actSrcPH=dstPObj.getActualSrc;
                                for idx=1:size(actSrcPH,1)
                                    synthInportH=get(actSrcPH(idx,1),'ParentHandle');
                                    if strcmp(get(synthInportH,'BlockType'),'Inport')
                                        if strcmp(get(synthInportH,'Port'),num2str(ii))
                                            dstPortH=aDst(nn,1);
                                            break;
                                        end
                                    end
                                end
                                if isKey(inportHToInputId,dstPortH)
                                    oDst=inportHToInputId(dstPortH);
                                    addDFGEdge(srcId,oDst,-1);

                                    inputOff=aDst(nn,2);
                                    widthOfEdge=aDst(nn,3);

                                    if size(aDst,1)==1
                                        varOff=0;
                                    else
                                        varOff=-1;
                                    end

                                    outputPortToInputPortEdges(nEdges)={varOff,...
                                    inputOff,widthOfEdge};
                                end
                            end
                        end
                    end
                end
            else
                addEnableOrTriggerPorts(ph.Enable,procId(i));
                addEnableOrTriggerPorts(ph.Trigger,procId(i));
                addEnableOrTriggerPorts(ph.Ifaction,procId(i));
                addInputDFGEdges(ph);
            end

        elseif strcmp(bt,'Inport')&&~ismember(bh,inportBHs)

            parent=get_param(bO.Parent,'Handle');
            if isKey(refMdlToMdlBlk,parent)
                parentBlk=refMdlToMdlBlk(parent);
            else
                parentBlk=parent;
            end
            pH=get(parentBlk,'PortHandles');
            portIdx=str2double(bO.Port);
            inport=pH.Inport(portIdx);
            inputId=addInputAndEdgesForNVInport(inport,procId(i),parent,bO);
        elseif strcmp(bt,'TriggerPort')



            parent=get_param(bO.Parent,'Handle');
            parentO=get_param(parent,'Object');
            if isa(parentO,'Simulink.BlockDiagram')
                if isKey(refMdlToMdlBlk,parent)
                    parentBlk=refMdlToMdlBlk(parent);
                else
                    parentBlk=[];
                end
            else
                parentBlk=parent;
            end
            if~isempty(parentBlk)
                pH=get(parentBlk,'PortHandles');
                inportH=pH.Trigger;
                inputId=inportHToInputId(inportH);
                addDFGEdge(inputId,procId(i),1);
            end
        elseif strcmp(bt,'EnablePort')




            parent=get_param(bO.Parent,'Handle');
            parentO=get_param(parent,'Object');
            if isa(parentO,'Simulink.BlockDiagram')
                if isKey(refMdlToMdlBlk,parent)
                    parentBlk=refMdlToMdlBlk(parent);
                else
                    parentBlk=[];
                end
            else
                parentBlk=parent;
            end
            if~isempty(parentBlk)
                pH=get(parentBlk,'PortHandles');
                inportH=pH.Enable;
                inputId=inportHToInputId(inportH);
                addDFGEdge(inputId,procId(i),1);
            end
        elseif strcmpi(bt,'DataStoreRead')
            dsmH=utils.getDSMBlock(bh);
            if localDsmToIdx.isKey(dsmH)
                dsmVarId=localDsmToIdx(dsmH);
            else
                dsmName=get(bh,'DataStoreName');
                dsmVarId=globalDsmNameToDfgIdx(dsmName);
            end
            nEdges=nEdges+1;
            if nEdges>length(edgeIdx)
                edgeIdx=[edgeIdx;zeros(size(edgeIdx))];%#ok<AGROW>
                edges=[edges;zeros(size(edges))];%#ok<AGROW>
            end
            edges(nEdges,:)=[dsmVarId,procId(i)];
            edgeIdx(nEdges)=-2;
        elseif strcmp(bt,'S-Function')



            dsmHs=utils.getSFcnDSMBlocks(bh);
            for dsmIdx=1:length(dsmHs)
                dsmH=dsmHs(dsmIdx);
                if localDsmToIdx.isKey(dsmH)
                    dsmVarId=localDsmToIdx(dsmH);
                else
                    dsmName=get(dsmH,'DataStoreName');
                    dsmVarId=globalDsmNameToDfgIdx(dsmName);
                end
                nEdges=nEdges+1;
                if nEdges>length(edgeIdx)
                    edgeIdx=[edgeIdx;zeros(size(edgeIdx))];%#ok<AGROW>
                    edges=[edges;zeros(size(edges))];%#ok<AGROW>
                end
                edges(nEdges,:)=[dsmVarId,procId(i)];
                edgeIdx(nEdges)=-2;
                nEdges=nEdges+1;
                if nEdges>length(edgeIdx)
                    edgeIdx=[edgeIdx;zeros(size(edgeIdx))];%#ok<AGROW>
                    edges=[edges;zeros(size(edges))];%#ok<AGROW>
                end
                edges(nEdges,:)=[procId(i),dsmVarId];
                edgeIdx(nEdges)=0;
            end
            addInputDFGEdges(ph);
        else

            if strcmpi(bt,'DataStoreWrite')
                dsmH=utils.getDSMBlock(bh);
                if localDsmToIdx.isKey(dsmH)
                    dsmVarId=localDsmToIdx(dsmH);
                else
                    dsmName=get(bh,'DataStoreName');
                    dsmVarId=globalDsmNameToDfgIdx(dsmName);
                end

                nEdges=nEdges+1;
                if nEdges>length(edgeIdx)
                    edgeIdx=[edgeIdx;zeros(size(edgeIdx))];%#ok<AGROW>
                    edges=[edges;zeros(size(edges))];%#ok<AGROW>
                end
                edges(nEdges,:)=[procId(i),dsmVarId];
                edgeIdx(nEdges)=0;
            end

            addInputDFGEdges(ph);
        end
    end


    import SystemsEngineering.*;
    g=SLGraph;
    g.newVertices(nodeTypes(1:nNodes));
    g.addEdges(edges(1:nEdges,1),edges(1:nEdges,2),edgeIdx(1:nEdges));

    maps=struct('portHandleToOid',portHandleToOid,...
    'oidToPortHandle',oidToPortHandle,...
    'blockHandleToProcid',blockHandleToProcid,...
    'procidToBlockHandle',procidToBlockHandle,...
    'inputIdToInportH',inputIdToInportH,...
    'inportHToInputId',inportHToInputId,...
    'localDsmToIdx',localDsmToIdx,...
    'globalDsmNameToDfgIdx',globalDsmNameToDfgIdx,...
    'dfgIdxToGlobalDsmName',dfgIdxToGlobalDsmName,...
    'outputPortToInputPortEdges',outputPortToInputPortEdges,...
    'dataDependenceBetweenInputAndVar',dataDependenceBetweenInputAndVar);

    modelElements=struct('rootInportHandles',inportBHs,...
    'signalObservers',signalObservers');



    function addInputDFGEdges(ph)
        for kk=1:length(ph.Inport)
            port=get(ph.Inport(kk),'Object');
            if~isKey(inportHToInputId,port.handle)
                return;
            end
            inputId=inportHToInputId(port.handle);
            actSrcs=port.getActualSrc;

            widthCounter=0;
            for jj=1:size(actSrcs,1)
                srcPH=actSrcs(jj,1);
                width=actSrcs(jj,3);
                if portHandleToOid.isKey(srcPH)
                    srcId=portHandleToOid(srcPH);
                    addDFGEdge(srcId,inputId,jj);

                    busWidth=actSrcs(jj,4);

                    if(busWidth==-1)
                        varOffset=actSrcs(jj,2);
                    else
                        varOffset=-1;
                    end

                    if size(actSrcs,1)==1
                        InputOffset=0;
                    else
                        InputOffset=widthCounter;
                    end



                    pObj=get(port.ParentHandle,'Object');
                    if strcmp(pObj.Type,'block')&&...
                        strcmp(pObj.BlockType,'ForEachSliceAssignment')
                        varOffset=-1;
                        InputOffset=-1;
                    end

                    outputPortToInputPortEdges(nEdges)={varOffset,...
                    InputOffset,width};
                end
                widthCounter=widthCounter+width;
            end
        end
    end

    function addDFGEdge(srcV,inputId,j)


        nEdges=nEdges+1;
        if nEdges>length(edgeIdx)
            edgeIdx=[edgeIdx;zeros(size(edgeIdx))];
            edges=[edges;zeros(size(edges))];
        end
        edges(nEdges,1)=srcV;
        edges(nEdges,2)=inputId;
        edgeIdx(nEdges)=j;
    end


    function[vStart,vEnd]=addDataInputs(ph)
        [vStart,vEnd]=addInput(ph.Inport);
    end

    function[vStart,vEnd]=addControlInputs(ph)
        controlPorts=[ph.Enable,ph.Trigger,ph.Ifaction];
        [vStart,vEnd]=addInput(controlPorts);
    end


    function[vStart,vEnd]=addInput(inportH)

        vStart=nNodes+1;
        for iIdx=1:length(inportH)

            if(isArrayOfBus(mdlH,inportH(iIdx)))
                Mex=MException('Sldv:se:ArrayOfBusesNotSupported',...
                getString(message('Sldv:se:ArrayOfBusesNotSupported')));
                throw(Mex);
            end

            nNodes=nNodes+1;
            if nNodes>length(nodeTypes)
                nodeTypes=[nodeTypes;zeros(size(nodeTypes))];%#ok<AGROW>
            end
            nodeTypes(nNodes)=3;

            id=nNodes;
            inH=inportH(iIdx);
            nInputs=nInputs+1;
            if nInputs>length(inputId)
                inputId=[inputId;zeros(size(inputId))];%#ok<AGROW>
                inputPortHandles=[inputPortHandles;zeros(size(inputPortHandles))];%#ok<AGROW>
            end
            inputId(nInputs)=id;
            inputPortHandles(nInputs)=inH;
        end
        vEnd=nNodes;
    end

    function[varStart,varEnd]=addVarForOutport(ph)

        varStart=nNodes+1;
        for oIdx=1:length(ph.Outport)

            if(isArrayOfBus(mdlH,ph.Outport(oIdx)))
                Mex=MException('Sldv:se:ArrayOfBusesNotSupported',...
                getString(message('Sldv:se:ArrayOfBusesNotSupported')));
                throw(Mex);
            end


            nNodes=nNodes+1;
            if nNodes>length(nodeTypes)
                nodeTypes=[nodeTypes;zeros(size(nodeTypes))];%#ok<AGROW>
            end
            nodeTypes(nNodes)=1;

            sigid=nNodes;
            outHandle=ph.Outport(oIdx);
            nVars=nVars+1;
            if nVars>length(varId)
                varId=[varId;zeros(size(varId))];%#ok<AGROW>
                outportHandles=[outportHandles;...
                zeros(size(outportHandles))];%#ok<AGROW>
            end
            varId(nVars)=sigid;
            outportHandles(nVars)=outHandle;
        end
        varEnd=nNodes;
    end
    function[varStart,varEnd]=addVarForStatePort(ph)

        varStart=nNodes+1;
        for oIdx=1:length(ph.State)


            nNodes=nNodes+1;
            if nNodes>length(nodeTypes)
                nodeTypes=[nodeTypes;zeros(size(nodeTypes))];%#ok<AGROW>
            end
            nodeTypes(nNodes)=1;

            sigid=nNodes;
            outHandle=ph.State(oIdx);
            nVars=nVars+1;
            if nVars>length(varId)
                varId=[varId;zeros(size(varId))];%#ok<AGROW>
                outportHandles=[outportHandles;...
                zeros(size(outportHandles))];%#ok<AGROW>
            end
            varId(nVars)=sigid;
            outportHandles(nVars)=outHandle;
        end
        varEnd=nNodes;
    end

    function addEdgesForBlockOutput(blkProcId,varIds)

        for vIdx=1:length(varIds)
            nEdges=nEdges+1;
            if nEdges>length(edgeIdx)
                edgeIdx=[edgeIdx;zeros(size(edgeIdx))];%#ok<AGROW>
                edges=[edges;zeros(size(edges))];%#ok<AGROW>
            end
            edges(nEdges,:)=[blkProcId,varIds(vIdx)];
            edgeIdx(nEdges)=0;
        end
    end

    function addEdgesForBlockState(blkProcId,varIds)

        for vIdx=1:length(varIds)
            nEdges=nEdges+1;
            if nEdges>length(edgeIdx)
                edgeIdx=[edgeIdx;zeros(size(edgeIdx))];%#ok<AGROW>
                edges=[edges;zeros(size(edges))];%#ok<AGROW>
            end
            edges(nEdges,:)=[blkProcId,varIds(vIdx)];
            edgeIdx(nEdges)=0;
        end
    end

    function addProcForBlock(handle)

        nNodes=nNodes+1;
        if nNodes>length(nodeTypes)
            nodeTypes=[nodeTypes;zeros(size(nodeTypes))];
        end
        nodeTypes(nNodes)=2;

        procid=nNodes;
        nProcs=nProcs+1;
        if nProcs>length(procId)
            procId=[procId;zeros(size(procId))];
            blockHandles=[blockHandles;zeros(size(blockHandles))];
        end
        procId(nProcs)=procid;
        blockHandles(nProcs)=handle;


    end


    function addEdgesForBlockInput(blkProcId,blkRto,inIds,ph)

        blkJacobian=[];

        if~isempty(inIds)
            try
                blkJacobian=blkRto.JacobianPattern;
            catch


                blkJacobian=[];
            end
        end

        if(~isempty(blkJacobian))
            subDMatrix=blkJacobian.Mp(blkJacobian.Nx+1:end,...
            blkJacobian.Nx+1:end);
        else
            subDMatrix=[];
        end
        inIndex=1;

        for iIdx=1:length(inIds)
            dfgIdx=inIds(iIdx);

            nEdges=nEdges+1;
            if nEdges>length(edgeIdx)
                edgeIdx=[edgeIdx;zeros(size(edgeIdx))];%#ok<AGROW>
                edges=[edges;zeros(size(edges))];%#ok<AGROW>
            end
            edges(nEdges,:)=[dfgIdx,blkProcId];
            edgeIdx(nEdges)=-1;

            inPortH=ph.Inport(iIdx);
            inPortWidth=get(inPortH,'CompiledPortWidth');

            if(length(ph.Outport)==1&&~isempty(subDMatrix))

                subDepMatrix=subDMatrix(1:end,inIndex:inIndex+inPortWidth-1);

                calculateEdgeDependence(blkRto,subDepMatrix,ph,iIdx);

            end

            inIndex=inIndex+inPortWidth;
        end

    end


    function calculateEdgeDependence(blkRto,subDepMatrix,ph,iIdx)




        edgeDep=0;
        if(~isempty(nonzeros(subDepMatrix)))
            [rows,col]=size(subDepMatrix);
            if((rows==col)&&isdiag(subDepMatrix))

                dataDependenceBetweenInputAndVar(nEdges)={ph.Outport(1),2};
            else

                dataDependenceBetweenInputAndVar(nEdges)={ph.Outport(1),1};
            end
            edgeDep=1;
        else

            dataDependenceBetweenInputAndVar(nEdges)={ph.Outport(1),0};
        end



        if~edgeDep
            try
                if IsControlPort(blkRto.BlockHandle,iIdx)||~(blkRto.InputPort(iIdx).DirectFeedthrough)
                    dataDependenceBetweenInputAndVar(nEdges)={ph.Outport(1),1};
                end
            catch
            end
        end

    end

    function yesno=IsControlPort(blkh,idx)
        bo=get_param(blkh,'object');
        yesno=false;
        if(strcmp(bo.BLockType,'MultiPortSwitch')&&idx==1)||...
            (strcmp(bo.BLockType,'Switch')&&idx==2)||...
            (strcmp(bo.BLockType,'Interpolation_n-D')&&idx==1)
            yesno=true;
            return
        end
    end

    function addEnableOrTriggerPorts(ports,procId)



        for aEK=1:length(ports)
            port=get(ports(aEK),'Object');

            inputId=inportHToInputId(port.handle);

            nEdges=nEdges+1;
            if nEdges>length(edgeIdx)
                edgeIdx=[edgeIdx;zeros(size(edgeIdx))];%#ok<AGROW>
                edges=[edges;zeros(size(edges))];%#ok<AGROW>
            end
            edges(nEdges,:)=[inputId,procId];
            edgeIdx(nEdges)=-1;



            dataDependenceBetweenInputAndVar(nEdges)={-1,0};

            actSrc=port.getActualSrc;
            srcPH=actSrc(:,1);


            widthCounter=0;
            for aEJ=1:size(srcPH,1)
                widthOffset=actSrc(aEJ,3);
                if portHandleToOid.isKey(srcPH(aEJ))
                    currentSrcH=srcPH(aEJ);
                    srcId=portHandleToOid(currentSrcH);
                    addDFGEdge(srcId,inputId,aEJ);


                    busWidth=actSrc(aEJ,4);
                    if(busWidth==-1)
                        varOffset=actSrc(aEJ,2);
                    else
                        varOffset=-1;
                    end

                    if size(actSrc,1)==1
                        inputOffset=0;
                    else
                        inputOffset=widthCounter;
                    end

                    outputPortToInputPortEdges(nEdges)={varOffset,...
                    inputOffset,widthOffset};
                end
                widthCounter=widthCounter+widthOffset;
            end
        end
    end


    function sigid=addVarForDSM(handle,isGlobal)


        nNodes=nNodes+1;
        if nNodes>length(nodeTypes)
            nodeTypes=[nodeTypes;zeros(size(nodeTypes))];
        end
        nodeTypes(nNodes)=1;

        sigid=nNodes;
        if~isGlobal
            localDsmToIdx(handle)=sigid;
        else
            name=get(handle,'DataStoreName');
            globalDsmNameToDfgIdx(name)=sigid;
            dfgIdxToGlobalDsmName(sigid)=name;
        end
    end
    function inputId=addInputAndEdgesForNVInport(inport,theProcId,...
        parent,bO)


        inputId=inportHToInputId(inport);

        nEdges=nEdges+1;
        if nEdges>length(edgeIdx)
            edgeIdx=[edgeIdx;zeros(size(edgeIdx))];
            edges=[edges;zeros(size(edges))];
        end
        edges(nEdges,:)=[inputId,theProcId];
        edgeIdx(nEdges)=-1;

        dataDependenceBetweenInputAndVar(nEdges)={-1,2};

        if~isKey(refMdlToMdlBlk,parent)



            actSrcs=bO.getActualSrc;

            widthCounter=0;
            for j=1:size(actSrcs,1)
                srcPH=actSrcs(j,1);
                width=actSrcs(j,3);
                if portHandleToOid.isKey(srcPH)
                    srcId=portHandleToOid(srcPH);
                    addDFGEdge(srcId,inputId,j);

                    busWidth=actSrcs(j,4);

                    if(busWidth==-1)
                        varOffset=actSrcs(j,2);
                    else
                        varOffset=-1;
                    end

                    if size(actSrcs,1)==1
                        InputOffset=0;
                    else
                        InputOffset=widthCounter;
                    end

                    outputPortToInputPortEdges(nEdges)={varOffset,...
                    InputOffset,width};

                end
                widthCounter=widthCounter+width;
            end
        end
    end
end


function[fwd,bwd]=createTwoWayMap(keyType,valueType)

    fwd=containers.Map('KeyType',keyType,'ValueType',valueType);
    bwd=containers.Map('KeyType',valueType,'ValueType',keyType);
end

function[fwd,bwd]=createInjectiveMap(keyType,valueType)


    fwd=containers.Map('KeyType',keyType,'ValueType',valueType);
    bwd=containers.Map('KeyType',valueType,'ValueType','any');
end

function bh=findInportBlock(mdl,idx)

    function yesno=isRootInport(bh,i)

        bo=get(bh,'Object');
        po=bo.getParent();
        yesno=isa(bo,'Simulink.Inport')&&isa(po,'Simulink.BlockDiagram')&&...
        (str2double(bo.Port)==i);
    end

    mObj=get_param(mdl,'Object');
    compiledList=mObj.getCompiledBlockList;


    flags=false(numel(compiledList),1);
    for i=1:length(compiledList)
        flags(i)=isRootInport(compiledList(i),idx);
    end

    bh=compiledList(flags);
end


function bh=findOutportBlockInReferencedModel(mdl,idx)

    function yesno=isOutport(bh,i)
        obj=get(bh,'Object');
        yesno=isa(obj,'Simulink.Outport')&&(str2double(obj.Port)==i);
    end
    mObj=get_param(mdl,'Object');
    sortedList=mObj.getSortedList;


    flags=false(numel(sortedList),1);
    for i=1:length(sortedList)
        flags(i)=isOutport(sortedList(i),idx);
    end
    bh=sortedList(flags);
end

function offset=getOffsetFrmActualInfo(actualResults,handleToBeMatched)

    offset=-1;
    actualHandles=actualResults(:,1);
    matchingIndex=find(actualHandles==handleToBeMatched);
    if(~isempty(matchingIndex))

        offset=actualResults(matchingIndex(1),2);
    end
end




function[JacIr,JacJc,JacTotalNonZero]=getIrJcForD(blkJacobian)

    if isempty(blkJacobian)
        JacIr=[];
        JacJc=[];
        JacTotalNonZero=0;
    else

        JacIr=blkJacobian.Ir;
        JacJc=blkJacobian.Jc;
        JacTotalNonZero=numel(blkJacobian.Pr);

        numOfStates=blkJacobian.Nx;


        if(numOfStates~=0)
            [JacIr,JacJc,JacTotalNonZero]=Analysis.getIrJcForSubMatrix(JacIr,JacJc,...
            JacTotalNonZero,numOfStates+1,length(JacIr),...
            numOfStates+1,length(JacJc));
        end
    end

end

function yesno=isMatrixDiagnol(subIr,subJc,subTotalNonZero)
    yesno=false;

    if(length(subIr)==subTotalNonZero)&&(length(subJc)==subTotalNonZero)
        expectedArray=[0:(subTotalNonZero-1)];
        if all(subIr==expectedArray)&&all(subJc==expectedArray)
            yesno=true;
        end
    end

end

function bool=isArrayOfBus(mdl,port)






    bool=false;


    assert(~strcmp(get_param(mdl,'SimulationStatus'),'stopped'));

    if~any(strcmpi(get_param(mdl,'StrictBusMsg'),{'None','warning'}))&&...
        strcmp(get_param(port,'CompiledBusType'),'NON_VIRTUAL_BUS')&&...
        (prod(get_param(port,'CompiledPortDimensions'))~=1)
        bool=true;
    end
end
