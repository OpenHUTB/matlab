function profTraceInfo=codeInstrExtractWCETLocation(model,srcFiles,hdrFiles)





    assert(strcmp(get_param(model,'IsERTTarget'),'on'),'Wrong STF');


    [~,hdrFileNames]=fileparts(hdrFiles);
    idx=find(strcmp(model,hdrFileNames));
    assert(~isempty(idx),'No header file found');
    profilingDeclarationInfo=hdrFiles{idx};

    lProbeSites=i_getProbeLocation(model,srcFiles);
    lDeclarationsSite=i_get_declarations_site_in_header(profilingDeclarationInfo);

    profTraceInfo.ProbeSites=lProbeSites;
    profTraceInfo.DeclarationsSite=lDeclarationsSite;
    profTraceInfo.OriginalModelRef=model;
    profTraceInfo.FileNames=srcFiles;
    profTraceInfo.ProbeTypes=cell(1,length(lProbeSites));
    [profTraceInfo.ProbeTypes{:}]=deal(coder_profile_ProbeType.EXEC_TIME_PROBE);



    list=[profTraceInfo.ProbeSites(:).TraceId];
    offset=min(list)-1;
    if offset>0
        for i=1:length(profTraceInfo.ProbeSites)
            profTraceInfo.ProbeSites(i).TraceId=profTraceInfo.ProbeSites(i).TraceId-offset;
        end
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
