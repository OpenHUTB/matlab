function profTraceInfo=codeInstrTraceabilityUpdate...
    (model,lTargetType,srcFiles,...
    profilingInstrumentationData,profilingDeclarationInfo)







    lTrace=get_param(model,'ExecTimeTraceabilityProbes');
    set_param(model,'ExecTimeTraceabilityProbes',[]);

    lExecTimeTraceInfo=lTrace.exportExecTimeTraceInfo;

    [rightClickSubsysName,originalModelRef,lSourceSubsystemHandle]=...
    i_getRightClickBuildInfo(model,lTargetType);
    profTraceInfo.OriginalModelRef=originalModelRef;

    [lExecTimeTraceInfo,lRightClickSIDMap]=i_update_trace_info...
    (lExecTimeTraceInfo,rightClickSubsysName,lSourceSubsystemHandle);

    if strcmp(get_param(model,'IsERTTarget'),'on')
        lProbeSites=i_getProbeLocation(model,srcFiles);
        lDeclarationsSite=i_get_declarations_site_in_header(profilingDeclarationInfo);
    else
        lProbeSites=coder.profile.analyzeProfilingTraceInfo...
        (Simulink.ExecTimeTraceabilityProbes.BlockStartSymbol,...
        Simulink.ExecTimeTraceabilityProbes.BlockEndSymbol,...
        profilingInstrumentationData.traceInfoProbes,srcFiles);

        lDeclarationsSite=i_get_declarations_site(profilingInstrumentationData.traceInfoDeclarations);
    end




    if isempty(rightClickSubsysName)
        lExecTimeTraceInfo=i_detect_code_reuse_in_blocks(model,lExecTimeTraceInfo);
    end

    profTraceInfo.FileNames=srcFiles;
    profTraceInfo.ModelTraceInfo=lExecTimeTraceInfo;
    profTraceInfo.ProbeSites=lProbeSites;

    profTraceInfo.DeclarationsSite=lDeclarationsSite;

    lProbeTypes=cell(size(lProbeSites));
    [lProbeTypes{1:length(lProbeTypes)}]=deal(coder_profile_ProbeType.EXEC_TIME_PROBE);
    profTraceInfo.ProbeTypes=lProbeTypes;


    if lRightClickSIDMap.Count>0
        profTraceInfo.RightClickSIDMap=lRightClickSIDMap;
    end


    function lDeclarationsSite=i_get_declarations_site_in_header(lHeaderFile)
        lDeclarationsSite=[];







        strToFind={['/* ',Simulink.ExecTimeTraceabilityProbes.DeclarationsPlaceholderSymbol,' */'],...
        ['// ',Simulink.ExecTimeTraceabilityProbes.DeclarationsPlaceholderSymbol],...
        '#endif'};
        cnt=fileread(lHeaderFile);

        for i=1:length(strToFind)
            position=strfind(cnt,strToFind{i});
            if~isempty(position)
                lDeclarationsSite=struct('CharNo',position(end),'FileName',lHeaderFile);
                break;
            end
        end
        assert(~isempty(lDeclarationsSite),'Header file not found to add profiling declaration');


        function lDeclarationsSite=i_get_declarations_site(traceInfoDeclarationsSite)

            lDeclarationsSiteInfo=traceInfoDeclarationsSite.getModelToCodeRecords;
            tracedFiles=traceInfoDeclarationsSite.files';
            fIndice=[lDeclarationsSiteInfo(1).tokens.fileIdx];
            assert(length(lDeclarationsSiteInfo)==1,...
            'Declarations site for code instrumentation must be found and must be unique');
            lineNos={lDeclarationsSiteInfo(1).tokens.line};
            colNos={lDeclarationsSiteInfo(1).tokens.beginCol};
            hdrFiles=tracedFiles(fIndice+1);
            hdrFile=hdrFiles{1};
            startIndex=coder.profile.lineAndColToChar...
            (lineNos,colNos,hdrFile);
            lDeclarationsSite=struct('CharNo',startIndex{1},'FileName',hdrFile);


            function[rightClickSubsysName,originalModelRef,lSourceSubsystemHandle]=...
                i_getRightClickBuildInfo(model,lTargetType)

                lSourceSubsystemHandle=[];
                rightClickSubsysName='';
                originalModelRef=model;
                if strcmp(lTargetType,'NONE')
                    lSourceSubsystemHandle=rtwprivate...
                    ('getSourceSubsystemHandle',model);
                    if~isempty(lSourceSubsystemHandle)
                        originalSubsysSid=...
                        get_param(lSourceSubsystemHandle,'sid');
                        origModelName=get_param(bdroot(lSourceSubsystemHandle),'Name');
                        originalModelRef=[origModelName,':',originalSubsysSid];
                        rightClickSubsysName=get_param(lSourceSubsystemHandle,'Name');
                    end
                end

                function hParents=i_getParents(hModel,blockHandles)

                    hParentBlocks=get_param(blockHandles,'parent');
                    hEmptyBlocks=strcmp(hParentBlocks,'');
                    if any(hEmptyBlocks)

                        hParentBlocks(hEmptyBlocks)=[];
                    end
                    hParents=get_param(hParentBlocks,'handle');
                    if iscell(hParents)

                        hParents=cell2mat(hParents);
                    end


                    hParents=hParents(hParents~=hModel);



                    function i_right_click_sid_map_fill_gaps(lRightClickSIDMap,lSourceSubsystemHandle)

                        temporaryModelSIDs=lRightClickSIDMap.keys;


                        [temporaryModelHandles,~,sidSpaces]=Simulink.ID.getHandle(temporaryModelSIDs);
                        for i=1:length(temporaryModelHandles)
                            if isa(temporaryModelHandles{i},'Stateflow.Object')
                                temporaryModelHandles{i}=sidSpaces{i};
                            end
                        end
                        temporaryModelHandles=cell2mat(temporaryModelHandles);
                        hModel=get_param(bdroot(temporaryModelHandles(1)),'handle');

                        hParents=i_getParents(hModel,temporaryModelHandles);
                        hAncestors=hParents;

                        while~isempty(hParents)
                            hParents=i_getParents(hModel,hParents);
                            hAncestors=unique([hAncestors(:);hParents(:)]);
                        end

                        temporaryIntermediateHandles=setdiff(hAncestors,temporaryModelHandles);
                        temporaryIntermediateSIDs=Simulink.ID.getSID(temporaryIntermediateHandles);
                        if~iscell(temporaryIntermediateSIDs)
                            temporaryIntermediateSIDs={temporaryIntermediateSIDs};
                        end

                        for i=1:length(temporaryIntermediateSIDs)
                            lTemporaryIntermediateSID=temporaryIntermediateSIDs{i};
                            lOriginalIntermediateSID=Simulink.ID.getSubsystemBuildSID...
                            (lTemporaryIntermediateSID,lSourceSubsystemHandle);
                            lRightClickSIDMap(lTemporaryIntermediateSID)=lOriginalIntermediateSID;
                        end


                        function[lExecTimeTraceInfoNew,lRightClickSIDMap]=i_update_trace_info...
                            (lExecTimeTraceInfo,rightClickSubsysName,lSourceSubsystemHandle)


                            lExecTimeTraceInfoNew=struct('CodeName',cell(size(lExecTimeTraceInfo)),...
                            'CallSiteSids',cell(size(lExecTimeTraceInfo)),...
                            'CallSiteNames',cell(size(lExecTimeTraceInfo)));



                            lRightClickSIDMap=containers.Map;

                            for i=1:length(lExecTimeTraceInfo)
                                sid=lExecTimeTraceInfo(i).Sid;
                                lCallSiteSids=lExecTimeTraceInfo(i).CallSiteSids;
                                if~isempty(lCallSiteSids)
                                    [h,~,sidSpace]=Simulink.ID.getHandle(sid);
                                    if isa(h,'Stateflow.Object')
                                        parentSid=get_param(sidSpace,'sid');
                                        sid=[strtok(sid,':'),':',parentSid];
                                    end
                                    idx1=strcmp(sid,lCallSiteSids);
                                    assert(sum(idx1)==1,'Must be exactly one match for primary call site');

                                    [~,sortIdx]=sort(~idx1);
                                    lCallSiteSids=lCallSiteSids(sortIdx);
                                else
                                    lCallSiteSids={sid};
                                end


                                if~isempty(rightClickSubsysName)
                                    for ii2=1:length(lCallSiteSids)
                                        lTemporarySID=lCallSiteSids{ii2};
                                        if isempty(lTemporarySID)

                                            continue
                                        end
                                        lOriginalModelSID=Simulink.ID.getSubsystemBuildSID...
                                        (lTemporarySID,lSourceSubsystemHandle);
                                        if~slfeature('RightClickBuild')
                                            lCallSiteSids{ii2}=lOriginalModelSID;
                                        end


                                        lRightClickSIDMap(lTemporarySID)=lOriginalModelSID;
                                    end
                                end
                                lCallSiteNames=repmat({''},size(lCallSiteSids));
                                for k=1:numel(lCallSiteSids)
                                    if~isempty(lCallSiteSids{k})
                                        try
                                            [h,~,sidSpace]=Simulink.ID.getHandle(lCallSiteSids{k});
                                            if isa(h,'Stateflow.Object')
                                                if isprop(h,'Name')
                                                    lCallSiteNames{k}=h.Name;
                                                else
                                                    lCallSiteNames{k}=get_param(sidSpace,'Name');
                                                end
                                            else
                                                lCallSiteNames{k}=get_param(h,'Name');
                                            end
                                        catch e




                                            if~any(strcmp(e.identifier,...
                                                {'Simulink:Commands:InvSimulinkObjectName',...
                                                'Simulink:utility:objectDestroyed'}))

                                                rethrow(e);
                                            end
                                        end
                                    end
                                end
                                lExecTimeTraceInfoNew(i).CodeName=lExecTimeTraceInfo(i).CodeName;
                                lExecTimeTraceInfoNew(i).CallSiteSids=lCallSiteSids;
                                lExecTimeTraceInfoNew(i).CallSiteNames=lCallSiteNames;

                                if lRightClickSIDMap.Count>0


                                    i_right_click_sid_map_fill_gaps(lRightClickSIDMap,lSourceSubsystemHandle);
                                end

                            end



                            function lExtExecTimeTraceInfo=i_detect_code_reuse_in_blocks(model,lExecTimeTraceInfo)

                                lReusedSubsystems=i_detect_reusable_subsystems(lExecTimeTraceInfo);




                                for i=1:length(lExecTimeTraceInfo)
                                    elem=lExecTimeTraceInfo(i);
                                    lNumSids=length(elem.CallSiteSids);
                                    if lNumSids~=1||isempty(elem.CallSiteSids{1})

                                        continue;
                                    end
                                    sid=elem.CallSiteSids{1};
                                    [h,~,sidSpace]=Simulink.ID.getHandle(sid);
                                    if isa(h,'Stateflow.Object')
                                        sid=sidSpace;
                                    end
                                    if strcmpi(model,get_param(sid,'name'))

                                        continue;
                                    end
                                    lBlockType=get_param(sid,'blocktype');
                                    if any(strcmpi(lBlockType,'subsystem'))


                                        continue;
                                    end


                                    originalCallSiteName=elem.CallSiteNames{1};

                                    res=i_compute_missing_sids(model,sid,lExecTimeTraceInfo,lReusedSubsystems);
                                    if~isempty(res)
                                        lExecTimeTraceInfo(i).CallSiteSids=[lExecTimeTraceInfo(i).CallSiteSids,res];
                                        lExtraCallSiteName=repmat({originalCallSiteName},1,length(res));
                                        lExecTimeTraceInfo(i).CallSiteNames=[lExecTimeTraceInfo(i).CallSiteNames,lExtraCallSiteName];
                                    end
                                end
                                lExtExecTimeTraceInfo=lExecTimeTraceInfo;



                                function res=i_compute_missing_sids(model,blockSID,lExecTimeTraceInfo,reusedSubsystems)



                                    res=[];







                                    lParent=get_param(blockSID,'parent');
                                    while~isempty(lParent)&&~strcmpi(model,lParent)

                                        lParentType=get_param(lParent,'blocktype');
                                        lParentSid=get_param(lParent,'sid');
                                        if strcmpi(lParentType,'subsystem')&&~isempty(lParentSid)
                                            lFullParentSid=[model,':',lParentSid];

                                            for i=1:length(lExecTimeTraceInfo)
                                                potentialParent=lExecTimeTraceInfo(i);
                                                if length(potentialParent.CallSiteSids)>1&&...
                                                    any(strcmpi(potentialParent.CallSiteSids,lFullParentSid))

                                                    for j=1:length(potentialParent.CallSiteSids)
                                                        if~strcmpi(lFullParentSid,potentialParent.CallSiteSids(j))
                                                            res{end+1}=i_compute_new_sid(model,blockSID,...
                                                            lParent,potentialParent.CallSiteSids{j});%#ok<AGROW>
                                                        end
                                                    end


                                                    return;
                                                end
                                            end
                                        end
                                        lParent=get_param(lParent,'parent');
                                    end







                                    lParent=get_param(blockSID,'parent');
                                    lParentSid=[model,':',get_param(lParent,'sid')];
                                    for i=1:length(reusedSubsystems)
                                        if any(strcmp(lParentSid,reusedSubsystems{i}))
                                            for j=1:length(reusedSubsystems{i})
                                                if~strcmp(lParentSid,reusedSubsystems{i}{j})
                                                    res{end+1}=i_compute_new_sid(model,blockSID,lParent,...
                                                    reusedSubsystems{i}{j});%#ok<AGROW>
                                                end
                                            end
                                            break;
                                        end
                                    end



                                    function newSID=i_compute_new_sid(model,currentSID,parentPath,newParentSID)




                                        fullName=Simulink.ID.getFullName(currentSID);
                                        lOriginalBlockPath=Simulink.BlockPath(fullName);
                                        lOriginalBlockPath=lOriginalBlockPath.getBlock(1);

                                        fullName=Simulink.ID.getFullName(newParentSID);
                                        lNewParentPath=Simulink.BlockPath(fullName);
                                        lNewParentPath=lNewParentPath.getBlock(1);

                                        lNewBlockPath=strrep(lOriginalBlockPath,parentPath,lNewParentPath);

                                        newSID=[model,':',get_param(lNewBlockPath,'sid')];



                                        function lReusedSubsystems=i_detect_reusable_subsystems(lExecTimeTraceInfo)







                                            lReusedSubsystems={};

                                            toConsider=false(1,length(lExecTimeTraceInfo));





                                            for i=1:length(lExecTimeTraceInfo)
                                                trace=lExecTimeTraceInfo(i);
                                                if length(trace.CallSiteSids)==1&&~isempty(trace.CallSiteSids{1})
                                                    [h,~,sidSpace]=Simulink.ID.getHandle(trace.CallSiteSids{1});
                                                    if isa(h,'Stateflow.Object')
                                                        h=sidSpace;
                                                    end
                                                    if strcmpi(get_param(h,'blocktype'),'subsystem')&&...
                                                        strcmpi(get_param(h,'RTWSystemCode'),'Reusable function')&&...
                                                        strcmpi(get_param(h,'TreatAsAtomicUnit'),'on')
                                                        toConsider(i)=true;
                                                    end
                                                end
                                            end
                                            lReducedExecTimeTraceInfo=lExecTimeTraceInfo(toConsider);





                                            alreadyDone=false(1,length(lReducedExecTimeTraceInfo));
                                            for i=1:length(lReducedExecTimeTraceInfo)-1
                                                if alreadyDone(i)
                                                    continue
                                                end
                                                currentTrace={};
                                                trace1=lReducedExecTimeTraceInfo(i);
                                                for j=i+1:length(lReducedExecTimeTraceInfo)
                                                    if alreadyDone(j)
                                                        continue
                                                    end
                                                    trace2=lReducedExecTimeTraceInfo(j);
                                                    if strcmp(trace1.CodeName,trace2.CodeName)
                                                        currentTrace{end+1}=trace2.CallSiteSids{1};%#ok<AGROW>
                                                        alreadyDone(j)=true;
                                                    end
                                                end
                                                if~isempty(currentTrace)
                                                    currentTrace{end+1}=trace1.CallSiteSids{1};%#ok<AGROW>
                                                    lReusedSubsystems{end+1}=currentTrace;%#ok<AGROW>
                                                end
                                            end

                                            function lProbeSites=i_getProbeLocation(lModel,lSourceFiles)


                                                traceInfo=coder.trace.getTraceInfo(lModel);
                                                assert(~isempty(traceInfo),'Error while getting TraceInfo');
                                                tracedFiles=traceInfo.files;
                                                lTokens=traceInfo.getTraceRecordsForCode;
                                                lProbeSites=struct('FileNameIdx',{},...
                                                'TraceId',{},...
                                                'StartFcnCharNo',{},...
                                                'StartLineNo',{},...
                                                'StartColNo',{},...
                                                'EndFcnCharNo',{},...
                                                'EndLineNo',{},...
                                                'EndColNo',{}...
                                                );

                                                for idFile=1:length(lSourceFiles)
                                                    srcFile=lSourceFiles{idFile};

                                                    lineStart=[];
                                                    colStart=[];
                                                    lineEnd=[];
                                                    colEnd=[];
                                                    ids=[];
                                                    instrString=Simulink.ExecTimeTraceabilityProbes.CustomTraceIdentifier;







                                                    for i=1:length(lTokens)
                                                        tkn=lTokens(i).token;
                                                        customTraces=lTokens(i).customTrace;
                                                        customTraceNames={customTraces(:).name};
                                                        match=strcmp(instrString,customTraceNames);
                                                        customTraceProf=customTraces(match);
                                                        for j=1:length(customTraceProf)
                                                            customTrace=customTraceProf(j);
                                                            if any(strcmp(tracedFiles{tkn.fileIdx+1},srcFile))
                                                                lineStart(end+1)=tkn.line;%#ok<AGROW>
                                                                colStart(end+1)=tkn.beginCol;%#ok<AGROW>
                                                                lineEnd(end+1)=tkn.line;%#ok<AGROW>
                                                                colEnd(end+1)=tkn.endCol;%#ok<AGROW>
                                                                ids(end+1)=str2num(customTrace.value);%#ok<ST2NM,AGROW>
                                                            end
                                                        end
                                                    end
                                                    if isempty(ids)
                                                        continue;
                                                    end







                                                    uniqueIds=unique(ids);
                                                    posStart=localLineAndColToChar(lineStart,colStart,srcFile);
                                                    posEnd=localLineAndColToChar(lineEnd,colEnd,srcFile);

                                                    for id=1:length(uniqueIds)
                                                        actId=uniqueIds(id);
                                                        tokenIds=find(ids==actId);
                                                        [st,startId]=min(posStart(tokenIds));
                                                        [en,endId]=max(posEnd(tokenIds));

                                                        s=struct('FileNameIdx',idFile,...
                                                        'TraceId',actId,...
                                                        'StartFcnCharNo',st,...
                                                        'StartLineNo',lineStart(tokenIds(startId)),...
                                                        'StartColNo',colStart(tokenIds(startId)),...
                                                        'EndFcnCharNo',en,...
                                                        'EndLineNo',lineEnd(tokenIds(endId)),...
                                                        'EndColNo',colEnd(tokenIds(endId))...
                                                        );
                                                        lProbeSites(end+1)=s;%#ok<AGROW>
                                                    end
                                                end

                                                function charNos=localLineAndColToChar(lineNos,colNos,srcFile)

                                                    srcFileContent=fileread(srcFile);
                                                    newLineCharNosMap=regexp(srcFileContent,'^.','lineanchors');


                                                    charNos=zeros(size(lineNos));
                                                    for i=1:length(lineNos(:))
                                                        charNos(i)=newLineCharNosMap(lineNos(i))+colNos(i)-1;
                                                    end


