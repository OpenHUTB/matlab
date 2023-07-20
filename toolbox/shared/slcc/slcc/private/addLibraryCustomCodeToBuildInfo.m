function[ccHeaderCode,ccSrcCode,ccInitCode,ccTermCode]=addLibraryCustomCodeToBuildInfo(libModelH,mainModelH)


    [ccHeaderCode,ccSrcCode,ccInitCode,ccTermCode]=deal('');

    libModel=get_param(libModelH,'Name');

    modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance([]);



    isExtMode=strcmpi(get_param(mainModelH,'SimulationMode'),'external');
    if isempty(modelCodegenMgr)&&~isExtMode

        return;
    end

    isRTW=~CGXE.Utils.isRaccelOrMdfRefSimTarget(mainModelH);

    ccSettings=cgxeprivate('get_custom_code_settings',libModel,isRTW);
    ccInitCode=ccSettings.customInitializer;
    ccTermCode=ccSettings.customTerminator;

    if~isempty(modelCodegenMgr)
        ccHeaderCode=ccSettings.customCode;
        ccSrcCode=ccSettings.customSourceCode;
        buildInfo=modelCodegenMgr.BuildInfo;
        targetDir=modelCodegenMgr.BuildDirectory;
        addCCInfoToBuildInfo(buildInfo,ccSettings,libModel,targetDir);
    end

    function headers=getHeadersFromCCSettings(headerCode)
        headers=regexp(headerCode,'"([\w_]+.[h|hpp])"','tokens');
        headers=[headers{:}];

        function addCCInfoToBuildInfo(buildInfo,ccSettings,libModel,targetDir)
            headerFiles=getHeadersFromCCSettings(ccSettings.customCode);
            if~isempty(headerFiles)
                buildInfo.addIncludeFiles(headerFiles);
            end

            projRootDir=cgxeprivate('get_cgxe_proj_root');
            [includes,sources,libraries]=...
            cgxeprivate('getTokenizedPathsAndFiles',libModel,projRootDir,ccSettings,targetDir);
            if~isempty(sources)
                [srcPaths,srcNames,exts]=cellfun(@fileparts,sources,'UniformOutput',false);
                buildInfo.addSourceFiles(strcat(srcNames,exts));
                buildInfo.addSourcePaths(srcPaths);
            end
            if~isempty(includes)
                buildInfo.addIncludePaths(includes);
            end
            if~isempty(libraries)
                [libPaths,libNames,ext]=cellfun(@(x)fileparts(x),libraries,'UniformOutput',false);
                priority=800;
                precompiled=true;
                linkonly=true;
                groups='BlockModules';
                buildInfo.addLinkObjects(strcat(libNames,ext),libPaths,priority,precompiled,linkonly,groups);
            end
            if~isempty(ccSettings.customUserDefines)
                ccDefines=CGXE.CustomCode.extractUserDefines(ccSettings.customUserDefines);
                addDefines(buildInfo,ccDefines,'Custom');
            end