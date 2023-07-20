function instrumentForCoverage...
    (lToolchainInfo,compileBuildOptsInstr,snifferFEOpts,modelName,...
    outDirRelative,filesToInstrument,instrumentationUpToDate,...
    componentName,moduleName,lBuildInfoInstr,buildInfoOriginal,lIsSilBuild,...
    lIsTopModelSil,lIsSilBuildAndPortableWordSizes,...
    instrumOptions,lHookChecksum,lInstrObjFolder)








    lAnchorFolder=lBuildInfoInstr.Settings.LocalAnchorDir;
    trDataFile=SlCov.coder.EmbeddedCoder.getCodeCovDataFilesDuringBuild...
    (moduleName,modelName,lAnchorFolder);



    isSharedLibrary=~strcmp(lBuildInfoInstr.ModelName,modelName);
    if~isSharedLibrary&&isfile(trDataFile)
        delete(trDataFile);
    end


    instrumenter=codeinstrum.internal.Instrumenter(trDataFile,instrumOptions);

    instrumenter.anchorDir=lBuildInfoInstr.Settings.LocalAnchorDir;
    instrumenter.moduleName=moduleName;
    outDir=fullfile(lAnchorFolder,outDirRelative);
    instrumenter.outDir=outDir;


    instrumenter.InstrVarRadix=[instrumenter.InstrVarRadix,'_',componentName];
    instrumenter.InstrFcnRadix=[instrumenter.InstrFcnRadix,'_',componentName];


    if sldv.code.internal.isXilFeatureEnabled()
        sldv.code.internal.setCustomMacroEmitter(instrumenter.InstrumImpl);
        instrumenter.InstrFcnSuffix=codeinstrum.internal.Utils.encodeModuleName(moduleName);
    end



    instrumenter.booleanTypes{end+1}='boolean_T';


    cs=getActiveConfigSet(modelName);
    if cs.hasProp('EnableUserReplacementTypes')&&...
        strcmpi(get_param(cs,'EnableUserReplacementTypes'),'on')
        replTypes=get_param(cs,'ReplacementTypes');
        booleanTypeValue=replTypes.boolean;
        if~isempty(booleanTypeValue)&&...
            (sum(strcmp(struct2cell(replTypes),booleanTypeValue))<2)
            instrumenter.booleanTypes{end+1}=booleanTypeValue;
        end
    end

    if cs.hasProp('AutosarSchemaVersion')&&...
        ~isempty(get_param(cs,'AutosarSchemaVersion'))
        instrumenter.booleanTypes{end+1}='boolean';
    end


    incrementalBuild=isSharedLibrary;


    componentRegistry=extractCodeCovComponentRegistry(outDir,lIsSilBuild);
    if~incrementalBuild||~isfile(trDataFile)||isempty(componentRegistry)


        targetWordSize=get_param(modelName,'TargetWordSize');
        maxIdLength=get_param(modelName,'MaxIdLength');

        componentRegistry=SlCov.coder.CodeCovProbeComponentRegistry(moduleName,...
        instrumOptions,...
        targetWordSize,...
        maxIdLength);

        codeCovSetIsSil(componentRegistry,lIsSilBuild)
    else


    end

    instrumenter.codeCovProbeComponentRegistry=componentRegistry;
    instrumenter.prepareModuleInstrumentation(incrementalBuild);
    instrumenter.setSourceKind(internal.cxxfe.instrum.SourceKind.ECoder);

    srcFiles=filesToInstrument(~(incrementalBuild&instrumentationUpToDate));

    if~isSharedLibrary

        instrumenter.traceabilityData.addSymbolicName('BUILD_DIR',polyspace.internal.getAbsolutePath(outDir));

        traceInfoBuilder=get_param(modelName,'CoderTraceInfo');
        if(isempty(traceInfoBuilder)||isempty(traceInfoBuilder.files))
            traceInfoBuilder=coder.trace.TraceInfoBuilder(modelName);
            traceInfoBuilder.buildDir=outDir;
            traceInfoBuilder.repositoryDir=fullfile(outDir,'tmwinternal');
            if isfile(fullfile(traceInfoBuilder.repositoryDir,'tr'))
                if traceInfoBuilder.load()


                    if lIsSilBuild
                        traceInfoBuilder.repositoryDir=fullfile(outDir,'tmwinternal');
                        traceInfoBuilder.buildDir=outDir;
                    end
                else

                    traceInfoBuilder=[];
                end
            else
                traceInfoBuilder=[];
            end
        end
        if~isempty(traceInfoBuilder)
            code2ModelRecords=traceInfoBuilder.getCodeToModelRecords();
            if~isempty(code2ModelRecords)
                token=[code2ModelRecords.token];
                fileIdx=[token.fileIdx];
                files=traceInfoBuilder.files';
                instrumenter.code2ModelRecords=...
                struct('file',{files(fileIdx+1)},...
                'line',[token.line],...
                'beginCol',[token.beginCol],...
                'modelElems',{{code2ModelRecords.modelElems}});
                if codeinstrumprivate('feature','honorCovLogicBlockShortCircuit')&&...
                    strcmpi(get_param(modelName,'CovLogicBlockShortCircuit'),'off')
                    isLogicBlock=ismember({token.token},{'&&','||'});
                    for ii=find(isLogicBlock)
                        isLogicBlock(ii)=...
                        all(strcmp(get_param(code2ModelRecords(ii).modelElems,'BlockType'),'Logic'));
                    end
                    instrumenter.code2ModelRecords.isLogicBlock=isLogicBlock;
                end
            end
        end
    end


    mainFile='ert_main';





    coder_profile_stubs=coder.profile.ExecTimeConfig.EmptyTimerSrcName;
    filesToSkip={mainFile,coder_profile_stubs};

    numInstrumented=0;

    allLangs={'c','c++'};
    allFEOpts=cell(size(allLangs));

    for ii=1:numel(srcFiles)
        srcFile=srcFiles{ii};
        [~,f,e]=fileparts(srcFile);
        instrumentedSrcFile=fullfile(lBuildInfoInstr.Settings.LocalAnchorDir,...
        lBuildInfoInstr.ComponentBuildFolder,[f,e]);

        [~,fname,fext]=fileparts(srcFile);
        if ismember(fname,filesToSkip)
            copyfile(srcFile,instrumentedSrcFile,'f');
            continue
        end

        try

            fNameAndExt=[fname,fext];


            if~isempty(snifferFEOpts)&&snifferFEOpts.isKey(fNameAndExt)
                frontEndOptions=snifferFEOpts(fNameAndExt);
            else
                if~isempty(snifferFEOpts)
                    warning(message('CodeInstrumentation:instrumenter:failedToDetectFEOpts',srcFile));
                end
                if strcmp(srcFile(end-1:end),'.c')
                    lang='c';
                else
                    lang='c++';
                end
                langIdx=find(strcmp(allLangs,lang),1,'first');
                frontEndOptions=allFEOpts{langIdx};
                if isempty(frontEndOptions)
                    frontEndOptions=getFEOpts...
                    (lang,lBuildInfoInstr,lIsSilBuildAndPortableWordSizes,...
                    lToolchainInfo,compileBuildOptsInstr,lIsSilBuild,modelName);
                    if sldv.code.internal.isXilFeatureEnabled()&&lIsSilBuild&&lang=="c"
                        opts=codeinstrum.internal.compilerWorkArounds(fileparts(trDataFile),frontEndOptions,false);
                        frontEndOptions.ExtraOptions=[frontEndOptions.ExtraOptions(:);opts(:)];
                    end
                    allFEOpts{langIdx}=frontEndOptions;
                end
            end


            extraOpts=struct('instrumentedSrcFile',instrumentedSrcFile);

            if codeinstrumprivate('feature','htmlPrettyPrinter')

                extraOpts.ilHtmlFile='<default>';
            end

            if polyspace.internal.logging.Logger.getLogger('Instrumenter').Level<polyspace.internal.logging.Level.FINE

                extraOpts.instrXmlFile='<default>';
            end

            extraOpts=instrumenter.instrumentFile(srcFile,frontEndOptions,extraOpts);

            if isfield(extraOpts,'instrXmlFile')&&~isempty(extraOpts.instrXmlFile)

                hl=targets_hyperlink_manager('new',extraOpts.instrXmlFile,...
                sprintf('edit(''%s'')',extraOpts.instrXmlFile));
                fine(polyspace.internal.logging.Logger.getLogger('Instrumenter'),...
                'created the database XML dump file:\n\t%s',hl);
            end

            hl=targets_hyperlink_manager('new',instrumentedSrcFile,...
            sprintf('edit(''%s'')',instrumentedSrcFile));
            fine(polyspace.internal.logging.Logger.getLogger('Instrumenter'),...
            'created instrumented file:\n\t%s',hl);

            numInstrumented=numInstrumented+1;
        catch Me %#ok<NASGU>
            warning(message('CodeInstrumentation:instrumenter:skipSourceInstrumentation',srcFile));



            copyfile(srcFile,instrumentedSrcFile,'f');


            srcFile=polyspace.internal.getAbsolutePath(srcFile);
            instrumenter.traceabilityData.insertFile(srcFile,...
            internal.cxxfe.instrum.FileKind.SOURCE,...
            internal.cxxfe.instrum.FileStatus.FAILED);
            instrumenter.traceabilityData.addFileToModule(srcFile,moduleName);
        end
    end


    [filesList,groupsList]=buildInfoOriginal.getFiles('all',true,true);

    for ii=1:numel(filesList)
        filePath=polyspace.internal.getAbsolutePath(filesList{ii});
        instrumenter.traceabilityData.setFileGroup(filePath,groupsList{ii});
    end



    if sldv.code.internal.isXilFeatureEnabled()


        instrumenter.traceabilityData.setConfigurationParameter('InstrFileExtPrefix',...
        instrumenter.instrPrefix);

        instrumenter.traceabilityData.setConfigurationParameter('InstrSubFolder',...
        lInstrObjFolder);
        instrumenter.traceabilityData.setConfigurationParameter('HookChecksum',...
        sprintf('%d',lHookChecksum));
        instrumenter.traceabilityData.setConfigurationParameter('IsSilBuild',...
        sprintf('%d',lIsSilBuild));
        instrumenter.traceabilityData.setConfigurationParameter('IsTopModelXil',...
        sprintf('%d',lIsTopModelSil));
    end

    instrumenter.finalizeModuleInstrumentation();

    [maxCovId,hTableSize]=instrumenter.getCovTableSize();
    componentRegistry.SetCovTableSize(maxCovId,hTableSize);

    coder.profile.CoderInstrumentationInfo.addComponentRegistry(outDir,componentRegistry);



    needCoverageInfoChecksums=isSharedLibrary;

    if~isempty(instrumentationUpToDate)&&~all(instrumentationUpToDate)&&needCoverageInfoChecksums

        coder.coverage.setInstrumentationUpToDate...
        (filesToInstrument,fullfile(outDir,lInstrObjFolder))
    end

    if~isempty(instrumentationUpToDate)&&~all(instrumentationUpToDate)&&...
        numInstrumented==0

        warning(message('CodeInstrumentation:instrumenter:noInstrumentedSource'));
    end

end



function feOpts=getFEOpts(lang,lBuildInfoInstr,lIsSilBuildAndPortableWordSizes,...
    lToolchainInfo,compileBuildOptsInstr,lIsSilBuild,modelName)

    isCxx=strcmpi(lang,'c++');








    if ispc&&~isempty(lToolchainInfo)&&lToolchainInfo.SupportsBuildingMEXFuncs
        mexCompilerKey=lToolchainInfo.Alias{1};
        forceLCC64=strcmp(mexCompilerKey,'LCC-x');
        isMinGW64=strcmp(lToolchainInfo.Platform,'win64')&&...
        strcmp(mexCompilerKey,'GNU-x');
        toolchainMexComp=coder.make.internal.getMexCompInfoFromKey(mexCompilerKey);

        evalc('currentMexComp = mex.getCompilerConfigurations(lang, ''Selected'');');

        if isempty(currentMexComp)||~strcmp(toolchainMexComp.comp.MexOpt,currentMexComp.MexOpt)


            localMexOptFile=fullfile(pwd,['mex_',upper(lang),'_',computer('arch'),'.xml']);
            assert(~isfile(localMexOptFile),'Local mex options %s file must not exist',localMexOptFile);

            mexOptFile=toolchainMexComp.comp.MexOpt;
            if strcmp(lang,'c++')

                mexOptFile=strrep(mexOptFile,'msvc','msvcpp');
                mexOptFile=strrep(mexOptFile,'mingw64','mingw64_g++');
                mexOptFile=strrep(mexOptFile,'intel_c','intel_cpp');
            end

            evalc(['mex(''-setup:',mexOptFile,''',''',lang,''', ''-f'', ''.'');']);
            assert(isfile(localMexOptFile),'Local mex options %s file must exist',localMexOptFile);
            mexRestore=onCleanup(@()delete(localMexOptFile));
        end
    else
        forceLCC64=false;
        isMinGW64=false;
    end

    if forceLCC64

        overrideCompilerFlags='';
    elseif ispc&&~isMinGW64

        overrideCompilerFlags=['-DCRTAPI1=_cdecl -DCRTAPI2=_cdecl -nologo -GS ',...
        '-D_AMD64_=1 -DWIN64 -D_WIN64 -DWIN32 -D_WIN32 -W4 ',...
'-D_WINNT -D_WIN32_WINNT=0x0502 -DNTDDI_VERSION=0x05020000 '...
        ,'-D_WIN32_IE=0x0600 -DWINVER=0x0502 -D_MT -MT'];
    else

        if isCxx
            buildToolName='C++ Compiler';
            stdOptsMacroName='CPP_STANDARD_OPTS';
        else
            buildToolName='C Compiler';
            stdOptsMacroName='C_STANDARD_OPTS';
        end


        buildTool=getBuildTool(lToolchainInfo,buildToolName);
        stdMaps=buildTool.SupportedStandard.getLangStandardMaps;
        standardOpts=stdMaps.getCompilerOptions('*');

        if strcmp(compileBuildOptsInstr.BuildConfiguration,'Specify')

            idx=find(strcmp(compileBuildOptsInstr.CustomToolchainOptions,buildToolName),1)+1;
            assert(idx~=1);
            compilerOpts=compileBuildOptsInstr.CustomToolchainOptions{idx};
            compilerOpts=regexprep(compilerOpts,{'^-c\s+','(\s)-c\s+'},{'','$1'});
            overrideCompilerFlags=regexprep(compilerOpts,['\$\(',stdOptsMacroName,'\)'],standardOpts);
            if ismac

                [~,xcodeDevelDir]=system('xcode-select -print-path');
                xcodeDevelDir=strtrim(xcodeDevelDir);
                xcodeSDKVer=strtrim(perl(fullfile(matlabroot,'rtw','c','tools','macsdkver.pl')));
                xcodeSDK=['MacOSX',xcodeSDKVer,'.sdk'];
                xcodeSDKDir=fullfile(xcodeDevelDir,'Platforms','MacOSX.platform','Developer','SDKs',xcodeSDK);

                overrideCompilerFlags=regexprep(overrideCompilerFlags,'\$\(XCODE_SDK_ROOT\)',xcodeSDKDir);
                overrideCompilerFlags=regexprep(overrideCompilerFlags,'\$\(ARCHS\)','x86_64');
            end
        elseif ismac

            overrideCompilerFlags=['-arch x86_64 ',standardOpts];
        else

            overrideCompilerFlags=[standardOpts,' -fPIC'];
        end
    end
    feOpts=internal.cxxfe.util.getFrontEndOptions('lang',lang,...
    'addMWInc',false,...
    'useMexSettings',true,...
    'forceLCC64',forceLCC64,...
    'overrideCompilerFlags',overrideCompilerFlags);

    if lIsSilBuildAndPortableWordSizes
        feOpts.Preprocessor.Defines{end+1}='PORTABLE_WORDSIZES';
    end
    if ispc
        feOpts.Preprocessor.Defines{end+1}='SAL_NO_ATTRIBUTE_DECLARATIONS';
    end


    internal.cxxfe.util.updateFrontEndOptions(feOpts,lBuildInfoInstr);









    unEscapeFunction=coder.make.internal.unEscapeDoubleQuotesFunction;
    feOpts.Preprocessor.Defines=unEscapeFunction(feOpts.Preprocessor.Defines);
    feOpts.Preprocessor.PreIncludeMacros=unEscapeFunction(feOpts.Preprocessor.PreIncludeMacros);

    if~lIsSilBuild

        feOpts.Target.CharNumBits=get_param(modelName,'TargetBitPerChar');
        feOpts.Target.ShortNumBits=get_param(modelName,'TargetBitPerShort');
        feOpts.Target.IntNumBits=get_param(modelName,'TargetBitPerInt');
        feOpts.Target.LongNumBits=get_param(modelName,'TargetBitPerLong');
        feOpts.Target.LongLongNumBits=get_param(modelName,'TargetBitPerLongLong');
        feOpts.Target.FloatNumBits=get_param(modelName,'TargetBitPerFloat');
        feOpts.Target.DoubleNumBits=get_param(modelName,'TargetBitPerDouble');
        feOpts.Target.LongDoubleNumBits=get_param(modelName,'TargetBitPerDouble');
        feOpts.Target.PointerNumBits=get_param(modelName,'TargetBitPerPointer');
        feOpts.Target.SizeTNumBits=get_param(modelName,'TargetBitPerSizeT');
        feOpts.Target.PtrDiffTNumBits=get_param(modelName,'TargetBitPerSizeT');
        if strcmpi(get_param(modelName,'TargetEndianess'),'LittleEndian')
            feOpts.Target.Endianness='little';
        else
            feOpts.Target.Endianness='big';
        end
    end

end



function componentRegistry=extractCodeCovComponentRegistry(outDir,isSIL)

    componentRegistry=[];

    info_mat=fullfile(outDir,'profiling_info.mat');
    if exist(info_mat,'file')
        infoData=load(info_mat);
        if isfield(infoData,'componentRegistries')&&~isempty(infoData.componentRegistries)
            idx=false(1,numel(infoData.componentRegistries));
            for ii=1:numel(infoData.componentRegistries)
                componentRegistry2=infoData.componentRegistries{ii};
                if isa(componentRegistry2,'SlCov.coder.CodeCovProbeComponentRegistry')&&...
                    codeCovGetIsSil(componentRegistry2)==isSIL
                    componentRegistry=componentRegistry2;
                    idx(ii)=true;
                end
            end
            if any(idx)
                infoData.componentRegistries(idx)=[];
                coder.profile.CoderInstrumentationInfo.writeInfo(outDir,infoData);
            end
        end
    end

end




