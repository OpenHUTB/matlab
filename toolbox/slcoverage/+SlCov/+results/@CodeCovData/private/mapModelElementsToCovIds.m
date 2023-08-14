



function res=mapModelElementsToCovIds(traceabilityData,modelName,traceInfoMat,traceInfoBuilder)



    workaroundG1357349=~false;


    useTraceInfoDataForSfObj=~false;

    if isempty(traceInfoMat)&&isempty(traceInfoBuilder)
        res=[];
        return
    end

    if ispc()
        normalizePath=@(x)lower(regexprep(x,'\\','/'));
    else
        normalizePath=@(x)x;
    end


    traceInfo=struct('name',{},'rtwname',{},'pathname',{},'hyperlink',{},'location',{},'sid',{});
    if~isempty(traceInfoMat)
        if~isfile(traceInfoMat)
            try


                oldWarn=warning('off','Simulink:Engine:MdlFileShadowedByFile');
                clrWarn=onCleanup(@()warning(oldWarn.state,'Simulink:Engine:MdlFileShadowedByFile'));
                rptObj=rtw.report.getReportInfo(modelName);
                rptObj.generate('GenerateTraceInfo','on');
            catch ME

                if codeinstrumprivate('feature','disableErrorRecovery')
                    rethrow(ME);
                end
            end
        end
        if isfile(traceInfoMat)
            tmp=load(traceInfoMat);
            if isfield(tmp,'infoStruct')&&isfield(tmp.infoStruct,'traceInfo')
                if~isempty(tmp.infoStruct.traceInfo)&&...
                    isfield(tmp.infoStruct.traceInfo,'sid')&&...
                    isfield(tmp.infoStruct.traceInfo,'rtwname')
                    traceInfo=tmp.infoStruct.traceInfo;
                end
            end
        end
    end


    if isempty(traceInfoBuilder)
        code2ModelRecords=[];
        modelElems={};
    else
        code2ModelRecords=traceInfoBuilder.getCodeToModelRecords();
        modelElems=cat(1,code2ModelRecords.modelElems);
    end

    SID=unique(cat(1,modelName,modelElems,{traceInfo.sid}'));
    covIds=cell(numel(SID),1);
    covIds(:)={zeros(0,1,'int64')};
    nodes=cell(numel(SID),1);
    nodes(:)={internal.cxxfe.instrum.ProgramNode.empty};

    function linkCovIdToModelElem(idx,node)
        covIds{idx}=unique(cat(1,covIds{idx},int64(node.covId)));
    end
    function linkNodesToModelElem(idx,x)
        nodes{idx}=unique(cat(1,nodes{idx},x(:)));
    end


    nodesTree=traceabilityData.getProgramNodesTree();





    if isempty(nodesTree)
        res=[];
        return
    end


    badIdx=arrayfun(@(node)isempty(node.startLocation),nodesTree);
    nodesTree(badIdx)=[];
    startLocations=[nodesTree.startLocation];
    badIdx=arrayfun(@(srcLoc)isempty(srcLoc.file),startLocations);
    nodesTree(badIdx)=[];
    startLocations(badIdx)=[];

    files=[startLocations.file];
    fullPath=normalizePath({files.path});
    startLineNum=[startLocations.lineNum];

    origTraceInfo=traceInfo;
    if~useTraceInfoDataForSfObj
        traceInfo(:)=[];
    end
    traceInfo(arrayfun(@(x)isempty(x.location),traceInfo))=[];
    if~isempty(traceInfo)
        filesContent=containers.Map('KeyType','char','ValueType','any');

        tmp=cellfun(@(x)x(:),{traceInfo.location},'UniformOutput',false);
        allLocs=cat(1,tmp{:});
        if isempty(allLocs)
            allFiles={};
            allLineNums=[];
        else
            allFiles=normalizePath({allLocs.file}');
            allLineNums=double(cat(1,allLocs.line));
        end


        badElemIdx=false(numel(traceInfo),1);
        for ii=1:numel(traceInfo)
            if isempty(traceInfo(ii).location)
                badElemIdx(ii)=true;
                continue
            end
            try
                h=Simulink.ID.getHandle(traceInfo(ii).sid);
            catch ME

                if codeinstrumprivate('feature','disableErrorRecovery')
                    rethrow(ME);
                end


                h=[];
            end
            isSF=isa(h,'Stateflow.Object');

            badIdx=false(numel(traceInfo(ii).location),1);
            for jj=1:numel(traceInfo(ii).location)
                filePath=normalizePath(traceInfo(ii).location(jj).file);
                lineNum=double(traceInfo(ii).location(jj).line);
                if~isSF&&any(ismember(allFiles,filePath)&ismember(allLineNums,lineNum-1))
                    badIdx(jj)=true;
                end
                if filesContent.isKey(filePath)
                    lines=filesContent(filePath);
                else
                    try
                        buf=fileread(filePath);
                        lines=strsplit(buf,'\n','CollapseDelimiters',false);
                        filesContent(filePath)=lines;
                    catch ME

                        if codeinstrumprivate('feature','disableErrorRecovery')
                            rethrow(ME);
                        end
                        lines={};
                    end
                end
                if numel(lines)>=lineNum
                    if~isempty(regexp(lines{lineNum},'(Merge|Scope|Outport|Inport): ''.*''','once'))

                        badIdx(jj)=true;
                    elseif~isempty(regexp(lines{lineNum},'''.*'' incorporates:','once'))


                        badIdx(jj)=false;
                    elseif~isempty(regexp(lines{lineNum},'[rR]equirements for .*''.*''','once'))

                        badIdx(jj)=true;
                    end
                end
            end
            traceInfo(ii).location(badIdx)=[];
            if isempty(traceInfo(ii).location)
                badElemIdx(ii)=true;
            end
        end
        traceInfo(badElemIdx)=[];

        if~isempty(traceInfo)
            tmp=cellfun(@(x)x(:),{traceInfo.location},'UniformOutput',false);
            allLocs=cat(1,tmp{:});
            allFiles=normalizePath({allLocs.file}');
            allLineNums=double(cat(1,allLocs.line));
        end
    end


    for ii=1:numel(traceInfo)
        try
            h=Simulink.ID.getHandle(traceInfo(ii).sid);
        catch ME

            if codeinstrumprivate('feature','disableErrorRecovery')
                rethrow(ME);
            end


            h=[];
        end
        isSF=isa(h,'Stateflow.Object');
        if(~isSF&&~workaroundG1357349)||(isSF&&~useTraceInfoDataForSfObj)
            continue
        end
        idx=strcmp(traceInfo(ii).sid,SID);

        for jj=1:numel(traceInfo(ii).location)
            filePath=normalizePath(traceInfo(ii).location(jj).file);
            lineNum=double(traceInfo(ii).location(jj).line);


            if filesContent.isKey(filePath)
                lines=filesContent(filePath);
                if~isempty(regexp(lines{lineNum},'End of .*: ''.*''','once'))
                    continue
                end
            end


            kk=find(strcmp(filePath,fullPath)&(lineNum<=startLineNum),1,'first');
            if isempty(kk)
                continue
            end

            currNode=nodesTree(kk);
            if currNode.kind==internal.cxxfe.instrum.ProgramNodeKind.FCN_ENTER



                if isempty(traceInfo(ii).location(jj).scope)
                    continue;
                end
            elseif~isSF&&workaroundG1357349
                continue
            end

            followsOtherLoc=any(ismember(allFiles,filePath)&ismember(allLineNums,lineNum+1:currNode.startLocation.lineNum));
            if followsOtherLoc||isBreakDataFlowNode(currNode)

                candidateNodesInfo=cell(0,2);
            else
                if isempty(currNode.parentNode)


                    candidateNodesInfo={currNode,currNode.startLocation.lineNum+1};
                else
                    candidateNodesInfo={currNode.parentNode,currNode.endLocation.lineNum+1};
                end
            end


            prevNode=getPreviousNode(currNode);
            if~isempty(prevNode)&&(lineNum<prevNode.endLocation.lineNum)
                currNode=prevNode;
            end


            prevNode=getPreviousNode(currNode);
            if~isempty(prevNode)&&(prevNode.kind==internal.cxxfe.instrum.ProgramNodeKind.SWITCH_CASE)&&...
                ~any(ismember(allFiles,filePath)&ismember(allLineNums,prevNode.startLocation.lineNum+1:lineNum-1))
                if~isempty(candidateNodesInfo)
                    candidateNodesInfo{1,2}=currNode.startLocation.lineNum;
                end
                currNode=prevNode;
            end



            while true
                if followsOtherLoc

                elseif currNode.kind==internal.cxxfe.instrum.ProgramNodeKind.FCN_ENTER

                    linkCovIdToModelElem(idx,currNode);


                    fcnExitSubNodes=currNode.subNodes.toArray();
                    fcnExitSubNodes([fcnExitSubNodes.kind]~=internal.cxxfe.instrum.ProgramNodeKind.FCN_EXIT)=[];
                    if~isempty(fcnExitSubNodes)
                        linkNodesToModelElem(idx,fcnExitSubNodes);
                    end

                    candidateNodesInfo(end+1,:)={currNode,currNode.startLocation.lineNum};%#ok<AGROW>
                elseif currNode.kind==internal.cxxfe.instrum.ProgramNodeKind.SWITCH

                    candidateNodesInfo(end+1,:)={currNode,currNode.startLocation.lineNum};%#ok<AGROW>
                    caseSubNodes=currNode.subNodes.toArray();
                    caseSubNodes([caseSubNodes.kind]~=internal.cxxfe.instrum.ProgramNodeKind.SWITCH_CASE)=[];
                    if~isempty(caseSubNodes)
                        for ll=1:numel(caseSubNodes)
                            candidateNodesInfo(end+1,:)={caseSubNodes(ll).parentNode,caseSubNodes(ll).startLocation.lineNum};%#ok<AGROW>
                        end
                    end
                    if(currNode.subNodes.Size()~=0)&&(currNode.subNodes(1).kind==internal.cxxfe.instrum.ProgramNodeKind.OTHER_EXPR)
                        linkNodesToModelElem(idx,currNode.subNodes(1));
                    else
                        linkNodesToModelElem(idx,currNode);
                    end
                elseif(~(isa(h,'Stateflow.State')||isa(h,'Stateflow.Transition'))||...
                    ~any(ismember(allFiles,filePath)&ismember(allLineNums,currNode.startLocation.lineNum:currNode.endLocation.lineNum)))&&...
                    ismember(currNode.kind,[internal.cxxfe.instrum.ProgramNodeKind.IF...
                    ,internal.cxxfe.instrum.ProgramNodeKind.FOR...
                    ,internal.cxxfe.instrum.ProgramNodeKind.FOR_RANGE...
                    ,internal.cxxfe.instrum.ProgramNodeKind.WHILE...
                    ,internal.cxxfe.instrum.ProgramNodeKind.DO_WHILE...
                    ,internal.cxxfe.instrum.ProgramNodeKind.OTHER_STATEMENT])


                    candidateNodesInfo(end+1,:)={currNode,currNode.startLocation.lineNum};%#ok<AGROW>
                    subBlocks=currNode.subNodes.toArray();
                    subBlocks([subBlocks.kind]~=internal.cxxfe.instrum.ProgramNodeKind.BLOCK)=[];
                    if~isempty(subBlocks)
                        for ll=1:numel(subBlocks)
                            candidateNodesInfo(end+1,:)={subBlocks(ll),subBlocks(ll).startLocation.lineNum};%#ok<AGROW>
                        end
                    end
                    if(currNode.subNodes.Size()~=0)&&(currNode.subNodes(1).kind==internal.cxxfe.instrum.ProgramNodeKind.DECISION)
                        linkNodesToModelElem(idx,currNode.subNodes(1));
                    elseif(currNode.subNodes.Size()>=2)&&(currNode.subNodes(2).kind==internal.cxxfe.instrum.ProgramNodeKind.DECISION)

                        linkNodesToModelElem(idx,currNode.subNodes(2));
                    end
                elseif currNode.kind==internal.cxxfe.instrum.ProgramNodeKind.IF


                    subBlocks=currNode.subNodes.toArray();
                    subBlocks([subBlocks.kind]~=internal.cxxfe.instrum.ProgramNodeKind.BLOCK)=[];
                    if numel(subBlocks)==2
                        candidateNodesInfo(end+1:end+2,:)={subBlocks(1),subBlocks(1).startLocation.lineNum;...
                        subBlocks(2),subBlocks(2).startLocation.lineNum};
                    end
                end
                if currNode.covId~=0
                    instrPt=traceabilityData.getInstrumentationPoint(currNode.covId);
                    if isempty(instrPt)||~isa(instrPt.Container,'internal.cxxfe.instrum.DecisionPoint')
                        decCovPt=[];
                    else
                        decCovPt=instrPt.Container;
                    end
                    if isa(h,'Stateflow.Transition')&&~isempty(decCovPt)&&(instrPt==decCovPt.outcomes(1))

                        linkCovIdToModelElem(idx,currNode);
                        linkNodesToModelElem(idx,decCovPt.node.parentNode);
                    elseif isa(h,'Stateflow.Transition')&&~isempty(decCovPt)&&(instrPt==decCovPt.outcomes(2))

                        linkCovIdToModelElem(idx,currNode);
                    elseif isa(h,'Stateflow.State')&&~isempty(decCovPt)&&(instrPt==decCovPt.outcomes(2))&&...
                        ~any(ismember(allFiles,filePath)&ismember(allLineNums,decCovPt.node.startLocation.lineNum:(lineNum-1)))

                        linkCovIdToModelElem(idx,currNode);
                        linkNodesToModelElem(idx,decCovPt.node.parentNode);

                        linkNodesToModelElem(idx,getPreviousSiblingNodes(currNode));
                    elseif isa(h,'Stateflow.State')&&~isempty(decCovPt)&&(instrPt==decCovPt.outcomes(1))&&...
                        ~any(ismember(allFiles,filePath)&ismember(allLineNums,decCovPt.node.startLocation.lineNum:(lineNum-1)))

                        linkCovIdToModelElem(idx,currNode);

                        linkNodesToModelElem(idx,getPreviousSiblingNodes(currNode));
                    elseif currNode.kind==internal.cxxfe.instrum.ProgramNodeKind.SWITCH_CASE
                        linkCovIdToModelElem(idx,currNode);
                        if followsOtherLoc
                            linkNodesToModelElem(idx,currNode);
                        end
                    elseif isnumeric(h)&&strcmp(get_param(h,'Type'),'block')&&...
                        strcmp(get_param(h,'BlockType'),'SubSystem')&&~isempty(decCovPt)&&(instrPt==decCovPt.outcomes(1))

                        linkCovIdToModelElem(idx,currNode);
                        linkNodesToModelElem(idx,decCovPt.node.parentNode);
                    end
                    if~followsOtherLoc
                        linkNodesToModelElem(idx,currNode);
                    end
                end
                if~isSF&&workaroundG1357349
                    break
                end
                followsOtherLoc=false;

                isBreakDF=false;
                badIdx=false(size(candidateNodesInfo,1),1);
                for ll=1:size(candidateNodesInfo,1)
                    candidateParentNode=candidateNodesInfo{ll,1};
                    lineNum=candidateNodesInfo{ll,2};
                    currNode=getNextChildNode(candidateParentNode,lineNum);
                    if isempty(currNode)||...
                        any(ismember(allFiles,filePath)&ismember(allLineNums,lineNum:currNode.startLocation.lineNum))||...
                        (currNode.kind==internal.cxxfe.instrum.ProgramNodeKind.FCN_EXIT)
                        badIdx(ll)=true;
                    else
                        if isBreakDataFlowNode(currNode)

                            isBreakDF=true;
                            badIdx(ll)=true;
                        else
                            candidateNodesInfo{ll,2}=currNode.endLocation.lineNum+1;
                        end
                        break
                    end
                end
                candidateNodesInfo(badIdx,:)=[];
                if isempty(candidateNodesInfo)&&~isBreakDF
                    break
                end
            end
        end
    end



    covIds=cellfun(@(x)-x,covIds,'UniformOutput',false);

    mappedIdx=arrayfun(@(node)(node.mappedElements.Size()~=0),nodesTree);
    mappedNodes=nodesTree(mappedIdx);
    for ii=1:numel(mappedNodes)
        node=mappedNodes(ii);
        objs=node.mappedElements.toArray();
        [b,allIdx]=ismember({objs.uniqueId},SID);
        allIdx(~b)=[];
        for idx=allIdx(:)'
            linkNodesToModelElem(idx,node);



            if node.covId~=0
                if(node.kind==internal.cxxfe.instrum.ProgramNodeKind.FCN_ENTER)||...
                    (node.kind==internal.cxxfe.instrum.ProgramNodeKind.CONDITION)
                    covIds{idx}=unique([covIds{idx};-int64(node.covId)]);
                elseif node.isRelationalOpNode()
                    covIds{idx}=unique([covIds{idx};int64(node.covId)]);
                end
            end
        end
    end


    coveng=cvi.TopModelCov.getInstance(modelName);
    if~isempty(coveng)&&coveng.slccCov.sfcnCov.modelName2SFcnBlkH.isKey(modelName)
        sfcnBlkH=coveng.slccCov.sfcnCov.modelName2SFcnBlkH(modelName);
        for ii=1:numel(sfcnBlkH)
            blkH=sfcnBlkH(ii);
            functionName=SlCov.Utils.fixSFunctionName(get_param(blkH,'FunctionName'));
            if~coveng.slccCov.sfcnCov.sfcnName2Info.isKey(functionName)
                continue
            end
            codeTr=coveng.slccCov.sfcnCov.sfcnName2Info(functionName).codeTr;
            files=codeTr.getFilesInResults();
            sfcnFilesFullPaths=normalizePath({files.path});
            idx=ismember(fullPath,sfcnFilesFullPaths);

            SID{end+1}=Simulink.ID.getSID(blkH);%#ok<AGROW>
            if any(idx)
                covIds{end+1}=int64(nodesTree(idx,:).covId);%#ok<AGROW>
            else
                covIds{end+1}=zeros(0,1,'int64');%#ok<AGROW>
            end
            nodes{end+1}=nodesTree(idx);%#ok<AGROW>
        end
    end

    res=struct('SID',{SID},...
    'covIds',{covIds},...
    'nodes',{nodes},...
    'traceInfo',{origTraceInfo},...
    'inCodeTrace',{code2ModelRecords});

    badIdx=false(1,numel(SID));
    for ii=1:numel(SID)
        try

            if contains(SID{ii},"#")
                badIdx(ii)=true;
                continue
            end

            h=Simulink.ID.getHandle(SID{ii});
            if isempty(h)
                DAStudio.error('Simulink:utility:invalidSID',SID{ii},SID{ii});
            end
        catch ME

            if codeinstrumprivate('feature','disableErrorRecovery')
                rethrow(ME);
            end

            if(ii==1)||~isempty(res.covIds{ii})||~isempty(res.nodes{ii})
                fprintf(1,'%s\n',getString(message('Slvnv:codecoverage:CodeMappingGetSlHandleFailed',SID{ii})));
            end
            h=[];
        end

        if isa(h,'Stateflow.Event')

            h=h.getParent();
        elseif~isempty(h)&&isnumeric(h)&&strcmp(get_param(h,'Type'),'block')





            if ismember(get_param(h,'BlockType'),{'Merge','Scope','Outport','Inport','EnablePort'})||...
                strcmp(get_param(h,'DisableCoverage'),'on')
                h=get_param(get_param(h,'Parent'),'Handle');
            end
        end





        if~(isempty(h)||(isempty(res.covIds{ii})&&isempty(res.nodes{ii})))
            res.SID{ii}=Simulink.ID.getSID(h);
            idx=find(strcmp(res.SID{ii},res.SID(1:ii-1)),1,'first');
            if~isempty(idx)
                res.covIds{idx}=unique(cat(1,res.covIds{idx},res.covIds{ii}));
                res.nodes{idx}=unique(cat(1,res.nodes{idx},res.nodes{ii}));
                badIdx(ii)=true;
                badIdx(idx)=false;
                continue
            end
        end

        if(ii~=1)&&isempty(res.covIds{ii})&&isempty(res.nodes{ii})
            badIdx(ii)=true;
        end
    end

    res.SID(badIdx)=[];
    res.covIds(badIdx)=[];
    res.nodes(badIdx)=[];

end

function res=isBreakDataFlowNode(node)
    res=ismember(node.kind,[internal.cxxfe.instrum.ProgramNodeKind.GOTO...
    ,internal.cxxfe.instrum.ProgramNodeKind.CONTINUE...
    ,internal.cxxfe.instrum.ProgramNodeKind.BREAK...
    ,internal.cxxfe.instrum.ProgramNodeKind.RETURN]);
end

function res=getPreviousSiblingNodes(node)
    if isempty(node.parentNode)
        res=internal.cxxfe.instrum.ProgramNode.empty;
    else
        res=node.parentNode.subNodes.toArray();
        idx=find(node==res,1,'first');
        res(idx:end)=[];
    end
end

function res=getPreviousNode(node)
    res=getPreviousSiblingNodes(node);
    if isempty(res)
        res=node.parentNode;
    else
        res=res(end);
    end
end

function res=getNextChildNode(parentNode,startLineNum)
    res=parentNode.subNodes.toArray();
    res(arrayfun(@(node)isempty(node.startLocation),res))=[];
    if~isempty(res)
        startLocs=[res.startLocation];
        startLineNums=[startLocs.lineNum];
        res(startLineNums<startLineNum)=[];
        if~isempty(res)
            res(2:end)=[];
        end
    end
end



