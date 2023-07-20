










function[sharedHdrFiles,sharedSrcFiles,hdrPaths,addHdrPaths]=...
    addCRLUsageInfoToBuildInfo(buildInfo,...
    hRtwFcnLib,...
    genDirForTFL,...
    excludeHdrs,...
    isSharedLoc,...
    isCompactFileFormat)

    [srcs,srcPaths,hdrs,hdrPaths,addHdrs,addHdrPaths,addSrcs,...
    addSrcPaths,sharedHdrFiles,sharedSrcFiles]=...
    getTflFilesAndPaths(hRtwFcnLib,...
    genDirForTFL,...
    isSharedLoc,...
    isCompactFileFormat);

    hdrs=regexprep(hdrs,'<.+>','');
    hdrs=regexprep(hdrs,'"','');
    addHdrs=regexprep(addHdrs,'<.+>','');
    addHdrs=regexprep(addHdrs,'"','');
    if~isempty(excludeHdrs)
        hdrs=setdiff(hdrs,excludeHdrs,'legacy');
        addHdrs=setdiff(addHdrs,excludeHdrs,'legacy');
    end
    objs=hRtwFcnLib.getUsedLinkObjs;

    srcPaths=RTW.expandToken(srcPaths);
    hdrPaths=RTW.expandToken(hdrPaths);
    addSrcPaths=RTW.expandToken(addSrcPaths);
    addHdrPaths=RTW.expandToken(addHdrPaths);
    objPaths=RTW.expandToken(hRtwFcnLib.getUsedLinkObjsPaths);
    linkFlags=RTW.expandToken(hRtwFcnLib.getUsedLinkFlags);
    compileFlags=RTW.expandToken(hRtwFcnLib.getUsedCompileFlags);


    if~isempty(srcs)
        buildInfo.addSourceFiles(srcs,srcPaths,'TFL');
    end
    if~isempty(hdrs)
        buildInfo.addIncludeFiles(hdrs,hdrPaths,'TFL');
    end
    if~isempty(addSrcs)
        buildInfo.addSourceFiles(addSrcs,'','TFL');
    end
    if~isempty(addSrcPaths)
        buildInfo.addSourcePaths(addSrcPaths,'TFL');
    end
    if~isempty(addHdrs)
        buildInfo.addIncludeFiles(addHdrs,'','TFL');
    end
    if~isempty(addHdrPaths)
        buildInfo.addIncludePaths(addHdrPaths,'TFL');
    end








    if hRtwFcnLib.isPerformingSim
        loc_addSimulationLibs(buildInfo,objs,objPaths);
    else
        buildInfo.addLinkObjects(objs,objPaths,'',true,true,'TFL');
    end

    buildInfo.addLinkFlags(linkFlags);
    buildInfo.addCompileFlags(compileFlags,'OPTS');

    simdFlags=loc_getSimdVersion(hRtwFcnLib);
    if~isempty(simdFlags)
        len=length(simdFlags);
        for i=1:len
            buildInfo.Settings.addInstructionSetRequirements(simdFlags{i});
        end
    end
end

function loc_addSimulationLibs(buildInfo,objs,objPaths)

    if iscell(objs)
        for i=1:length(objs)
            loc_addLibOrSyslib(buildInfo,objs{i},objPaths{i});
        end
    else
        loc_addLibOrSyslib(buildInfo,objs,objPaths);
    end
end

function loc_addLibOrSyslib(buildInfo,obj,objPath)
    if isequal(objPath,'$(MATLAB_ROOT)/bin/glnxa64')&&isequal(obj,'libmwblas.so')
        buildInfo.addSysLibs('mwblas',objPath);
    elseif isequal(objPath,'$(MATLAB_ROOT)/bin/glnxa64')&&isequal(obj,'libmwmfl_interp.so')
        buildInfo.addSysLibs('mwmfl_interp',objPath);
    else
        buildInfo.addLinkObjects(obj,objPath,'',true,true,'TFL');
    end
end

function simdFlags=loc_getSimdVersion(hRtwFcnLib)
    simdFlags={};
    useSIMDLibrary=contains(hRtwFcnLib.LoadedLibrary,'Intel AVX-512')||...
    contains(hRtwFcnLib.LoadedLibrary,'Intel AVX')||...
    contains(hRtwFcnLib.LoadedLibrary,'Intel SSE');
    instructionSets=hRtwFcnLib.InstructionSets;
    hasInstructionSetsEnabled=~isempty(instructionSets)&&...
    ~any(contains(instructionSets,'none'));

    if hasInstructionSetsEnabled
        simdFlags=loc_getSimdVersionForInstructionSets(instructionSets);
    elseif useSIMDLibrary
        simdFlags=loc_getSimdVersionForLegacyCrl(hRtwFcnLib);
    end



    simdFlags=loc_removeUnnecessarySimdVersions(simdFlags);

end



function trimmedSimdVersions=loc_removeUnnecessarySimdVersions(inputSimdVersions)
    len=length(inputSimdVersions);
    if(len<=1)
        trimmedSimdVersions=inputSimdVersions;
        return;
    end



    if any(strcmp(inputSimdVersions,'AVX512F'))
        trimmedSimdVersions={'AVX512F'};
    elseif any(strcmp(inputSimdVersions,'FMA'))
        trimmedSimdVersions={'FMA'};
    elseif any(strcmp(inputSimdVersions,'AVX2'))
        trimmedSimdVersions={'AVX2'};
    elseif any(strcmp(inputSimdVersions,'AVX'))
        trimmedSimdVersions={'AVX'};
    elseif any(strcmp(inputSimdVersions,'SSE4.1'))
        trimmedSimdVersions={'SSE4.1'};
    elseif any(strcmp(inputSimdVersions,'SSE2'))
        trimmedSimdVersions={'SSE2'};
    elseif any(strcmp(inputSimdVersions,'SSE'))
        trimmedSimdVersions={'SSE'};
    else
        trimmedSimdVersions=inputSimdVersions;
    end

end

function simdFlags=loc_getSimdVersionForInstructionSets(instructionSets)
    simdFlags={};
    len=length(instructionSets);
    for i=1:len
        if~strcmpi(instructionSets{i},'None')
            simdFlags{i}=instructionSets{i};%#ok<AGROW>
        else
            simdFlags={};
            return;
        end
    end

end

function simdFlags=loc_getSimdVersionForLegacyCrl(hRtwFcnLib)
    simdFlags={};
    hitCache=hRtwFcnLib.HitCache;
    numHits=length(hitCache);
    currentFlagIdx=1;
    for i=1:numHits
        if contains(hitCache(i).UID,'inline_intel_avx512f_crl')
            simdFlags{currentFlagIdx}='AVX512F';%#ok<AGROW>
            currentFlagIdx=currentFlagIdx+1;
        elseif contains(hitCache(i).UID,'inline_intel_fma_crl')||...
            contains(hitCache(i).UID,'dst_avx2_crl_table')
            simdFlags{currentFlagIdx}='FMA';%#ok<AGROW>
            currentFlagIdx=currentFlagIdx+1;
        elseif contains(hitCache(i).UID,'inline_intel_avx2_crl')
            simdFlags{currentFlagIdx}='AVX2';%#ok<AGROW>
            currentFlagIdx=currentFlagIdx+1;
        elseif contains(hitCache(i).UID,'inline_intel_avx_crl')
            simdFlags{currentFlagIdx}='AVX';%#ok<AGROW>
            currentFlagIdx=currentFlagIdx+1;
        elseif contains(hitCache(i).UID,'inline_intel_sse41_crl')
            simdFlags{currentFlagIdx}='SSE4.1';%#ok<AGROW>
            currentFlagIdx=currentFlagIdx+1;
        elseif contains(hitCache(i).UID,'inline_intel_sse2_crl')
            simdFlags{currentFlagIdx}='SSE2';%#ok<AGROW>
            currentFlagIdx=currentFlagIdx+1;
        elseif contains(hitCache(i).UID,'inline_intel_sse_crl')
            simdFlags{currentFlagIdx}='SSE';%#ok<AGROW>
            currentFlagIdx=currentFlagIdx+1;
        end
    end
    simdFlags=unique(simdFlags);

end





function[addHdrs,addSrcs,addSrcPaths,hdrMap,srcMap,sharedHdrFiles,...
    sharedSrcFiles]=getHeaderSourceAndPathInfo(entry,...
    impl,...
    addHdrs,...
    addSrcs,...
    addSrcPaths,...
    hdrMap,...
    srcMap,...
    sharedHdrFiles,...
    sharedSrcFiles,...
    buildDir,...
    isSharedLoc,...
    isCompactFormat)

    copied=strcmp(entry.GenCallback,'RTW.copyFileToBuildDir');
    generated=strfind(entry.GenCallback,'.tlc');

    if isCompactFormat&&~isempty(generated)
        return
    end

    implHdr=impl.HeaderFile;
    if~isempty(implHdr)
        srcDirs=['.';...
        impl.HeaderPath;...
        entry.AdditionalIncludePaths;...
        entry.SearchPaths];
        [implHdr,implHdrPath]=getTflFilePath(implHdr,...
        buildDir,copied,srcDirs);
    end
    implSrc=impl.SourceFile;
    if~isempty(implSrc)
        srcDirs=['.';...
        impl.SourcePath;...
        entry.AdditionalSourcePaths;...
        entry.SearchPaths];
        [implSrc,implSrcPath]=getTflFilePath(implSrc,...
        buildDir,copied,srcDirs);
    end
    if~isempty(implHdr)
        if isSharedLoc&&copied
            sharedHdrFiles{end+1}=implHdr;
        else
            if isempty(implHdrPath)
                addHdrs{end+1}=implHdr;
            elseif~isKey(hdrMap,implHdr)
                hdrMap(implHdr)=implHdrPath;
            end
        end
    end
    if~isempty(implSrc)
        if isSharedLoc&&copied
            sharedSrcFiles{end+1}=implSrc;
        else
            if isempty(implSrcPath)
                addSrcs{end+1}=implSrc;
            elseif~isKey(srcMap,implSrc)
                srcMap(implSrc)=implSrcPath;




                if~strcmp(implSrcPath,buildDir)
                    addSrcPaths{end+1}=implSrcPath;
                end
            end
        end
    end

end






function[srcs,srcPaths,hdrs,hdrPaths,addHdrs,addHdrPaths,addSrcs,...
    addSrcPaths,sharedHdrFiles,sharedSrcFiles]=...
    getTflFilesAndPaths(hTfl,...
    buildDir,...
    isSharedLoc,...
    isCompactFormat)

    srcMap=containers.Map('KeyType','char','ValueType','char');
    hdrMap=containers.Map('KeyType','char','ValueType','char');
    addHdrs={};
    addSrcs={};
    addHdrPaths={};
    addSrcPaths={};
    sharedSrcFiles={};
    sharedHdrFiles={};

    entries=hTfl.HitCache;
    numEnts=length(entries);
    for entIdx=1:numEnts
        thisEnt=entries(entIdx);
        if thisEnt.getExcludeFromBuild()
            continue;
        end

        copied=strcmp(thisEnt.GenCallback,'RTW.copyFileToBuildDir');
        if~isa(thisEnt,'RTW.TflCustomization')
            if isprop(thisEnt,'Implementation')&&~isempty(thisEnt.Implementation)
                impl=thisEnt.Implementation;
                [addHdrs,addSrcs,addSrcPaths,hdrMap,srcMap,sharedHdrFiles,...
                sharedSrcFiles]=getHeaderSourceAndPathInfo(thisEnt,...
                impl,...
                addHdrs,...
                addSrcs,...
                addSrcPaths,...
                hdrMap,...
                srcMap,...
                sharedHdrFiles,...
                sharedSrcFiles,...
                buildDir,...
                isSharedLoc,...
                isCompactFormat);
            elseif isa(thisEnt,'RTW.TflBlockEntry')
                implVector=thisEnt.ImplementationVector;
                if~isempty(implVector)
                    [nrow,ncol]=size(implVector);
                    index=(nrow*ncol)/2;
                    for i=1:nrow
                        implSet=implVector{index+i};
                        for j=1:length(implSet)
                            impl=implSet(j);
                            [addHdrs,addSrcs,addSrcPaths,hdrMap,srcMap,...
                            sharedHdrFiles,sharedSrcFiles]=...
                            getHeaderSourceAndPathInfo(thisEnt,...
                            impl,...
                            addHdrs,...
                            addSrcs,...
                            addSrcPaths,...
                            hdrMap,...
                            srcMap,...
                            sharedHdrFiles,...
                            sharedSrcFiles,...
                            buildDir,...
                            isSharedLoc,...
                            isCompactFormat);
                        end
                    end
                end
            end
            addFiles=thisEnt.AdditionalHeaderFiles;
            numAddFiles=length(addFiles);
            addPaths=thisEnt.AdditionalIncludePaths;
            numAddPaths=length(addPaths);
            for fileIdx=1:numAddFiles
                thisFile=addFiles{fileIdx};
                [aFile,aPath]=getTflFilePath(thisFile,...
                buildDir,copied,['.';addPaths;thisEnt.SearchPaths]);
                if~isempty(aFile)
                    if isSharedLoc&&copied
                        sharedHdrFiles{end+1}=aFile;%#ok<AGROW>
                    else
                        if isempty(aPath)
                            addHdrs{end+1}=aFile;%#ok<AGROW>
                        elseif~isKey(hdrMap,aFile)
                            hdrMap(aFile)=aPath;
                        end
                    end
                end
            end
            for fileIdx=1:numAddPaths
                addHdrPaths{end+1}=addPaths{fileIdx};%#ok
            end

            addFiles=thisEnt.AdditionalSourceFiles;
            numAddFiles=length(addFiles);
            addPaths=thisEnt.AdditionalSourcePaths;
            numAddPaths=length(addPaths);
            for fileIdx=1:numAddFiles
                thisFile=addFiles{fileIdx};
                [aFile,aPath]=getTflFilePath(thisFile,...
                buildDir,copied,['.';addPaths;thisEnt.SearchPaths]);
                if~isempty(aFile)
                    if isSharedLoc&&copied
                        sharedSrcFiles{end+1}=aFile;%#ok<AGROW>
                    else
                        if isempty(aPath)
                            addSrcs{end+1}=aFile;%#ok<AGROW>
                        elseif~isKey(srcMap,aFile)
                            srcMap(aFile)=aPath;
                        end
                    end
                end
            end
            for fileIdx=1:numAddPaths
                addSrcPaths{end+1}=addPaths{fileIdx};%#ok
            end
        end
    end

    srcs=srcMap.keys;
    srcPaths=srcMap.values;
    hdrs=hdrMap.keys;
    hdrPaths=hdrMap.values;
    addHdrs=unique(addHdrs,'legacy');
    addHdrPaths=unique(addHdrPaths,'legacy');
    addSrcs=unique(addSrcs,'legacy');
    addSrcPaths=unique(addSrcPaths,'legacy');
    sharedHdrFiles=unique(sharedHdrFiles,'legacy');
    sharedSrcFiles=unique(sharedSrcFiles,'legacy');

end





function[nameSrcFile,filePath]=getTflFilePath(fileName,...
    buildDir,...
    copied,...
    srcDirs)

    nameSrcFile=fileName;
    filePath='';
    if~isempty(fileName)
        srcDirs=RTW.expandToken(srcDirs);

        [filePath,idSrcFile,extSrcFile]=fileparts(fileName);

        if isempty(extSrcFile)
            nameSrcFile=idSrcFile;
        else
            nameSrcFile=[idSrcFile,extSrcFile];
        end

        if isempty(filePath)
            if copied
                filePath=buildDir;
            else
                for i=1:length(srcDirs)
                    if strcmp('',srcDirs{i})
                        srcDirs{i}='.';
                    end
                    fullSrcName=fullfile(srcDirs{i},nameSrcFile);
                    existSrcFlag=dir(fullSrcName);
                    if~isempty(existSrcFlag)
                        filePath=srcDirs{i};
                        if strcmp(filePath,'.')
                            filePath=pwd;
                        end
                        break;
                    end
                end
            end
        end
    end



    if strcmp(filePath,buildDir)
        filePath='';
    end

end

