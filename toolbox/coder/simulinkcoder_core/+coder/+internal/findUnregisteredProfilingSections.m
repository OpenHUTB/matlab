function findUnregisteredProfilingSections...
    (srcFilesList,headerFilesList,codeInstrRegistry)




    if isempty(codeInstrRegistry)

        assert(isequal(length(dir('profiling_info.mat')),1),...
        'Could not find profiling_info.mat file');
        profilingInfo=load('profiling_info.mat');
        fieldNames=fieldnames(profilingInfo);
        assert(isequal(find(strcmp(fieldNames,'componentRegistries')),1),...
        'The file profiling_info.mat does not have component registry');
        codeInstrRegistry=profilingInfo.componentRegistries;
        assert(isequal(length(codeInstrRegistry),1),...
        'There should be only one component registry');
        codeInstrRegistry=codeInstrRegistry{1};
    end

    if isequal(length(codeInstrRegistry.Probes),0)
        return;
    end

    probeTypes=[coder_profile_ProbeType.EXEC_TIME_PROBE,...
    coder_profile_ProbeType.FILTER_TIME_PROBE];
    for probeTypeIndex=1:length(probeTypes)
        probeType=probeTypes(probeTypeIndex);
        profNames=codeInstrRegistry.getCodeIdentifiers(probeType);
        if isempty(profNames)
            continue;
        end
        startSymbol=profNames.startMacroName;
        endSymbol=profNames.endMacroName;

        [srcFiles,~,startEndExpr]=...
        coder.internal.InstrProfilingInfo.buildRegexp...
        (srcFilesList,...
        headerFilesList,...
        startSymbol,...
        endSymbol);


        updateRegistry=false;

        sectionIdsMap=containers.Map('KeyType','uint64','ValueType','uint32');

        for i=1:length(srcFiles)
            if~isequal(length(dir(srcFiles{i})),1)
                continue;
            end

            content=fileread(srcFiles{i});

            [tokens,matchStart,~]=regexp...
            (content,startEndExpr,'tokens');

            if(isempty(tokens))
                continue;
            end

            [idUnique,~,~]=coder.internal.InstrProfilingInfo.matchStartEndProbes...
            (tokens,startSymbol);

            updateFile=false;
            for ii=1:length(idUnique)
                idUniqueNum=uint64(str2double(idUnique{ii}));
                present=codeInstrRegistry.probePresent(idUniqueNum);
                if~present

                    assert(isequal(sectionIdsMap.isKey(idUniqueNum),false),...
                    'The identification tags has already been used');

                    lSectionId=codeInstrRegistry.getNextSectionId;
                    lProfiledCodeName=sprintf('UNREGISTERED SECTION: %d',lSectionId);
                    newSectionId=codeInstrRegistry.requestSectionId...
                    (coder_profile_ProbeType.EXEC_TIME_PROBE,...
                    lProfiledCodeName,...
                    codeInstrRegistry.ComponentName);
                    assert(isequal(lSectionId,newSectionId),...
                    'The queried and added identification tags should be the same');
                    codeInstrRegistry.addIdentifier(...
                    coder_profile_ProbeType.EXEC_TIME_PROBE,...
                    newSectionId,...
                    lProfiledCodeName);

                    sectionIdsMap(idUniqueNum)=newSectionId;

                    updateFile=true;
                    updateRegistry=true;
                end

            end

            if updateFile
                newContentEndPos=1;
                oldContentEndPos=1;

                for j=1:length(tokens)
                    llength=matchStart(j)-1-oldContentEndPos;
                    newContent(newContentEndPos:newContentEndPos+llength)=...
                    content(oldContentEndPos:oldContentEndPos+llength);
                    newContentEndPos=newContentEndPos+llength;
                    oldContentEndPos=oldContentEndPos+llength;

                    sectionId=uint64(str2double(tokens{j}{2}));
                    present=isKey(sectionIdsMap,sectionId);
                    if present
                        newSectionId=sectionIdsMap(sectionId);
                        oldSectionIdLength=length(tokens{j}{2});
                        fncNameLength=length(tokens{j}{1})+1;
                        newContent(newContentEndPos:newContentEndPos+fncNameLength)=...
                        content(oldContentEndPos:oldContentEndPos+fncNameLength);
                        newContentEndPos=newContentEndPos+fncNameLength+1;
                        oldContentEndPos=oldContentEndPos+fncNameLength+oldSectionIdLength+1;
                        newSectionIdChar=int2str(newSectionId);
                        newContent(newContentEndPos:(newContentEndPos+length(newSectionIdChar)-1))=...
                        newSectionIdChar;
                        newContentEndPos=newContentEndPos+length(newSectionIdChar);
                    end
                end

                llength=length(content)-oldContentEndPos;
                newContent(newContentEndPos:newContentEndPos+llength)=...
                content(oldContentEndPos:oldContentEndPos+llength);

                fid=fopen(srcFiles{i},'w');
                fwrite(fid,newContent);
                fclose(fid);
            end
        end
    end

    if updateRegistry
        profilingInfo.componentRegistries={codeInstrRegistry};
        save('profiling_info.mat','-struct','profilingInfo');
    end
