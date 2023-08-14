function buildInfoTimerUpdate...
    (buildInfo,timer,extraSrcFiles,extraHdrFiles,addSources)




    [srcFiles,isHeader,isGenerated,includePaths,srcPaths]=...
    i_getTimerSources(timer,extraSrcFiles,extraHdrFiles);

    if addSources
        buildInfoGroup='SkipForInTheLoop';
        addedModules=cell(size(srcFiles));
        for i=1:length(srcFiles)
            srcFile=srcFiles{i};
            if~isHeader(i)
                buildInfo.addSourceFiles(srcFile,'',buildInfoGroup);
                addedModules{i}=srcFile;
                isHeader(i)=false;
            else
                buildInfo.addIncludeFiles(srcFile,'',buildInfoGroup);
            end
        end

        for i=1:length(includePaths)
            buildInfo.addIncludePaths(includePaths{i})
        end
        for i=1:length(srcPaths)
            buildInfo.addSourcePaths(srcPaths{i});
        end



        if~isempty(timer)&&~isempty(timer.getLinkFlags)
            buildInfo.addLinkFlags(timer.getLinkFlags);
        end


        if~isempty(timer)&&~isempty(timer.getCompileFlags)
            buildInfo.addCompileFlags(timer.getCompileFlags,'OPTS');
        end

    else
        numSrc=length(buildInfo.Src.Files);
        srcFileNames=cell(numSrc,1);
        for i=1:numSrc
            srcFileNames{i}=buildInfo.Src.Files(i).FileName;
        end
        numHeader=length(buildInfo.Inc.Files);
        headerFileNames=cell(numHeader,1);
        for i=1:numHeader
            headerFileNames{i}=buildInfo.Inc.Files(i).FileName;
        end
        [~,~,incRemoveIdx]=intersect(srcFiles,headerFileNames);
        [~,~,srcRemoveIdx]=intersect(srcFiles,srcFileNames);
        incKeepIdx=true(size(headerFileNames));
        srcKeepIdx=true(size(srcFileNames));
        incKeepIdx(incRemoveIdx)=false;
        srcKeepIdx(srcRemoveIdx)=false;
        buildInfo.Src.Files=buildInfo.Src.Files(srcKeepIdx);
        buildInfo.Inc.Files=buildInfo.Inc.Files(incKeepIdx);


        for i=1:length(srcFiles)
            if isGenerated(i)
                if~isempty(dir(srcFiles{i}))
                    delete(srcFiles{i});
                end
            end
        end
    end


    function[files,isHeader,isGenerated,includePaths,srcPaths]=...
        i_getTimerSources(timer,extraSrcFiles,extraHdrFiles)


        files={};
        isHeader=false(0,1);
        isGenerated=false(0,1);
        includePaths={};
        srcPaths={};

        if~isempty(timer)
            timerSrc=timer.getTimerSource;
            if~isempty(timerSrc)
                files{end+1}=timerSrc;
                isHeader(end+1)=false;
                isGenerated(end+1)=false;
            end
            timerHeader=timer.getTimerHeader;
            if~isempty(timerHeader)
                files{end+1}=timerHeader;
                isHeader(end+1)=true;
                isGenerated(end+1)=false;
            end
            sourceFiles=timer.getTimerAdditionalSources;
            for i=1:length(sourceFiles)
                files{end+1}=sourceFiles{i};%#ok<AGROW>
                isHeader(end+1)=false;%#ok<AGROW>
                isGenerated(end+1)=false;%#ok<AGROW>
            end
            headerFiles=timer.getTimerAdditionalHeaders;
            for i=1:length(headerFiles)
                files{end+1}=headerFiles{i};%#ok<AGROW>
                isHeader(end+1)=true;%#ok<AGROW>
                isGenerated(end+1)=false;%#ok<AGROW>
            end

            includePaths=timer.getTimerIncludePaths;
            srcPaths=timer.getSourcePaths;
        end

        if~isempty(extraSrcFiles)
            for i=1:length(extraSrcFiles)
                extraSrcFile=extraSrcFiles{i};
                [p,f,e]=fileparts(extraSrcFile);
                files{end+1}=[f,e];%#ok<AGROW>
                isHeader(end+1)=false;%#ok<AGROW>
                isGenerated(end+1)=true;%#ok<AGROW>
                srcPaths(end+1)={p};%#ok<AGROW>
            end
        end
        if~isempty(extraHdrFiles)
            for i=1:length(extraHdrFiles)
                extraHdrFile=extraHdrFiles{i};
                [p,f,e]=fileparts(extraHdrFile);
                files{end+1}=[f,e];%#ok<AGROW>
                isHeader(end+1)=true;%#ok<AGROW>
                isGenerated(end+1)=true;%#ok<AGROW>
                includePaths(end+1)={p};%#ok<AGROW>
            end
        end
