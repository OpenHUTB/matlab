function errMsg=identify(this)




    errMsg=[];
    mdls=[{this.fMdl},this.fRefMdls];

    this=resetAnalysisResults(this);
    if~this.fUserSpecifiedSortedOrder
        sess=Simulink.CMI.CompiledSession(Simulink.EngineInterfaceVal.byFiat);
        bd=Simulink.CMI.CompiledBlockDiagram(sess,this.fTopMdlHandle);
        init(bd);
    end
    for mIdx=1:length(mdls)
        topMdlHandle=get_param(mdls{mIdx},'handle');
        byNameList=groupBlocksByDSName(this,topMdlHandle);
        nB=length(this.fByNameList);
        nb=length(byNameList);

        this.fFcnCallEnableIteratorIndex{end+1}=detectCrossFunctionCallBoundary(byNameList,topMdlHandle)+nB;
        this.fCondTerminatedIndex{end+1}=detectCondTerminated(byNameList,topMdlHandle)+nB;
        this.fElementIndex{end+1}=detectElementRW(byNameList)+nB;
        this.fGlobalIndex{end+1}=detectGlobal(byNameList)+nB;
        this.fStateflowIndex{end+1}=detectStateflow(byNameList)+nB;
        this.fMultirateIndex{end+1}=detectMultirate(byNameList)+nB;
        this.fVariantIndex{end+1}=detectVariant(byNameList)+nB;
        this.fMultiInOutIndex{end+1}=detectMultiInOut(byNameList)+nB;
        this.fPartialArrayIndex{end+1}=detectPartialArray(byNameList)+nB;
        this.fByNameList=horzcat(this.fByNameList,byNameList);

        this.fCandidateIndex{end+1}=nB+1:nB+nb;

        if slfeature('GlobalDSMRwElim')>0
            this.fNonCandidateIndex{end+1}=unique(horzcat(this.fFcnCallEnableIteratorIndex{end},...
            this.fStateflowIndex{end},this.fMultirateIndex{end},...
            this.fVariantIndex{end},this.fMultiInOutIndex{end},...
            this.fPartialArrayIndex{end},this.fCondTerminatedIndex{end}));
        else
            this.fNonCandidateIndex{end+1}=unique(horzcat(this.fFcnCallEnableIteratorIndex{end},this.fGlobalIndex{end},...
            this.fStateflowIndex{end},this.fMultirateIndex{end},...
            this.fVariantIndex{end},this.fMultiInOutIndex{end},...
            this.fPartialArrayIndex{end},this.fCondTerminatedIndex{end}));
        end

        this.fCandidateIndex{end}=setdiff(this.fCandidateIndex{end},this.fNonCandidateIndex{end});
        this=buildLibCandList(this,mIdx);
    end

    this=sortCandidates(this,length(mdls));
    this=excludeDifferentLibBehavior(this,length(mdls));
    this=updateNonCandReason(this,length(mdls));
    displayNonCandidates2(this,length(mdls));
    displayProposedCandidates(this,length(mdls));

    if~this.fUserSpecifiedSortedOrder
        term(bd);
    end
end

function this=updateNonCandReason(this,nMdls)












    this.fNonCandidateReason=cell(1,nMdls);
    for mIdx=1:nMdls
        nonCandIdx=this.fNonCandidateIndex{mIdx};
        if isempty(nonCandIdx)
            return
        end
        nonCandReason=cell(1,length(nonCandIdx));
        nonCandReason=addReason(nonCandReason,nonCandIdx,this.fFcnCallEnableIteratorIndex{mIdx},1);
        nonCandReason=addReason(nonCandReason,nonCandIdx,this.fCondTerminatedIndex{mIdx},2);
        if slfeature('GlobalDSMRwElim')==0
            nonCandReason=addReason(nonCandReason,nonCandIdx,this.fGlobalIndex{mIdx},3);
        end
        nonCandReason=addReason(nonCandReason,nonCandIdx,this.fStateflowIndex{mIdx},4);
        nonCandReason=addReason(nonCandReason,nonCandIdx,this.fMultirateIndex{mIdx},5);
        nonCandReason=addReason(nonCandReason,nonCandIdx,this.fVariantIndex{mIdx},6);
        nonCandReason=addReason(nonCandReason,nonCandIdx,this.fMultiInOutIndex{mIdx},7);
        nonCandReason=addReason(nonCandReason,nonCandIdx,this.fPartialArrayIndex{mIdx},8);
        nonCandReason=addReason(nonCandReason,nonCandIdx,this.fLibBehaveDifferentIndex{mIdx},9);
        this.fNonCandidateReason{mIdx}=nonCandReason;
    end

end

function nonCandReason=addReason(nonCandReason,nonCandIdx,nonCandList,reasonIdx)




    for i=1:length(nonCandList)
        idx=find(nonCandIdx==nonCandList(i));
        nonCandReason{idx}(end+1)=reasonIdx;
    end
end

function this=resetAnalysisResults(this)

    this.fFcnCallEnableIteratorIndex={};
    this.fCondTerminatedIndex={};
    this.fElementIndex={};
    this.fGlobalIndex={};
    this.fStateflowIndex={};
    this.fMultirateIndex={};
    this.fVariantIndex={};
    this.fMultiInOutIndex={};
    this.fPartialArrayIndex={};
    this.fByNameList={};

    this.fCandidateIndex={};
    this.fDefaultCandIndex=[];
    this.fNonCandidateIndex={};
    this.fLibCandIdx=cell(size(this.fLibMdls));
end


function this=excludeDifferentLibBehavior(this,nMdls)
    nLibs=length(this.fLibMdls);
    this.fLibBehaveDifferentIndex=cell([1,nMdls]);
    for i=1:nLibs
        instanceIndex=this.fLibCandIdx{i};
        shouldExclude=false;
        if length(instanceIndex)>=2
            nameStrA={};
            for k=1:length(this.fByNameList{instanceIndex(1)})
                nameStrA{end+1}=get_param(this.fByNameList{instanceIndex(1)}(k),'Name');%#ok
            end
            for j=2:length(instanceIndex)
                for k=1:length(this.fByNameList{instanceIndex(j)})
                    if~strcmp(get_param(this.fByNameList{instanceIndex(j)}(k),'Name'),nameStrA{k})
                        shouldExclude=true;
                        break;
                    end
                end
            end
            if shouldExclude
                for j=1:length(instanceIndex)
                    for k=1:length(nMdls)
                        idx=find(this.fCandidateIndex{k}==instanceIndex(j));
                        if~isempty(idx)
                            this.fCandidateIndex{k}(idx)=[];
                            this.fNonCandidateIndex{k}(end+1)=instanceIndex(j);
                            this.fLibBehaveDifferentIndex{k}(end+1)=instanceIndex(j);
                            break;
                        end
                    end
                end
                this.fLibCandIdx{i}=[];
            end
        end
    end
end

function this=buildLibCandList(this,mIdx)
    candIdx=this.fCandidateIndex{mIdx};
    for i=1:length(candIdx)
        idx=candIdx(i);
        blockList=this.fByNameList{idx};
        bH=findLowestCommParentHandle(blockList);
        if~isempty(get_param(bH,'parent'))&&(~strcmp(get_param(bH,'LinkStatus'),'none')&&~strcmp(get_param(bH,'LinkStatus'),'inactive'))
            while~strcmp(get_param(bH,'LinkStatus'),'resolved')
                bH=get_param(get_param(bH,'parent'),'handle');
            end
            libInfo=libinfo(bH);
            for j=1:length(libInfo)
                if libInfo(j).Block==bH
                    libName=libInfo(j).Library;
                    libID=find(strcmp([this.fLibMdls],libName));
                    if length(this.fLibCandIdx)<libID
                        this.fLibCandIdx{libID}=idx;
                    else
                        this.fLibCandIdx{libID}(end+1)=idx;
                    end
                    break;
                end
            end
        end
    end
end

function this=sortCandidates(this,nMdls)
    for mIdx=1:nMdls
        deleteIdx=[];
        hiddenSubsysIdx=[];
        for i=1:length(this.fCandidateIndex{mIdx})
            listIdx=this.fCandidateIndex{mIdx}(i);
            blockList=this.fByNameList{listIdx};
            if strcmp(get_param(blockList(1),'blocktype'),'DataStoreMemory')
                memoryBlock=blockList(1);
                blockList(1)=[];
            end
            if this.fUserSpecifiedSortedOrder
                blockList=sortByUserSpecifiedOrder(blockList);
            else
                [blockList,hasHiddenSubsys]=sortByExecOrder(blockList);
                if hasHiddenSubsys
                    hiddenSubsysIdx(end+1)=this.fCandidateIndex{mIdx}(i);%#ok
                    this.fNonCandidateIndex{mIdx}=unique([this.fNonCandidateIndex{mIdx},this.fCandidateIndex{mIdx}(i)]);
                    deleteIdx(end+1)=i;%#ok
                end
            end
            if~slfeature('GlobalDSMRwElim')
                blockList(2:end+1)=blockList;
                blockList(1)=memoryBlock;
            end
            this.fByNameList{listIdx}=blockList;
        end
        this.fCandidateIndex{mIdx}(deleteIdx)=[];
        this.fHiddenSubsysIdx{mIdx}=hiddenSubsysIdx;
    end

end

function mapObj=buildWrite2BusTypeMap(mapObj,writeList)
    for i=1:length(writeList)
        writeBlk=writeList(i);
        pHs=get_param(writeBlk,'PortHandles');
        inport=pHs.Inport;
        if~strcmp(get_param(inport,'CompiledBusType'),'NOT_BUS')
            if(~isKey(mapObj,writeBlk))
                str=get_param(writeBlk,'CompiledPortDataTypes');
                if~isempty(str)
                    mapObj(writeBlk)=str.Inport{1};
                end
            end
        end
    end
end

function byNameList=groupBlocksByDSName(this,topMdlHandle)

    memoryList=findDSBlocks(topMdlHandle,'m');
    totalMemory=length(memoryList);
    readList=findDSBlocks(topMdlHandle,'r');
    totalRead=length(readList);
    writeList=findDSBlocks(topMdlHandle,'w');
    this.fWrite2BusTypeMap=buildWrite2BusTypeMap(this.fWrite2BusTypeMap,writeList);
    totalWrite=length(writeList);
    completeList=[memoryList;readList;writeList];
    SForMLFcnBlockPool=[];
    SForMLFcnBlock=0;
    dispMsg(this,'**************************');
    dispMsg(this,['In the model: ',get_param(topMdlHandle,'Name'),' , there are:']);
    dispMsg(this,[num2str(totalMemory),' data store memory blocks,']);
    dispMsg(this,[num2str(totalRead),' data store read blocks,']);
    dispMsg(this,[num2str(totalWrite),' data store write blocks.',newline]);

    localByNameList={};
    totalByName=[];
    for i=1:length(memoryList)
        corrBlocks=get_param(memoryList(i),'DSReadWriteBlocks');
        for j=length(corrBlocks):-1:1
            if checkCommentOut(corrBlocks(j).handle)
                corrBlocks(j)=[];
            end
        end
        corrBlockHandles=[];
        if~isempty(corrBlocks)
            for j=1:length(corrBlocks)
                corrBlockHandles(j)=corrBlocks(j).handle;%#ok
                if isSForMLFcnBlock(corrBlockHandles(j))
                    if find(SForMLFcnBlockPool==corrBlockHandles(j))
                        SForMLFcnBlock=SForMLFcnBlock+1;
                    else
                        SForMLFcnBlockPool(end+1)=corrBlockHandles(j);%#ok
                    end
                end
            end
        end
        localByNameList{i}=[memoryList(i),corrBlockHandles];%#ok
        totalByName(i)=length(localByNameList{i});%#ok % stores how many R and W blocks are under each data store name given by M blocks in memoryList
        index=ismember(completeList,localByNameList{i});
        completeList(index)=[];
    end

    globalList=completeList;
    globalByNameList={};
    globalNameList={};
    totalGlobalByName=[];
    while~isempty(globalList)
        globalName=get_param(globalList(1),'DataStoreName');
        globalNameList{end+1}=globalName;%#ok
        sameNameIndex=[];
        for i=1:length(globalList)
            currentName=get_param(globalList(i),'DataStoreName');
            if strcmp(currentName,globalName)
                sameNameIndex(i)=1;%#ok
            end
        end
        totalGlobalByName(end+1)=sum(sameNameIndex);%#ok
        sameNameIndex=logical(sameNameIndex);

        if slfeature('GlobalDSMRwElim')>0
            globalByNameList{end+1}=globalList(sameNameIndex).';%#ok
        else
            globalByNameList{end+1}=globalList(sameNameIndex);%#ok
        end
        globalList(sameNameIndex)=[];
    end

    completeByNameList=horzcat(localByNameList,globalByNameList);
    if(length(completeByNameList)>totalMemory)
        globalIndex=totalMemory+1:length(completeByNameList);%#ok
    end

    byNameList=completeByNameList;

end

function result=isSForMLFcnBlock(bh)

    if strcmp(get_param(bh,'blocktype'),'SubSystem')&&(strcmp(get_param(bh,'SFBlockType'),'Chart')||strcmp(get_param(bh,'SFBlockType'),'MATLAB Function'))
        result=true;
    else
        result=false;
    end
end


function condTerminatedIndex=detectCondTerminated(byNameList,topMdlHandle)


    condTerminatedIndex=[];
    for i=1:length(byNameList)
        corrBlocks=byNameList{i};
        hasRead=false;
        writeIndex=[];
        for j=1:length(corrBlocks)
            if strcmp(get_param(corrBlocks(j),'blocktype'),'DataStoreRead')
                hasRead=true;
            elseif strcmp(get_param(corrBlocks(j),'blocktype'),'DataStoreWrite')
                writeIndex(end+1)=j;%#ok
            end
        end
        if hasRead
            if strcmp(get_param(corrBlocks(1),'blocktype'),'DataStoreMemory')
                memoryBlock=corrBlocks(1);
                topParentPath=get_param(memoryBlock,'parent');
                topParentHandle=get_param(topParentPath,'handle');
            else
                topParentHandle=topMdlHandle;
            end
            foundTerminator=false;
            for k=1:length(writeIndex)
                parents=findParentUntilTop(corrBlocks(writeIndex(k)),topParentHandle);
                for l=1:length(parents)
                    if isIfActionSubsystem(parents(l))
                        pC=get_param(parents(l),'portconnectivity');
                        for m=1:length(pC)
                            if strcmp(pC(m).Type,'ifaction')
                                condBlock=pC(m).SrcBlock;
                            end
                        end
                        condPC=get_param(condBlock,'portconnectivity');
                        for n=1:length(condPC)
                            dstBlock=condPC(n).DstBlock;
                            if~isempty(dstBlock)
                                if strcmp(get_param(dstBlock,'blocktype'),'Terminator')
                                    foundTerminator=true;
                                    break;
                                end
                            end
                        end
                    end
                    if foundTerminator
                        break;
                    end
                end
                if foundTerminator
                    break;
                end
            end
            if foundTerminator
                condTerminatedIndex(end+1)=i;%#ok
            end
        end
    end
end

function boolResult=isIfActionSubsystem(handle)
    boolResult=false;
    if~isprop(handle,'BlockType')
        return
    end

    blockType=get_param(handle,'BlockType');
    if strcmp(blockType,'SubSystem')


        childBlocks=find_system(handle,'searchdepth','1',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'lookundermasks','on');
        for i=1:length(childBlocks)
            childBlockType=get_param(childBlocks(i),'BlockType');
            if strcmp(childBlockType,'ActionPort')
                boolResult=true;
                return
            end
        end
    end
end

function fcnCallIndex=detectCrossFunctionCallBoundary(byNameList,topMdlHandle)


    fcnCallIndex=[];
    for i=1:length(byNameList)
        corrBlocks=byNameList{i};
        if strcmp(get_param(corrBlocks(1),'blocktype'),'DataStoreMemory')
            memoryBlock=corrBlocks(1);
            corrBlocks(1)=[];
            topParentPath=get_param(memoryBlock,'parent');
            topParentHandle=get_param(topParentPath,'handle');
        else
            topParentHandle=topMdlHandle;
        end
        hasAtLeastOneWrite=false;
        crossFcnCallDetected=false;


        fcnCallHandle=[];

        if~isempty(corrBlocks)
            for j=1:length(corrBlocks)
                if strcmp(get_param(corrBlocks(j),'BlockType'),'DataStoreWrite')
                    hasAtLeastOneWrite=true;
                end
                foundFcnCallSubsystem=false;
                parentsHandle=findParentUntilTop(corrBlocks(j),topParentHandle);
                for k=1:length(parentsHandle)
                    if isFcnCallEnableIteratorSubsystem(parentsHandle(k))
                        foundFcnCallSubsystem=true;
                        numFcnCallSubsystem=length(fcnCallHandle);
                        fcnCallHandle=unique([fcnCallHandle;parentsHandle(k)]);
                        if(length(fcnCallHandle)>numFcnCallSubsystem&&j>1)
                            crossFcnCallDetected=true;
                            break;
                        end
                        break;
                    end
                end
                if(~isempty(fcnCallHandle)&&~foundFcnCallSubsystem)
                    crossFcnCallDetected=true;
                end
            end
        end

        if(crossFcnCallDetected&&hasAtLeastOneWrite)
            fcnCallIndex(end+1)=i;%#ok


            for j=1:length(fcnCallHandle)

            end
        end
    end

end

function elementIndex=detectElementRW(byNameList)


    elementIndex=[];
    for i=1:length(byNameList)
        corrBlocks=byNameList{i};
        if strcmp(get_param(corrBlocks(1),'blocktype'),'DataStoreMemory')
            corrBlocks(1)=[];
        end
        dsElements={};
        for j=1:length(corrBlocks)
            if isprop(corrBlocks(j),'DataStoreElements')
                dsElements{end+1}=get_param(corrBlocks(j),'datastoreelements');%#ok % might be a data store memory bug which reports non r/w blocks in corresponding r/w block list.%#ok
            end
        end
        total=length(unique(dsElements));
        if total>1



            elementIndex(end+1)=i;%#ok
        end
    end
end

function partialArrayIndex=detectPartialArray(byNameList)

    partialArrayIndex=[];
    for i=1:length(byNameList)
        corrBlocks=byNameList{i};
        if strcmp(get_param(corrBlocks(1),'blocktype'),'DataStoreMemory')
            corrBlocks(1)=[];
        end
        for j=1:length(corrBlocks)
            if isprop(corrBlocks(j),'DataStoreElements')
                elementStr=get_param(corrBlocks(j),'datastoreelements');
                for k=1:length(elementStr)
                    if elementStr(k)=='('||elementStr(k)==')'
                        partialArrayIndex(end+1)=i;%#ok

                        break;
                    end
                end
            end
        end
    end
end

function multiInOutIndex=detectMultiInOut(byNameList)

    multiInOutIndex=[];
    for i=1:length(byNameList)
        corrBlocks=byNameList{i};
        for j=1:length(corrBlocks)
            if isSForMLFcnBlock(corrBlocks(j))
                continue;
            end
            if sum(get_param(corrBlocks(j),'ports'))>1
                multiInOutIndex(end+1)=i;%#ok

                break;
            end
        end
    end
end

function globalIndex=detectGlobal(byNameList)



    globalIndex=[];
    for i=1:length(byNameList)
        firstBlock=byNameList{i}(1);
        if~strcmp(get_param(firstBlock,'blocktype'),'DataStoreMemory')
            globalIndex(end+1)=i;%#ok

        else
            if strcmp(get_param(firstBlock,'StateMustResolveToSignalObject'),'on')
                globalIndex(end+1)=i;%#ok
            end
        end
    end
end

function variantIndex=detectVariant(byNameList)

    variantIndex=[];
    for i=1:length(byNameList)
        corrBlocks=byNameList{i};
        for j=1:length(corrBlocks)
            if isempty(get_param(corrBlocks(j),'SortedOrderDisplay'))
                variantIndex(end+1)=i;%#ok

            end
        end
    end

end

function multirateIndex=detectMultirate(byNameList)



    multirateIndex=[];
    for i=1:length(byNameList)
        corrBlocks=byNameList{i};
        if strcmp(get_param(corrBlocks(1),'blocktype'),'DataStoreMemory')
            corrBlocks(1)=[];
        end
        if length(corrBlocks)>1
            for j=2:length(corrBlocks)
                if~strcmp(getBlockSampleTime(corrBlocks(j-1)),getBlockSampleTime(corrBlocks(j)))
                    multirateIndex(end+1)=i;%#ok

                    break;
                end
            end
        end
    end
end

function sampleTime=getBlockSampleTime(handle)


    if isprop(handle,'SampleTime')
        sampleTime=get_param(handle,'SampleTime');
    elseif isprop(handle,'SystemSampleTime')
        sampleTime=get_param(handle,'SystemSampleTime');
    end
end

function stateflowIndex=detectStateflow(byNameList)


    stateflowIndex=[];
    for i=1:length(byNameList)
        corrBlocks=byNameList{i};
        for j=1:length(corrBlocks)
            if isSForMLFcnBlock(corrBlocks(j))
                stateflowIndex(end+1)=i;%#ok
                continue;
            end
        end
    end
end

function this=displayNonCandidates2(this,nMdls)


    for mIdx=1:nMdls
        nCand=length(this.fNonCandidateReason{mIdx});
        for j=1:nCand
            nReason=length(this.fNonCandidateReason{mIdx}{j});
            reasonStr='';
            for k=1:nReason
                thisReasonStr=genReasonStr(this.fNonCandidateReason{mIdx}{j}(k));
                if k==1
                    reasonStr=['1) ',thisReasonStr];
                else
                    reasonStr=[reasonStr,', 2) ',thisReasonStr];%#ok
                end
            end
            reasonStr=[reasonStr,'.'];%#ok
            dsmName=get_param(this.fByNameList{this.fNonCandidateIndex{mIdx}(j)}(1),'DataStoreName');
            reasonStr=['The DSM blocks under name: ',dsmName,' cannot be eliminated due to ',reasonStr];%#ok
            dispMsg(this,reasonStr);
        end
    end

end

function reasonStr=genReasonStr(reasonInteger)










    switch reasonInteger
    case 1
        reasonStr='cross function call subsystem, iterator subsystem or enabled subsystem boundary';
    case 2
        reasonStr='have at least one data store write block falling into an If Action Subsystem whose control block connects to a terminator block';
    case 3
        reasonStr='is global data store';
    case 4
        reasonStr='has stateflow access';
    case 5
        reasonStr='have different execution rate';
    case 6
        reasonStr='have been used in variants';
    case 7
        reasonStr='have at least one multi-port access block';
    case 8
        reasonStr='have at least one partial array access block';
    case 9
        reasonStr='have different relative sorted execution orders than other instances of the same library';
    otherwise
        reasonStr='';
    end

end


function this=displayNonCandidates(this,nMdls)


    for mIdx=1:nMdls


        for i=1:length(this.fFcnCallEnableIteratorIndex{mIdx})
            j=this.fFcnCallEnableIteratorIndex{mIdx}(i);
            dsmName=get_param(this.fByNameList{j}(1),'DataStoreName');
            dispMsg(this,['Data store read/write blocks under name: ',dsmName,' has cross function-call, enabled/triggered or iterator subsystem boundary access blocks. Hence, they cannot be eliminated.']);
        end


        for i=1:length(this.fCondTerminatedIndex{mIdx})
            j=this.fCondTerminatedIndex{mIdx}(i);
            dsmName=get_param(this.fByNameList{j}(1),'DataStoreName');
            dispMsg(this,['Data store read/write blocks under name: ',dsmName,' has at least one write block falling into an If Action Subsystem whose control block connects to a terminator block. Hence, they cannot be eliminated.']);
        end


        for i=1:length(this.fGlobalIndex{mIdx})
            j=this.fGlobalIndex{mIdx}(i);
            dsmName=get_param(this.fByNameList{j}(1),'DataStoreName');
            dispMsg(this,['Data store read/write blocks under name: ',dsmName,' is global. Hence, they cannot be eliminated.']);
        end


        for i=1:length(this.fStateflowIndex{mIdx})
            j=this.fStateflowIndex{mIdx}(i);
            dsmName=get_param(this.fByNameList{j}(1),'DataStoreName');
            dispMsg(this,['Data store read/write blocks under name: ',dsmName,' has stateflow access and will not be qualified for elimination.']);
        end


        for i=1:length(this.fLibBehaveDifferentIndex{mIdx})
            j=this.fLibBehaveDifferentIndex{mIdx}(i);
            dsmName=get_param(this.fByNameList{j}(1),'DataStoreName');
            dispMsg(this,['Data store read/write blocks under name: ',dsmName,' have different relative sorted orders than other instances of the same library. For now, they cannot be eliminated.']);
        end


        for i=1:length(this.fMultirateIndex{mIdx})
            j=this.fMultirateIndex{mIdx}(i);
            dsmName=get_param(this.fByNameList{j}(1),'DataStoreName');
            dispMsg(this,['Data store read/write blocks under name: ',dsmName,' have different data store access rate. Hence, they cannot be eliminated.']);
        end


        for i=1:length(this.fMultirateIndex{mIdx})
            j=this.fMultirateIndex{mIdx}(i);
            dsmName=get_param(this.fByNameList{j}(1),'DataStoreName');
            dispMsg(this,['Data store read/write blocks under name: ',dsmName,' have been used in variants. Hence, they cannot be eliminated.']);
        end


        for i=1:length(this.fMultiInOutIndex{mIdx})
            j=this.fMultiInOutIndex{mIdx}(i);
            dsmName=get_param(this.fByNameList{j}(1),'DataStoreName');
            dispMsg(this,['Data store read/write blocks under name: ',dsmName,' have multi-port access blocks which are not supported to be eliminated.']);
        end

    end

end


function this=displayProposedCandidates(this,nMdls)



    dispMsg(this,'Data store read/write blocks under the following name are detected as elimination candidates:');
    numCand=0;
    for mIdx=1:nMdls
        this.fDefaultCandIndex=horzcat(this.fDefaultCandIndex,this.fCandidateIndex{mIdx});
        for i=1:length(this.fCandidateIndex{mIdx})
            j=this.fCandidateIndex{mIdx}(i);
            dsmName=get_param(this.fByNameList{j}(1),'DataStoreName');
            dispMsg(this,['#',num2str(j),': ',dsmName]);
            numCand=numCand+1;
        end
    end
    if numCand==0
        dispMsg(this,'No candidates are found.');
    end

end

function list=findDSBlocks(modelHandle,type)






    findActiveBlocksOfType=@(mdl,blockType)find_system(mdl,...
    'findall','on',...
    'lookundermasks','all',...
    'followlinks','on',...
    'RegExp','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'IncludeCommented','off',...
    'BlockType',blockType);

    switch type
    case 'm'
        list=findActiveBlocksOfType(modelHandle,'DataStoreMemory');
    case 'r'
        list=findActiveBlocksOfType(modelHandle,'DataStoreRead');
    case 'w'
        list=findActiveBlocksOfType(modelHandle,'DataStoreWrite');
    case 'a'
        list=findActiveBlocksOfType(modelHandle,'DataStoreMemory|DataStoreRead|DataStoreWrite');
    otherwise
        list=findDSBlocks(modelHandle,'a');
    end
end


function parentsHandle=findParentUntilTop(childHandle,topParentHandle)



    parentsHandle=[];

    while true
        parentPath=get_param(childHandle,'parent');
        if(isempty(parentPath)&&bdroot(childHandle)==childHandle)
            break
        end
        parentHandle=get_param(parentPath,'handle');
        parentsHandle=[parentsHandle,parentHandle];%#ok

        if parentHandle~=topParentHandle
            childHandle=parentHandle;
        else
            break
        end
    end

end


function boolResult=isFcnCallEnableIteratorSubsystem(handle)



    boolResult=false;

    if~isprop(handle,'BlockType')
        return
    end

    blockType=get_param(handle,'BlockType');

    if strcmp(blockType,'SubSystem')


        childBlocks=find_system(handle,'searchdepth','1',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'lookundermasks','on');

        for i=1:length(childBlocks)
            childBlockType=get_param(childBlocks(i),'BlockType');
            if strcmp(childBlockType,'TriggerPort')
                triggerType=get_param(childBlocks(i),'TriggerType');
                if strcmp(triggerType,'function-call')
                    boolResult=true;
                    return
                end
            end
            if strcmp(childBlockType,'EnablePort')
                boolResult=true;
            end
            if strcmp(childBlockType,'EventListener')
                boolResult=true;
            end
            if strcmp(childBlockType,'WhileIterator')||strcmp(childBlockType,'ForIterator')
                boolResult=true;
            end
        end
    end

end

function sortedList=sortByUserSpecifiedOrder(inputList)



    if isempty(inputList)
        sortedList=[];
        return
    end

    n=length(inputList);
    sortedList=inputList;

    for i=1:n-1
        totalCompare=n-i;
        for j=1:totalCompare
            isArg1B4Arg2=userSpecifiedOrderCompare(sortedList(j),sortedList(j+1));
            if~isArg1B4Arg2
                temp=sortedList(j);
                sortedList(j)=sortedList(j+1);
                sortedList(j+1)=temp;
            end
        end
    end
end

function isArg1B4Arg2=userSpecifiedOrderCompare(handle1,handle2)

    if handle1==handle2

        isArg1B4Arg2=false;
        return
    end

    blocks={getfullname(handle1),getfullname(handle2)};
    sequenceNumber={};
    for i=1:length(blocks)
        block=ASCET2Simulink.Block(blocks{i});
        sequenceNumber{i}=block.getSequenceNumber();%#ok
        if isempty(sequenceNumber{i}.getValue)
            priority=get_param(blocks(i),'priority');
            if(str2double(priority{1})==-65536)
                if i==1
                    isArg1B4Arg2=true;
                else
                    isArg1B4Arg2=false;
                end
                return
            end
            if(str2double(priority{1})==65535)
                if i==1
                    isArg1B4Arg2=false;
                else
                    isArg1B4Arg2=true;
                end
                return
            end






        end

    end

    compareResult=sequenceNumber{1}.compare(sequenceNumber{2});
    if(compareResult==-1)
        isArg1B4Arg2=true;
    elseif(compareResult==1)
        isArg1B4Arg2=false;
    else
        if strcmp(get_param(handle1,'blocktype'),'DataStoreRead')&&strcmp(get_param(handle2,'blocktype'),'DataStoreWrite')
            isArg1B4Arg2=true;
        elseif strcmp(get_param(handle2,'blocktype'),'DataStoreRead')&&strcmp(get_param(handle1,'blocktype'),'DataStoreWrite')
            isArg1B4Arg2=false;
        else
            error(['Failed to compare the execution order of the following blocks:',newline,getfullname(handle1),newline,getfullname(handle2)]);
        end
    end
end

function[sortedList,hasHiddenSubsys]=sortByExecOrder(inputList)


    hasHiddenSubsys=false;
    if isempty(inputList)
        sortedList=[];
        return
    end

    n=length(inputList);
    sortedList=inputList;

    for i=1:n-1
        totalCompare=n-i;
        for j=1:totalCompare
            [isArg1B4Arg2,hasHiddenSubsys]=execOrderCompare(sortedList(j),sortedList(j+1));
            if~isArg1B4Arg2
                temp=sortedList(j);
                sortedList(j)=sortedList(j+1);
                sortedList(j+1)=temp;
            end
        end
    end
end


function[result,hasHiddenSubsys]=execOrderCompare(handle1,handle2)




    hasHiddenSubsys=false;

    path1=getfullname(handle1);
    path2=getfullname(handle2);


    slashPos1=find(path1=='/');
    slashPos2=find(path2=='/');


    numOfSlash1=length(slashPos1);
    numOfSlash2=length(slashPos2);
    minSlashLen=min(numOfSlash1,numOfSlash2);


    hierIndex=0;
    for i=1:minSlashLen
        if strcmp(path1(1:slashPos1(i)),path2(1:slashPos2(i)))
            hierIndex=i;
        else
            break
        end
    end



    diff1=numOfSlash1-hierIndex+1;
    for i=1:diff1
        if i==diff1
            blockPath1=path1;
        else
            blockPath1=path1(1:slashPos1(hierIndex+i)-1);
        end
        order1=get_param(blockPath1,'SortedOrderDisplay');
        if~isempty(order1)
            break
        end
    end

    diff2=numOfSlash2-hierIndex+1;
    for i=1:diff2
        if i==diff2
            blockPath2=path2;
        else
            blockPath2=path2(1:slashPos2(hierIndex+i)-1);
        end
        order2=get_param(blockPath2,'SortedOrderDisplay');
        if~isempty(order2)
            break
        end
    end

    colonPos1=strfind(order1,':');
    colonPos2=strfind(order2,':');


    numBeforeColon1=str2double(order1(1:colonPos1-1));
    numBeforeColon2=str2double(order2(1:colonPos2-1));
    if numBeforeColon1~=numBeforeColon2
        hasHiddenSubsys=true;
    end

    numOrder1=str2double(order1(colonPos1+1:end));
    numOrder2=str2double(order2(colonPos2+1:end));

    if numOrder1<=numOrder2
        result=true;
    else
        result=false;
    end
end


function lowestCommonParentHandle=findLowestCommParentHandle(handleList)


    n=length(handleList);

    for i=1:n
        path{i}=getfullname(handleList(i));%#ok
        slashPos{i}=find(path{i}=='/');%#ok
        numOfSlash(i)=length(slashPos{i});%#ok
    end
    minSlashLen=min(numOfSlash);


    hierIndex=0;
    for i=1:minSlashLen
        breakFor=false;
        for j=1:n-1
            path1=path{j}(1:slashPos{j}(i));
            path2=path{j+1}(1:slashPos{j+1}(i));
            if~strcmp(path1,path2)
                breakFor=true;
                break
            end
        end
        if breakFor
            break
        else
            hierIndex=i;
        end
    end


    lowestCommonParentPath=path{1}(1:slashPos{1}(hierIndex)-1);
    lowestCommonParentHandle=get_param(lowestCommonParentPath,'handle');

end


function result=checkCommentOut(bH)



    result=false;
    if strcmp(get_param(bH,'Commented'),'on')
        result=true;
    else
        parent=get_param(bH,'Parent');
        while~isempty(get_param(parent,'parent'))
            if strcmp(get_param(parent,'Commented'),'on')
                result=true;
                return
            else
                parent=get_param(parent,'parent');
            end
        end
    end

end




