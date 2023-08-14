







function ok=runSldvAnalysis(this,...
    options,...
    modelH,...
    modelInfo,...
    emitterDb,...
    wrapperInfo,...
    analyzedInfo)

    tmpDir=tempname;
    polyspace.internal.makeParentDir(fullfile(tmpDir,'.'));
    if sldv.code.internal.feature('debug')
        fprintf(1,'### Debug: Keeping temporary directory %s\n',tmpDir);
    else
        cleanupDir=onCleanup(@()sldv.code.internal.removeDir(tmpDir));
    end

    posConverter=sldv.code.internal.PosConverter();
    allSourceFiles={};
    extractedInfo=modelInfo([modelInfo.SupportSldv]);
    if numel(extractedInfo)>1

        [~,uniqueIndexes]=unique({extractedInfo.SettingsChecksum});
        extractedInfo=extractedInfo(uniqueIndexes);
    end
    for ii=1:numel(extractedInfo)
        extractedChecksum=extractedInfo(ii).SettingsChecksum;
        ccLib=extractedInfo(ii).LibPath;
        coverageDb=internal.slcc.cov.LibUtils.getTraceabilityDb(ccLib);
        dbFile=sldv.code.internal.extractDb(tmpDir,coverageDb);

        db=sldv.code.slcc.internal.TraceabilityDb(dbFile);
        db.computeShortestUniquePaths();


        emitterDb.addModuleInfo(extractedChecksum,struct('codeTr',db));

        currentSourceFiles=db.extractInstrumentedFiles(tmpDir,extractedChecksum);
        db.close();
        allSourceFiles=[allSourceFiles;currentSourceFiles(:)];%#ok;

        posConverter.parseFiles(fullfile(tmpDir,currentSourceFiles));
    end

    if~isempty(analyzedInfo)&&analyzedInfo.SupportSldv





        settingsChecksum=analyzedInfo.SettingsChecksum;
        ccLib=analyzedInfo.LibPath;
        coverageDb=internal.slcc.cov.LibUtils.getTraceabilityDb(ccLib);
        dbFile=sldv.code.internal.extractDb(tmpDir,coverageDb);

        db=sldv.code.slcc.internal.TraceabilityDb(dbFile);

        db.extractInstrumentedFiles(tmpDir,settingsChecksum);

        analyzedWrapper=getWrapperFile(tmpDir,settingsChecksum);
        if~isempty(analyzedWrapper)
            allSourceFiles{end+1}=analyzedWrapper;
        end
    end

    settingsChecksum=modelInfo(1).SettingsChecksum;

    ccSettings=CGXE.CustomCode.CustomCodeSettings.createFromModel(modelH);



    cgxeDir=cgxeprivate('get_cgxe_proj_root');
    ccDir=fullfile(cgxeDir,'slprj','_slcc',settingsChecksum);
    ccSettings.userIncludeDirs=...
    cgxeprivate('getTokenizedPathsAndFiles',modelH,cgxeDir,ccSettings,ccDir);

    lang=get_param(modelH,'TargetLang');
    isCppModel=~strcmpi(lang,'c');

    randomFunctions={};
    for ii=1:numel(wrapperInfo)
        [wrapperFile,isCppWrapper]=getWrapperFile(tmpDir,wrapperInfo(ii).Checksum);

        if isCppWrapper

            lang='c++';
        end

        if isempty(wrapperFile)
            checksum=wrapperInfo(ii).Checksum;
            if any(strcmp(checksum,{'CScript','CExpr'}))
                if isCppModel
                    wrapperExt='cpp';
                else
                    wrapperExt='c';
                end
                wrapperFileName=sprintf('wrappers_%s.%s',checksum,wrapperExt);
                wrapperFile=fullfile(tmpDir,wrapperFileName);
                allSourceFiles{end+1}=wrapperFile;%#ok
            else
                continue
            end
        end

        randomFunction=sldv.code.slcc.internal.generateWrappers(wrapperFile,...
        wrapperInfo(ii).Checksum,...
        ccSettings,...
        wrapperInfo(ii).WrapperText,...
        wrapperInfo(ii).WrapperVars,...
        wrapperInfo(ii).CustomCodeVars);
        randomFunctions{end+1}=randomFunction;%#ok<AGROW>
    end

    if strcmpi(lang,'c')
        ext='c';
    else
        ext='cpp';
    end


    mainFile=fullfile(tmpDir,sprintf('psmain.%s',ext));

    wrapperFunctions=flattenCells({wrapperInfo.WrapperFunctions});
    sldv.code.slcc.internal.generateMain(mainFile,wrapperFunctions,randomFunctions);

    allSourceFiles{end+1}=mainFile;

    feOpts=CGXE.CustomCode.getFrontEndOptions(lang,ccSettings.userIncludeDirs);
    compilerInfo=sldv.code.internal.getCompilerInfo(feOpts);

    polyspaceOptions=options;
    polyspaceOptions.tmpDir=tmpDir;
    polyspaceOptions.language=compilerInfo.language;
    polyspaceOptions.Dialect=compilerInfo.dialect;
    polyspaceOptions.stdVersion=compilerInfo.stdVersion;
    polyspaceOptions.TargetTypes=compilerInfo.targetTypes;
    polyspaceOptions.ProtectedVars=flattenCells({wrapperInfo.CustomCodeVars});
    polyspaceOptions.InVars=flattenCells({wrapperInfo.WrapperVars});
    polyspaceOptions.CodeProcs=wrapperFunctions;
    polyspaceOptions.RemoveProcs=randomFunctions;

    [cgel,translationLog]=sldv.code.internal.sourceAnalysis(tmpDir,...
    polyspaceOptions,...
    allSourceFiles,...
    posConverter);

    ok=translationLog.isOk();
    this.FullLog=translationLog;
    if ok
        this.setFullIR(cgel,false);
    end

    function[wrapperFile,isCpp]=getWrapperFile(tmpDir,checksum)
        cppWrapperFile=fullfile(tmpDir,checksum,'wrappers.cpp');
        cWrapperFile=fullfile(tmpDir,checksum,'wrappers.c');
        isCpp=false;
        if isfile(cppWrapperFile)
            wrapperFile=cppWrapperFile;
            isCpp=true;
        elseif isfile(cWrapperFile)
            wrapperFile=cWrapperFile;
        else
            wrapperFile='';
        end

        function flattened=flattenCells(nested)
            numElements=0;
            for ii=1:numel(nested)
                numElements=numElements+numel(nested{ii});
            end
            flattened=cell(numElements,1);

            index=1;
            for ii=1:numel(nested)
                count=numel(nested{ii});
                if count>0
                    firstIndex=index;
                    index=index+count;
                    lastIndex=index-1;

                    flattened(firstIndex:lastIndex)=nested{ii};
                end
            end



