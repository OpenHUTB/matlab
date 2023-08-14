function processSFunctions(modelName,...
    lConfigSet,...
    lBuildInfo,...
    lBuildArgs,...
    lCodeFormat,...
    lStartDirToRestore,...
    lBuildDirectory,...
    lGenerateCodeOnly,...
    lSFunctionInfoList,...
    lSFunctionBuildInfo,...
    nonInlinedChildModelSFcnInfoForRaccel,...
    lPrecompTargetLibSuffix,...
    lBuildIsTMFBased)






    sfcn_group=coder.make.internal.BuildInfoGroup.SFunctionGroup;




    locProcessCustomCode(modelName,lBuildInfo,lConfigSet,...
    lCodeFormat,lStartDirToRestore,lBuildDirectory,sfcn_group);




    [lUniqueSfcnNames,lCorrespondingSfcnPaths]=...
    locProcessSFunctionInfoList(...
    lBuildInfo,...
    lSFunctionInfoList,...
    sfcn_group);





    locProcessMakeCfgFiles(modelName,...
    lBuildInfo,...
    lBuildArgs,...
    lGenerateCodeOnly,...
    lUniqueSfcnNames,...
    lCorrespondingSfcnPaths,...
    sfcn_group,...
    lPrecompTargetLibSuffix);




    locProcessSFunctionModuleInfo(...
    lBuildInfo,...
    modelName,...
    lSFunctionBuildInfo,...
    nonInlinedChildModelSFcnInfoForRaccel,...
    sfcn_group,...
    lBuildIsTMFBased);






    function locProcessCustomCode(modelName,lBuildInfo,lConfigSet,...
        lCodeFormat,lStartDirToRestore,lBuildDirectory,lSfcnGroup)


        rtwSettings=lConfigSet.getComponent('any','Code Generation');
        custCodeFiles=rtwprivate('rtw_resolve_custom_code',...
        modelName,lCodeFormat,...
        lStartDirToRestore,...
        lBuildDirectory,...
        rtwSettings.CustomInclude,...
        rtwSettings.CustomSource,...
        rtwSettings.CustomLibrary);

        if~isempty(custCodeFiles.parsedIncludePaths)
            lBuildInfo.addIncludePaths(custCodeFiles.parsedIncludePaths,lSfcnGroup);
        end
        if~isempty(custCodeFiles.parsedSrcPaths)
            lBuildInfo.addSourcePaths(custCodeFiles.parsedSrcPaths,'MDLREF');
        end


        function[lUniqueSfcnNames,lCorrespondingSfcnPaths]=...
            locProcessSFunctionInfoList(...
            lBuildInfo,...
            lSFunctionInfoList,...
            sfcn_group)


            [lUniqueSfcnNames,lCorrespondingSfcnPaths]=...
            locGetNamesFromSFunctionInfoList(lSFunctionInfoList);

            [sfunlist_IncludeDirs,sfunlist_SourceDirs]=locGetDirsFromSfcnNames(lUniqueSfcnNames,lCorrespondingSfcnPaths);


            if~isempty(sfunlist_IncludeDirs)
                lBuildInfo.addIncludePaths(sfunlist_IncludeDirs,sfcn_group);
            end


            if~isempty(sfunlist_SourceDirs)
                lBuildInfo.addSourcePaths(sfunlist_SourceDirs,'MDLREF');
            end





            function locProcessMakeCfgFiles(modelName,...
                lBuildInfo,...
                lBuildArgs,...
                lGenerateCodeOnly,...
                lUniqueSfcnNames,...
                lCorrespondingSfcnPaths,...
                sfcn_group,...
                lPrecompTargetLibSuffix)





                lConfigSet=getActiveConfigSet(modelName);
                sfcnMakeCfgSuffix='makecfg';


                [lSfunlist_SfcnMakeCfgFiles,lSfunlist_SfcnMakeCfgFilePaths]=...
                locGetMakeCfgFilesAndPaths(lUniqueSfcnNames,...
                lCorrespondingSfcnPaths,...
                sfcnMakeCfgSuffix);


                [simscape_sfcnMakeCfgFiles,simscape_sfcnMakeCfgFilePaths]=...
                locGetSimscapeSFunctionInfo(lConfigSet,sfcnMakeCfgSuffix);

                lSfcnMakeCfgFiles=[simscape_sfcnMakeCfgFiles(:)
                lSfunlist_SfcnMakeCfgFiles(:)];

                lSfcnMakeCfgFilePaths=[simscape_sfcnMakeCfgFilePaths(:)
                lSfunlist_SfcnMakeCfgFilePaths(:)];

                isPrecompBuild=contains(lBuildArgs,'PRECOMP_LIB_BUILD=1');



                set_param(0,'CurrentSystem',modelName);
                [tmpIncludeDirs,tmpSourceDirs,tmpAddSources,tmpLinkLibsObjs,...
                missingPrecomps]=coder.internal.runMakeCfgFiles...
                (lBuildInfo,lSfcnMakeCfgFiles,lSfcnMakeCfgFilePaths,...
                lGenerateCodeOnly,...
                isPrecompBuild,lBuildInfo.TargetPreCompLibLoc,...
                lPrecompTargetLibSuffix);

                includeDirs=tmpIncludeDirs(:);
                sourceDirs=tmpSourceDirs(:);
                addSources=tmpAddSources(:);
                linkLibsObjs=tmpLinkLibsObjs(:);


                if~isempty(missingPrecomps)




                    locMissingPrecompMsg(modelName,...
                    lBuildInfo.TargetPreCompLibLoc,...
                    missingPrecomps,lPrecompTargetLibSuffix);
                end



                [sfcnLibModsPaths,sfcnLibMods]=locFilepartsLinkLibObjs(linkLibsObjs);


                if~isempty(addSources)
                    srcPaths(1:length(addSources))={''};
                    lBuildInfo.addSourceFiles(addSources,srcPaths,'rtwmakecfg');
                end


                if~isempty(includeDirs)
                    lBuildInfo.addIncludePaths(includeDirs,sfcn_group);
                end


                if~isempty(sourceDirs)
                    lBuildInfo.addSourcePaths(sourceDirs,'MDLREF');
                end


                if~isempty(sfcnLibMods)


                    lBuildInfo.addLibraries(sfcnLibMods,sfcnLibModsPaths,...
                    1000,false,true,sfcn_group);
                end





                function locProcessSFunctionModuleInfo(...
                    lBuildInfo,...
                    modelName,...
                    lSFunctionBuildInfo,...
                    nonInlinedChildModelSFcnInfoForRaccel,...
                    sfcn_group,...
                    lBuildIsTMFBased)




                    lSystemTargetFile=strtrim(get_param(modelName,'SystemTargetFile'));
                    lRapidAcceleratorSimStatus=get_param(modelName,'RapidAcceleratorSimStatus');
                    searchPathExcludeGroups={'TFL','Standard','BuildDir','StartDir'};
                    searchPath=getSourcePaths(lBuildInfo,true,{},searchPathExcludeGroups);

                    [sourceFilesSFcn,...
                    sourceFilePathsSFcn,...
                    sfcnModListMakeVar,...
                    sfcnLibMods,...
                    sfcnLibModsPaths]=...
                    locGetSFunctionModuleInfo(...
                    lBuildIsTMFBased,...
                    lSFunctionBuildInfo,...
                    nonInlinedChildModelSFcnInfoForRaccel,...
                    searchPath,...
                    lSystemTargetFile);

                    if~isempty(sourceFilesSFcn)
                        addSourceFiles(lBuildInfo,sourceFilesSFcn,sourceFilePathsSFcn,sfcn_group);
                    end
                    if~isempty(sfcnModListMakeVar)

                        lBuildInfo.addMakeVars('S_FUNCTIONS',sfcnModListMakeVar);
                    end
                    if~isempty(sfcnLibMods)


                        lBuildInfo.addLibraries(sfcnLibMods,sfcnLibModsPaths,...
                        1000,false,true,sfcn_group);
                    end





                    if~strcmpi(lRapidAcceleratorSimStatus,'inactive')
                        notDynamicallyLoadedSFcnIndices=~[lSFunctionBuildInfo.willBeDynamicallyLoaded];
                        nonInlinedSFcnIndices=~[lSFunctionBuildInfo.isInlined];
                        sfcnsNeedingSourceCodeIndices=notDynamicallyLoadedSFcnIndices&nonInlinedSFcnIndices;
                        sfcnsNeedingSourceCode=lSFunctionBuildInfo(sfcnsNeedingSourceCodeIndices);
                        sfcnsNeedingSourceCode={sfcnsNeedingSourceCode.name};

                        if~isempty(sfcnsNeedingSourceCode)
                            coder.internal.lookForRapidAccelNonInlinedSFunctionFiles...
                            (lBuildInfo,modelName,sfcnsNeedingSourceCode)
                        end
                    end




                    function[uniqueSfcnNames,correspondingSfcnPaths]=locGetNamesFromSFunctionInfoList(lSFunctionInfoList)

                        sfcnNames=cell(1,length(lSFunctionInfoList));
                        sfcnPaths=cell(1,length(lSFunctionInfoList));

                        for i=1:length(lSFunctionInfoList)

                            if lSFunctionInfoList(i).isSkipped
                                continue
                            end


                            if~lSFunctionInfoList(i).isInlined&&lSFunctionInfoList(i).willBeDynamicallyLoaded
                                continue;
                            end




                            sfcnNames{i}=lSFunctionInfoList(i).sFcnName;



                            sfcnPaths{i}=fileparts(lSFunctionInfoList(i).sFcnPath);

                        end

                        nonEmptyIndices=cellfun(@(x)~isempty(x),sfcnNames);
                        sfcnNames=sfcnNames(nonEmptyIndices);
                        sfcnPaths=sfcnPaths(nonEmptyIndices);





                        [uniqueSfcnNames,correspondingSfcnPaths]=locGetUniqueSFcns(sfcnNames,sfcnPaths);



                        function[includeDirs,sourceDirs]=locGetDirsFromSfcnNames(uniqueSfcnNames,correspondingSfcnPaths)

                            includeDirs={};
                            sourceDirs={};
                            for i=1:numel(uniqueSfcnNames)
                                sfcnName=uniqueSfcnNames{i};
                                sfcnPath=correspondingSfcnPaths{i};






                                if(exist([sfcnPath,filesep,sfcnName,'.h'],'file')==2)
                                    includeDirs={includeDirs{:},sfcnPath};%#ok<CCAT>
                                end
                                if(exist([sfcnPath,filesep,sfcnName,'.c'],'file')==2)
                                    sourceDirs={sourceDirs{:},sfcnPath};%#ok<CCAT>
                                end
                                if(exist([sfcnPath,filesep,sfcnName,'.cpp'],'file')==2)
                                    sourceDirs={sourceDirs{:},sfcnPath};%#ok<CCAT>
                                end
                            end



                            function[uniqueSfcnName,correspondingSfcnPath]=locGetUniqueSFcns(sfcnNames,sfcnPaths)









                                uniqueSfcnName={};


                                correspondingSfcnPath={};

                                nSfcnNames=numel(sfcnNames);
                                nSfcnPath=0;
                                for k1=1:nSfcnNames
                                    if~isempty(sfcnPaths{k1})


                                        sfcnMatches=strcmp(uniqueSfcnName,sfcnNames{k1});
                                        if~any(sfcnMatches)
                                            nSfcnPath=nSfcnPath+1;
                                            uniqueSfcnName{nSfcnPath}=sfcnNames{k1};%#ok<AGROW>
                                            correspondingSfcnPath{nSfcnPath}=sfcnPaths{k1};%#ok<AGROW>
                                        else





                                            matchIdx=find(sfcnMatches,1);
                                            if~strcmp(sfcnPaths{k1},correspondingSfcnPath{matchIdx})
                                                DAStudio.error('RTW:buildProcess:nonUniqueSfunctionPath',sfcnNames{k1},sfcnPaths{k1},correspondingSfcnPath{matchIdx});
                                            end
                                        end
                                    end
                                end




                                function[sfcnMakeCfgFiles,sfcnMakeCfgFilePaths]=locGetSimscapeSFunctionInfo...
                                    (cs,sfcnMakeCfgSuffix)


                                    if~isempty(which('simscape.internal.register_rtwmakecfg'))
                                        sfcnMakeCfgFilePaths=simscape.internal.register_rtwmakecfg({},cs);
                                    else
                                        sfcnMakeCfgFilePaths={};
                                    end






                                    sfcnMakeCfgFiles=cell(size(sfcnMakeCfgFilePaths));
                                    for i=1:length(sfcnMakeCfgFilePaths)
                                        sfcnMakeCfgFiles{i}=sfcnMakeCfgSuffix;
                                    end

                                    function[sfcnMakeCfgFiles,sfcnMakeCfgFilePaths]=...
                                        locGetMakeCfgFilesAndPaths(lUniqueSfcnNames,...
                                        lCorrespondingSfcnPaths,...
                                        lSfcnMakeCfgSuffix)

                                        nUniqueSfcnNameAndPath=numel(lUniqueSfcnNames);
                                        sfcnMakeCfgFiles=cell(1,nUniqueSfcnNameAndPath);
                                        sfcnMakeCfgFilePaths=cell(1,nUniqueSfcnNameAndPath);

                                        for i=1:nUniqueSfcnNameAndPath


                                            sfcnMakeCfgFiles{i}=[lUniqueSfcnNames{i},'_',lSfcnMakeCfgSuffix];


                                            sfcnMakeCfgFilePaths{i}=lCorrespondingSfcnPaths{i};
                                        end

















                                        function locMissingPrecompMsg(modelName,loc,missingPrecomps,...
                                            lPrecompTargetLibSuffix)
                                            libStr='';
                                            rtwmakecfgStr='';



                                            ssname=coder.internal.SubsystemBuild.getSourceSubsysName;
                                            if~isempty(ssname)
                                                modelName=regexp(ssname,'^[^/]*','match');



                                                modelName=modelName{1};
                                            end

                                            libNames=cell(size(missingPrecomps));
                                            for i=1:length(missingPrecomps)
                                                [~,f,e]=fileparts(missingPrecomps(i).lib);
                                                libNames{i}=[f,e];
                                                libStr=sprintf('%s, %s\n',libStr,char(missingPrecomps(i).lib));
                                                rtwmakecfgStr=sprintf('%s ''%s''',rtwmakecfgStr,...
                                                char(missingPrecomps(i).rtwmakecfgDir));
                                            end
                                            libNames=join(string(libNames),', ');


                                            msg=message('RTW:buildProcess:missingPrecompiledLibraries',...
                                            loc,libNames,rtwmakecfgStr,lPrecompTargetLibSuffix,modelName);
                                            diag=MSLException([],msg);
                                            throw(diag);


                                            function[sfcnLibModsPaths,sfcnLibMods]=locFilepartsLinkLibObjs(linkLibsObjs)




                                                nLinkLibsObjs=numel(linkLibsObjs);
                                                sfcnLibModsPaths=cell(1,nLinkLibsObjs);
                                                sfcnLibMods=cell(1,nLinkLibsObjs);
                                                for i=1:nLinkLibsObjs

                                                    path=regexprep(linkLibsObjs{i},'^("|'')(.*)("|'')$','$2');
                                                    [sfcnLibModsPaths{i},libName,libExt]=fileparts(path);
                                                    sfcnLibMods{i}=[libName,libExt];
                                                end








                                                function[sourceFilesSFcn,...
                                                    sourceFilePathsSFcn,...
                                                    sfcnModListMakeVar,...
                                                    sfcnLibMods,...
                                                    sfcnLibModsPaths]=locGetSFunctionModuleInfo(...
                                                    lBuildIsTMFBased,...
                                                    lSFunctionBuildInfo,...
                                                    nonInlinedChildModelSFcnInfoForRaccel,...
                                                    searchPath,...
                                                    lSystemTargetFile)

                                                    currPath=path;
                                                    if~isempty(searchPath)
                                                        addpath(searchPath{:});
                                                        pathRestore=onCleanup(@()path(currPath));
                                                    end


                                                    isRaccel=strcmp(lSystemTargetFile,'raccel.tlc');







                                                    isSimOrAccel=any(strcmp(lSystemTargetFile,{'accel.tlc','modelrefsim.tlc'}));


                                                    inlinedIdx=[lSFunctionBuildInfo(:).isInlined];

                                                    if isRaccel

                                                        loadedDynamicallyIdx=[lSFunctionBuildInfo(:).willBeDynamicallyLoaded];



                                                        sFcnNames={lSFunctionBuildInfo(~loadedDynamicallyIdx&~inlinedIdx).name};


                                                        sFcnModulesTmp=[lSFunctionBuildInfo(~loadedDynamicallyIdx).modules];


                                                        topSFcnNames={lSFunctionBuildInfo(:).name};




                                                        childSFcnSources=i_getChildSourcesToBeBuiltByRaccelTop...
                                                        (nonInlinedChildModelSFcnInfoForRaccel,topSFcnNames);

                                                        sFcnModules=[sFcnNames,sFcnModulesTmp,childSFcnSources];
                                                    elseif isSimOrAccel

                                                        sFcnModules=[lSFunctionBuildInfo(inlinedIdx).modules];
                                                    else

                                                        sFcnNames={lSFunctionBuildInfo(~inlinedIdx).name};


                                                        sFcnModulesTmp=[lSFunctionBuildInfo(:).modules];

                                                        sFcnModules=[sFcnNames,sFcnModulesTmp];
                                                    end

                                                    if isempty(sFcnModules)
                                                        sFcnModules={};
                                                    else
                                                        sFcnModules=sFcnModules(cellfun(@(x)~isempty(x),sFcnModules));
                                                        sFcnModules=unique(sFcnModules,'stable');
                                                    end


                                                    linkModuleExts={'.lib','.a','.obj','.o'};
                                                    moduleExts=regexp(sFcnModules,'\.\w+$','once','match');
                                                    sFcnLinkModuleIdx=ismember(moduleExts,linkModuleExts);
                                                    sFcnLinkModules=sFcnModules(sFcnLinkModuleIdx);
                                                    sFcnSourceModules=sFcnModules(~sFcnLinkModuleIdx);


                                                    [sourceFilesSFcn,sourceFilePathsSFcn]=...
                                                    locProcessSFcnSourceModules(sFcnSourceModules,lBuildIsTMFBased);

                                                    [tmpSfcnLibMods,tmpSfcnLibModsPaths]=...
                                                    locProcessSFcnLinkModules(sFcnLinkModules);

                                                    sfcnLibMods=tmpSfcnLibMods(:);
                                                    sfcnLibModsPaths=tmpSfcnLibModsPaths(:);


                                                    sfcnModListMakeVar='';
                                                    if~isempty(sourceFilesSFcn)
                                                        if isequal(lSystemTargetFile,'rtwsfcn.tlc')||...
                                                            isequal(lSystemTargetFile,'accel.tlc')




                                                            sfcnModListMakeVar=regexprep(sourceFilesSFcn,'(.*)',' $1');
                                                            sfcnModListMakeVar=strcat(sfcnModListMakeVar{:});
                                                            sfcnModListMakeVar=sfcnModListMakeVar(2:end);
                                                        end
                                                    end






                                                    function[sfcnLibMods,sfcnLibModsPaths]=locProcessSFcnLinkModules(modules)

                                                        sfcnLibMods=cell(size(modules));
                                                        sfcnLibModsPaths=cell(size(modules));

                                                        for i=1:length(modules)
                                                            name=modules{i};
                                                            if~isempty(regexp(name,'\w+\.lib','once'))
                                                                sfcnLibMods{i}=name;
                                                                sfcnLibModsPaths{i}=fileparts(which(name));
                                                            elseif~isempty(regexp(name,'\w+\.a','once'))








                                                                if(isempty(dir(name))&&...
                                                                    length(name)>3&&...
                                                                    strcmp(name(1:3),'lib'))
                                                                    sfcnLibMods{i}=name;
                                                                else




                                                                    if(~isempty(dir(name)))
                                                                        sfcnLibMods{i}=name;
                                                                        sfcnLibModsPaths{i}=['.',filesep];
                                                                    else
                                                                        sfcnLibMods{i}=name;
                                                                        sfcnLibModsPaths{i}='$(START_DIR)';
                                                                    end
                                                                end
                                                            elseif~isempty(regexp(name,'\w+\.obj','once'))
                                                                sfcnLibMods{i}=name;
                                                                sfcnLibModsPaths{i}='$(START_DIR)';
                                                            else
                                                                assert(~isempty(regexp(name,'\w+\.o','once')),...
                                                                'Remaining possibility is a .o extension')

                                                                sfcnLibMods{i}=name;
                                                                sfcnLibModsPaths{i}='$(START_DIR)';
                                                            end
                                                        end



                                                        function candidateFileNames=locGetFileNameForModule(moduleName)

                                                            [~,~,e]=fileparts(moduleName);
                                                            hasExtension=~isempty(e);


                                                            extensionIsCOrCpp=any(strcmp(e,{'.c','.cpp'}));
                                                            if extensionIsCOrCpp
                                                                candidateFileNames={moduleName};
                                                                return
                                                            end


                                                            cName=[moduleName,'.c'];
                                                            cppName=[moduleName,'.cpp'];
                                                            candidateFileNames={cppName,cName};


                                                            if hasExtension
                                                                candidateFileNames{end+1}=moduleName;
                                                            end





                                                            function[sfcnMods,sfcnModsPaths]=locProcessSFcnSourceModules(modules,tmfBased)

                                                                sfcnMods=cell(size(modules));
                                                                sfcnModsPaths=cell(size(modules));

                                                                for i=1:length(modules)
                                                                    moduleName=modules{i};

                                                                    candidateFileNames=locGetFileNameForModule(moduleName);


                                                                    fileExists=false(size(candidateFileNames));
                                                                    for ii1=1:length(fileExists)
                                                                        fileExists(ii1)=(exist(candidateFileNames{ii1},'file')==2);
                                                                    end


                                                                    if sum(fileExists)>1
                                                                        DAStudio.error('RTW:buildProcess:duplicateSfcnModule',moduleName,...
                                                                        strjoin(candidateFileNames,', '));
                                                                    elseif sum(fileExists)==1
                                                                        sfcnMods{i}=candidateFileNames{fileExists};
                                                                    elseif tmfBased&&isempty(regexp(moduleName,'\.\w+$','once'))




                                                                        sfcnMods{i}=[moduleName,'.c'];
                                                                    else
                                                                        DAStudio.error('RTW:buildProcess:missingSfcnModule',moduleName);
                                                                    end



                                                                    sfcnModsPaths{i}=fileparts(which(sfcnMods{i}));
                                                                end




                                                                function childSFcnSources=i_getChildSourcesToBeBuiltByRaccelTop...
                                                                    (nonInlinedChildModelSFcnInfoForRaccel,topSFcnNames)


                                                                    allSFcnNames={nonInlinedChildModelSFcnInfoForRaccel(:).sFcnName};
                                                                    [~,childIdx]=setdiff(allSFcnNames,topSFcnNames);
                                                                    childSFcnInfo=nonInlinedChildModelSFcnInfoForRaccel(childIdx);


                                                                    loadedDynamicallyIdx=[childSFcnInfo(:).willBeDynamicallyLoaded];



                                                                    sFcnNames={childSFcnInfo(~loadedDynamicallyIdx).sFcnName};



                                                                    sFcnModulesTmp=[childSFcnInfo(~loadedDynamicallyIdx).modules];


                                                                    childSFcnSources=[sFcnNames,sFcnModulesTmp];



