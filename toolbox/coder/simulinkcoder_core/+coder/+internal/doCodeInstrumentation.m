function lCodeInstrRegistry=doCodeInstrumentation...
    (lModelName,...
    lBuildDirectory,...
    lCodeGenerationId,...
    lFrontEndOptions,...
    lInstrSrcFolder,...
    lChecksumGranularityOn,...
    lChecksumGranularityOff)






    profilingTraceability=load('profilingTraceability.mat');
    profTraceInfo=profilingTraceability.profTraceInfo;
    assert(profilingTraceability.lCodeGenerationId==lCodeGenerationId,...
    'Profiling data must be for the most recent build')



    lOriginalModelRef=profTraceInfo.OriginalModelRef;

    cfgTmp=Simulink.fileGenControl('getConfig');
    lWordSize=get_param(lModelName,'TargetWordSize');
    lAnchorFolder=cfgTmp.CodeGenFolder;
    lCodeFolderRelative=lBuildDirectory(length(lAnchorFolder)+2:end);
    lCodeInstrRegistry=...
    coder.profile.TimeProbeComponentRegistry...
    (get_param(lOriginalModelRef,'Name'),...
    lOriginalModelRef,...
    lWordSize,...
    [],...
    get_param(lModelName,'MaxIdLength'),...
    lCodeFolderRelative);
    lCodeInstrRegistry.setFeatureChecksum('GranularityOn',lChecksumGranularityOn);
    lCodeInstrRegistry.setFeatureChecksum('GranularityOff',lChecksumGranularityOff);

    if coder.profile.private.edgCodeInstrumentation
        assert(~isempty(lFrontEndOptions),'Front-End Options are not valid');

        instrFiles=lFrontEndOptions.keys;
        lTraceInfo=lGetTraceability(lOriginalModelRef,instrFiles,profTraceInfo);
        lCallback='insertExecTimeProbe';
        lRemoveAnnotations=false;
        lTreatErrorsAsWarnings=false;
        coder.internal.runEDGInstrumentation(lFrontEndOptions,lInstrSrcFolder,...
        {lCodeInstrRegistry},lTraceInfo,lWordSize,lCallback,...
        lRemoveAnnotations,lTreatErrorsAsWarnings);
    else

        filteredProfTraceInfo=i_filterRTEFunctions(lBuildDirectory,profTraceInfo);


        filteredProfTraceInfo=i_filter_out_probes(lModelName,filteredProfTraceInfo);




        lProbesToKeep=coder.profile.findUniqueProbes(filteredProfTraceInfo.ProbeSites);
        filteredProfTraceInfo.ProbeSites=filteredProfTraceInfo.ProbeSites(lProbesToKeep);
        filteredProfTraceInfo.ProbeTypes=filteredProfTraceInfo.ProbeTypes(lProbesToKeep);

        lCodeInstrRegistry.insertProbes...
        (filteredProfTraceInfo,...
        filteredProfTraceInfo.DeclarationsSite,...
        lInstrSrcFolder);
    end

end


function lFilteredProfTraceInfo=i_filter_out_probes(model,lProfTraceInfo)






    lFilteredProfTraceInfo=lProfTraceInfo;

    realTimeSystemTgtFiles={'slrt.tlc','slrtert.tlc','xpctarget.tlc','xpctargetert.tlc'};
    systemTgtFile=get_param(model,'SystemTargetFile');

    lCoarseExecution=false;
    if~isempty(find(ismember(realTimeSystemTgtFiles,systemTgtFile),1))||...
        strcmpi(get_param(model,'CodeProfilingInstrumentation'),'coarse')
        lCoarseExecution=true;
    end

    lInstrumentSites=false(size(lFilteredProfTraceInfo.ModelTraceInfo));
    for i=1:length(lFilteredProfTraceInfo.ModelTraceInfo)
        blockTracingInfo=lFilteredProfTraceInfo.ModelTraceInfo(i);
        blockSIDs=blockTracingInfo.CallSiteSids;
        lDoProfile=true;
        lIsModelBlock=false;
        for j=1:length(blockSIDs)
            blockSID=blockSIDs{j};
            if isempty(blockSID)
                continue;
            end

            try
                [h,~,sidSpace]=Simulink.ID.getHandle(blockSID);
            catch ME %#ok<NASGU> 

                continue;
            end
            lIsInStateFlowBlock=isa(h,'Stateflow.Object');

            if lIsInStateFlowBlock
                lSidToCheck=sidSpace;
            else
                lSidToCheck=blockSID;
            end

            if~coder.profile.isBlockProfiled(lSidToCheck)
                lDoProfile=false;
                break;
            end

            if lCoarseExecution&&~lIsInStateFlowBlock
                try
                    blockType=get_param(blockSID,'BlockType');
                catch err
                    if strcmp(err.identifier,'Simulink:Commands:ParamUnknown')
                        continue;
                    else
                        rethrow(err);
                    end
                end

                if~lIsModelBlock&&(strcmp(blockType,'SubSystem')||strcmp(blockType,'ModelReference'))
                    lIsModelBlock=true;
                end
            end
        end
        lInstrumentSites(i)=lDoProfile&&(~lCoarseExecution||lIsModelBlock);
    end

    lProbeSiteTraces=[lFilteredProfTraceInfo.ProbeSites(:).TraceId];




    lFilterIdx=find(lInstrumentSites==false);
    for i=1:length(lFilterIdx)
        sites_idx=(lProbeSiteTraces==lFilterIdx(i));
        probeTypes_idx=lFilteredProfTraceInfo.ProbeTypes(sites_idx);
        if isempty(probeTypes_idx)
            continue;
        end
        cnt=sum(probeTypes_idx{:}==coder_profile_ProbeType.FILTER_TIME_PROBE);
        if cnt>0
            lInstrumentSites(lFilterIdx(i))=true;
        end
    end


    lProbeSiteTraces=[lFilteredProfTraceInfo.ProbeSites(:).TraceId];
    lFilterIdx=find(lInstrumentSites==true);
    lFilteredProbeSites=false(1,length(lFilteredProfTraceInfo.ProbeSites));
    for i=1:length(lFilterIdx)
        sites_idx=(lProbeSiteTraces==lFilterIdx(i));
        probeSites_idx=lFilteredProfTraceInfo.ProbeSites(sites_idx);
        if isempty(probeSites_idx)
            continue;
        end
        [probeSites_idx(:).TraceId]=deal(i);
        lFilteredProfTraceInfo.ProbeSites(sites_idx)=probeSites_idx;
        lFilteredProbeSites(sites_idx)=true;
    end

    lFilteredProfTraceInfo.ModelTraceInfo=lFilteredProfTraceInfo.ModelTraceInfo(lInstrumentSites);
    lFilteredProfTraceInfo.ProbeSites=lFilteredProfTraceInfo.ProbeSites(lFilteredProbeSites);
    lFilteredProfTraceInfo.ProbeTypes=lFilteredProfTraceInfo.ProbeTypes(lFilteredProbeSites);
end


function lTraceInfo=lGetTraceability(modelname,instrFiles,profTraceInfo)




    builder=coder.trace.getTraceInfo(modelname);
    if~isempty(builder)&&isempty(builder.sourceSubsysSID)
        lCodeReusableSubSystems=lCreateReusableCodeList(modelname);
    else

        lCodeReusableSubSystems=containers.Map('KeyType','char','ValueType','any');
    end
    lTraceInfo=containers.Map('KeyType','char','ValueType','any');
    for i=1:length(instrFiles)
        entry=[];
        if~isempty(builder)&&sum(strcmp(builder.files,instrFiles{i}))>0

            lCode2ModelRecords=builder.getCodeToModelRecords(instrFiles{i});
            if~isempty(lCode2ModelRecords)
                codenameList=cell(1,0);
                lineNumberList=cell(1,0);
                sidList=cell(1,0);
                for j=1:length(lCode2ModelRecords)
                    tmp=lCode2ModelRecords(j);



                    if~lIsPotentialFunctionCall(builder,tmp)
                        continue;
                    end


                    [lSid,h]=lGetMostAccurateHandleAndSid(builder,instrFiles{i},tmp);
                    if isempty(h)
                        continue;
                    end




                    if strcmpi(get_param(modelname,'CodeProfilingInstrumentation'),'coarse')


                        if~isnumeric(h)
                            continue;
                        end
                        blockType=get_param(h,'BlockType');
                        if~strcmp(blockType,'SubSystem')&&~strcmp(blockType,'ModelReference')
                            continue;
                        end
                    end



                    if~isnumeric(h)
                        lSid=Simulink.ID.getSimulinkParent(lSid);
                    end


                    if~coder.profile.isBlockProfiled(lSid)
                        continue;
                    end


                    lSid={lSid};




                    if isnumeric(h)&&strcmp(get_param(h,'BlockType'),'SubSystem')&&...
                        strcmp(get_param(h,'TreatAsAtomicUnit'),'on')&&...
                        strcmp(get_param(h,'RTWSystemCode'),'Reusable function')
                        functionName=get_param(h,'Name');
                        if lCodeReusableSubSystems.isKey(functionName)
                            lSid=lCodeReusableSubSystems(functionName);
                        end
                    end


                    finalSidList=cell(1,numel(lSid));
                    for idx=1:length(lSid)
                        if~isempty(builder.sourceSubsysSID)
                            finalSidList{idx}=Simulink.ID.getSubsystemBuildSID(lSid{idx},builder.sourceSubsysSID);
                        else
                            finalSidList{idx}=lSid{idx};
                        end
                    end


                    if~isempty(finalSidList)
                        codenameList{end+1}=tmp.token.token;%#ok<AGROW>
                        lineNumberList{end+1}=tmp.token.line;%#ok<AGROW>
                        sidList{end+1}=finalSidList;%#ok<AGROW>
                    end
                end
                entry=struct('CallSiteName',codenameList,...
                'CallSiteLine',lineNumberList,...
                'CallSiteSID',sidList);
            end
        end
        if isempty(builder)

            fileIdx=find(strcmp(profTraceInfo.FileNames,instrFiles{i}),1);
            if~isempty(fileIdx)
                idxs=[profTraceInfo.ProbeSites.FileNameIdx]==fileIdx;
                probesInFile=profTraceInfo.ProbeSites(idxs);
                if~isempty(probesInFile)
                    codenameList=cell(1,0);
                    lineNumberList=cell(1,0);
                    sidList=cell(1,0);
                    for j=1:length(probesInFile)
                        lSid=profTraceInfo.ModelTraceInfo(probesInFile(j).TraceId).CallSiteSids;
                        if~isempty(lSid{:})
                            codenameList{end+1}=profTraceInfo.ModelTraceInfo(probesInFile(j).TraceId).CodeName;%#ok<AGROW>
                            lineNumberList{end+1}=probesInFile(j).StartLineNo;%#ok<AGROW>
                            sidList{end+1}=lSid;%#ok<AGROW>
                        end
                    end
                    entry=struct('CallSiteName',codenameList,...
                    'CallSiteLine',lineNumberList,...
                    'CallSiteSID',sidList);
                end
            end
        end
        lTraceInfo(instrFiles{i})=entry;
    end
    clear builder;
end

function[profTraceInfo,listRTE]=i_filterRTEFunctions(buildDir,profTraceInfo)
    listRTE=[];

    lSrcFile=fullfile(buildDir,'stub','profileInfo.txt');
    if exist(lSrcFile,'file')==2
        fid=fopen(lSrcFile);
        finishup=onCleanup(@()fclose(fid));

        while~feof(fid)
            line_ex=fgetl(fid);
            if isempty(line_ex)
                continue;
            end
            switch line_ex(1)
            case '#'

            case{'-','+'}
                listRTE{end+1}=line_ex(2:end);%#ok<AGROW>
            otherwise
                assert(false,'Line not valid in profileInfo.txt');
                break;
            end
        end
    end



    traceIds=[profTraceInfo.ProbeSites.TraceId];
    for i=1:length(traceIds)
        codeName=profTraceInfo.ModelTraceInfo(traceIds(i)).CodeName;
        if~isempty(codeName)&&any(strcmp(codeName,listRTE))
            profTraceInfo.ProbeTypes{i}=coder_profile_ProbeType.FILTER_TIME_PROBE;
        end
    end


end



function lCodeReusableSubSystems=lCreateReusableCodeList(modelname)
    lCodeReusableSubSystems=containers.Map('KeyType','char','ValueType','any');
    list=find_system(modelname,'MatchFilter',@Simulink.match.activeVariants,'BlockType','SubSystem');
    for i=1:length(list)
        sid=Simulink.ID.getSID(list{i});


        if~isempty(sid)&&~coder.profile.isBlockProfiled(sid)
            continue;
        end

        h=Simulink.ID.getHandle(sid);
        if isnumeric(h)&&strcmp(get_param(h,'TreatAsAtomicUnit'),'on')&&...
            strcmp(get_param(h,'RTWSystemCode'),'Reusable function')
            functionName=get_param(h,'Name');
            if~lCodeReusableSubSystems.isKey(functionName)
                lCodeReusableSubSystems(functionName)=cell(1,0);
            end
            l=lCodeReusableSubSystems(functionName);
            l{end+1}=sid;%#ok<AGROW>
            lCodeReusableSubSystems(functionName)=l;
        end
    end
end






function lToKeep=lIsPotentialFunctionCall(traceInfo,tkn)
    lToKeep=false;


    if isempty(tkn.modelElems)
        return;
    end



    lNumValidCharacters=length(strfind(tkn.token.token,'_'))+...
    sum(isstrprop(tkn.token.token,'alphanum'));
    lValidFirstCharacter=isstrprop(tkn.token.token(1),'digit');
    if(~isempty(lValidFirstCharacter)&&lValidFirstCharacter)||...
        lNumValidCharacters~=length(tkn.token.token)
        return;
    end


    for idx=1:length(tkn.modelElems)
        hSid=lRestoreSID(traceInfo,tkn.modelElems{idx});
        try
            hh=Simulink.ID.getHandle(hSid);
        catch ME
            if strcmp(ME.identifier,'Simulink:utility:SIDSyntaxError')
                return;
            else
                rethrow(ME);
            end
        end
        if~isempty(hh)&&isnumeric(hh)&&...
            strcmp(get_param(hh,'BlockType'),'TriggerPort')&&...
            ~strcmp(get_param(hh,'TriggerType'),'Function-call')
            return;
        end
    end

    lToKeep=true;
end





function[rSid,rHandle]=lGetMostAccurateHandleAndSid(aTraceInfo,aInstrFile,tkn)
    rHandle=[];
    rSid=[];

    if length(tkn.modelElems)==1

        lSid=tkn.modelElems{end};
    else
        lTkn=aTraceInfo.getCodeToModelSingle(aInstrFile,tkn.token.line,tkn.token.beginCol);
        if isempty(lTkn.modelElems)
            return;
        end
        lSid=lTkn.modelElems{1};
    end
    lSid=lRestoreSID(aTraceInfo,lSid);



    h=Simulink.ID.getHandle(lSid);
    if isempty(h)
        return;
    end

    rSid=lSid;
    rHandle=h;
end

function regularSid=lRestoreSID(traceInfo,sid)
    regularSid=sid;
    if~isstrprop(regularSid(1),'digit')
        return;
    end
    pos=strfind(regularSid,':');
    if isempty(pos)
        return;
    end
    pos=pos(1);
    prefixId=str2double(extractBefore(regularSid,pos));
    stem=extractAfter(regularSid,pos);
    regularSid=[traceInfo.sidPrefixes{prefixId+1},':',stem];
end


