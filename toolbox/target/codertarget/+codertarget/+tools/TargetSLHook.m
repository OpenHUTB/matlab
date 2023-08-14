classdef TargetSLHook<matlab.mixin.SetGet




    methods(Access=public)
        function postCodeGenHookCommand(h,obj)
            hMdl=obj.ModelName;
            hCS=getActiveConfigSet(hMdl);
            h.verify(hCS);
            h.updateBuildInfoForFeatures(obj,hCS);
            h.updateBuildInfoForResourceManager(obj);
            h.addTargetsLinkObjects(obj);
            h.addProfilerDefines(obj);
            h.addStackDefines(obj);
            h.addSpecialDefines(obj);
            h.removeUnneededGeneratedFiles(obj);
            h.manageCPP(obj);
            h.createHardwareResourcesHeaderFile(hMdl,hCS);
            h.createProxyTaskDataFile(obj,hMdl,hCS);
            h.createTestingArtifactsFile(hMdl,hCS);
            h.manageScheduleEditor(obj,hMdl,hCS);
        end
    end

    methods(Access=private)
        function verify(h,hCS)
            h.verifyToolchain(hCS);
            h.verifyHardware(hCS);
            h.verifyCSValues(hCS);
            h.verifyLanguage(hCS);
            h.verifyIsNotSIL(hCS);
        end
        function verifyToolchain(~,hCS)
            ret=coder.internal.checkModelToolchainCompliance(hCS);
            if~ret.AllParamsCompliant
                msg='';
                for i=1:length(ret.Params)
                    if~ret.Params(i).IsCompliant
                        msg=sprintf('%s \n \t %s is set to %s, but it is expected to be set to %s',msg,...
                        ret.Params(i).Parameter,ret.Params(i).ActualValue,ret.Params(i).DefaultValue);
                    end
                end
                DAStudio.error('codertarget:build:IncompatibleWithCoderTarget',msg)
            end
        end
        function verifyHardware(~,hCS)
            board=get_param(hCS,'HardwareBoard');
            allBoards=codertarget.targethardware.getRegisteredTargetHardwareNames;
            [isSpPkgInstalled,missingBaseProduct]=...
            codertarget.utils.isSpPkgInstalledForSelectedBoard(hCS,board);
            if isequal(board,DAStudio.message('codertarget:build:DefaultHardwareBoardNameNone'))
                DAStudio.error('codertarget:build:TargetHardwareNotSelected');
            elseif isempty(allBoards)||~isSpPkgInstalled
                DAStudio.error('codertarget:build:SupportPackageNotInstalled',[missingBaseProduct,board],board,board);
            end
        end
        function verifyCSValues(~,hCS)
            if~slprivate('getIsExportFcnModel',hCS.getModel)&&...
                ~isequal(get_param(hCS,'GenerateSampleERTMain'),'off')
                DAStudio.error('codertarget:build:GenerateSampleMainError');
            end
        end
        function verifyLanguage(~,hCS)
            language=get_param(hCS,'TargetLang');
            attribInfo=codertarget.attributes.getTargetHardwareAttributes(hCS);
            if~supportsCppCodegen(attribInfo)&&~isequal(language,'C')
                DAStudio.error('codertarget:build:CPPNotSupported',language);
            end
            function ret=supportsCppCodegen(attribInfo)
                ret=false;
                tokenToMatch='_SUPPORTS_CPP_CODEGEN_';
                for i=1:length(attribInfo.Tokens)
                    ret=ret||isequal(attribInfo.Tokens{i}.Name,tokenToMatch);
                end
            end
        end
        function verifyIsNotSIL(~,hCS)
            if(strcmpi(get_param(hCS,'CreateSILPILBlock'),'SIL'))
                DAStudio.error('codertarget:build:SILNotSupported');
            end
        end
    end

    methods(Access=public,Hidden)

        function updateBuildInfoForFeatures(h,obj,hCS)
            buildInfo=obj.BuildInfo;
            language=get_param(hCS,'TargetLang');
            info=codertarget.attributes.getTargetHardwareAttributes(hCS);
            tokens=info.Tokens;



            allBCs=[h.getToolchainBuildConfigurationInfo(hCS)...
            ,h.getSchedulerBuildConfigurationInfo(hCS)...
            ,h.getExternalModeBuildConfigurationInfo(hCS)...
            ,h.getProfilerBuildConfigurationInfo(hCS),...
            h.getCPUSyncBuildConfigurationInfo(hCS),...
            h.getIPCBuildConfigurationInfo(hCS)];

            h.manageSourceFilesToSkip(obj,hCS,buildInfo,allBCs,tokens);
            h.manageSourceFiles(obj,hCS,buildInfo,allBCs,tokens);
            h.manageIncludePathsToRemove(hCS,buildInfo,allBCs,tokens);
            h.manageIncludePaths(hCS,buildInfo,allBCs,tokens);
            h.manageCompilerFlags(hCS,buildInfo,allBCs,tokens,language);
            h.manageLinkerFlags(hCS,buildInfo,allBCs,tokens,language);
            h.manageDefines(hCS,buildInfo,allBCs,tokens);
            h.manageLinkObjects(obj,hCS,buildInfo,allBCs,tokens);
        end
        function manageSourceFiles(h,obj,hCS,buildInfo,bcs,tokens)
            if h.isPIL(obj)||h.isSIL(obj)||~h.isExe(obj),return;end
            for i=1:numel(bcs)
                for j=1:length(bcs(i).SourceFiles)
                    [pathstr,name,ext]=fileparts(bcs(i).SourceFiles{j});
                    pathstr=codertarget.utils.replaceTokens(hCS,pathstr,tokens);
                    buildInfo.addSourceFiles([name,ext],pathstr,'SkipForInTheLoop');
                end
            end
        end
        function manageSourceFilesToSkip(h,obj,~,buildInfo,bcs,~)
            if h.isPIL(obj)||h.isSIL(obj)||~h.isExe(obj),return;end
            for i=1:numel(bcs)
                h.removeSourceFilesFromBuildInfo(buildInfo,bcs(i).SourceFilesToSkip);
            end
        end
        function manageIncludePaths(~,hCS,buildInfo,bcs,tokens)
            for i=1:numel(bcs)
                paths=codertarget.utils.replaceTokens(hCS,bcs(i).IncludePaths,tokens);
                for j=1:length(paths)
                    buildInfo.addIncludePaths(paths{j},'SkipForSil');
                end
            end
        end
        function manageIncludePathsToRemove(h,hCS,buildInfo,bcs,tokens)
            for i=1:numel(bcs)
                paths=codertarget.utils.replaceTokens(hCS,bcs(i).PathsToRemove);
                for j=1:length(paths)
                    h.removeIncludePaths(hCS,buildInfo,paths{j},tokens);
                end
            end
        end
        function manageCompilerFlags(~,hCS,buildInfo,bcs,tokens,~)
            for i=1:numel(bcs)




                flags=codertarget.utils.replaceTokens(hCS,bcs(i).CompileFlags,tokens);



                if~nnz(ismember(buildInfo.getCompileFlags,flags))
                    buildInfo.addCompileFlags(flags,'SkipForSil');
                end
            end
        end
        function manageLinkerFlags(~,hCS,buildInfo,bcs,tokens,~)
            for i=1:numel(bcs)




                flags=codertarget.utils.replaceTokens(hCS,bcs(i).LinkFlags,tokens);



                if~nnz(ismember(buildInfo.getLinkFlags,flags))
                    buildInfo.addLinkFlags(flags,'SkipForSil');
                end
            end
        end
        function manageDefines(~,hCS,buildInfo,bcs,tokens)
            for i=1:numel(bcs)
                flags=codertarget.utils.replaceTokens(hCS,bcs(i).Defines,tokens);
                buildInfo.addDefines(flags,'SkipForSil');
            end
        end
        function manageLinkObjects(h,obj,hCS,buildInfo,bcs,tokens)
            if h.isPIL(obj)||h.isSIL(obj)||~h.isExe(obj),return;end
            for i=1:numel(bcs)
                for j=1:length(bcs(i).LinkObjects)
                    if isstruct(bcs(i).LinkObjects{j})
                        name=codertarget.utils.replaceTokens(hCS,bcs(i).LinkObjects{j}.Name,tokens);
                        path=codertarget.utils.replaceTokens(hCS,bcs(i).LinkObjects{j}.Path,tokens);
                    else
                        linkObj=codertarget.utils.replaceTokens(hCS,bcs(i).LinkObjects{j},tokens);
                        [path,name,ext]=fileparts(linkObj);
                        name=[name,ext];%#ok<AGROW>
                    end
                    buildInfo.addLinkObjects(name,path,1000,true,true);
                end
            end
        end

        function updateBuildInfoForResourceManager(h,obj)
            hCS=getActiveConfigSet(obj.ModelName);
            buildInfo=obj.BuildInfo;
            attribInfo=codertarget.attributes.getTargetHardwareAttributes(hCS);
            tokens=attribInfo.Tokens;
            h.manageResourceManagerSourceFiles(hCS,buildInfo,tokens);
            h.manageResourceManagerIncludePaths(hCS,buildInfo);
            h.manageResourceManagerLinkObjects(hCS,buildInfo,tokens);
        end
        function manageResourceManagerSourceFiles(~,hCS,buildInfo,tokens)
            if codertarget.resourcemanager.isregistered('','CustomCode','SourceFiles',hCS)
                customSources=codertarget.resourcemanager.get('','CustomCode','SourceFiles',hCS);
            else
                customSources=0;
            end
            if isequal(customSources,0)
                customSources={};
            end
            if~iscell(customSources)&&~ischar(customSources)
                customSources={};
            end
            srcs=customSources;

            if ischar(srcs)
                srcs={srcs};
            end
            for i=1:length(srcs)
                srcs{i}=codertarget.utils.replaceTokens(hCS,srcs{i},tokens);
                [srcPath,srcName,srcExt]=fileparts(srcs{i});
                buildInfo.addSourceFiles([srcName,srcExt],srcPath,'SkipForSil');
            end
        end
        function manageResourceManagerIncludePaths(~,hCS,buildInfo)
            customPaths=codertarget.resourcemanager.get('','CustomCode','IncludePaths',hCS);
            if~iscell(customPaths)&&~ischar(customPaths)
                customPaths={};
            elseif~iscell(customPaths)
                customPaths={customPaths};
            end
            for i=1:length(customPaths)
                buildInfo.addIncludePaths(customPaths{i},'SkipForSil');
            end
        end
        function manageResourceManagerLinkObjects(~,hCS,buildInfo,tokens)
            if codertarget.resourcemanager.isregistered('','CustomCode','Libraries',hCS)
                customLibraries=codertarget.resourcemanager.get('','CustomCode','Libraries',hCS);
            else
                customLibraries=0;
            end
            if isequal(customLibraries,0)
                customLibraries={};
            end
            if~iscell(customLibraries)&&~ischar(customLibraries)
                customLibraries={};
            end
            libs=customLibraries;
            for i=1:length(libs)
                libs{i}=codertarget.utils.replaceTokens(hCS,libs{i},tokens);
                [path,name,ext]=fileparts(libs{i});
                buildInfo.addLinkObjects([name,ext],path,1000,true,true);
            end
        end
        function addSpecialDefines(~,obj)
            buildInfo=obj.BuildInfo;
            xilInfo=obj.MdlRefBuildArgs.XilInfo;
            isSIL=xilInfo.IsSil;
            if~isSIL


                buildInfo.addDefines('__MW_TARGET_USE_HARDWARE_RESOURCES_H__');
            end
            buildInfo.addDefines('RT','SkipForSil');
        end
        function addStackDefines(~,obj)
            hCS=getActiveConfigSet(obj.ModelName);
            buildInfo=obj.BuildInfo;
            stackSize=get_param(hCS,'MaxStackSize');
            if isequal(stackSize,'Inherit from target')
                DAStudio.error('codertarget:build:UndefinedStackSize');
            end
            buildInfo.addDefines(['STACK_SIZE=',stackSize],'SkipForSil');
        end
        function addTargetsLinkObjects(h,obj)
            hCS=getActiveConfigSet(obj.ModelName);
            buildInfo=obj.BuildInfo;
            if h.isPIL(obj)||h.isSIL(obj)||~h.isExe(obj),return;end
            attribInfo=codertarget.attributes.getTargetHardwareAttributes(hCS);
            tokens=attribInfo.Tokens;

            if codertarget.data.isParameterInitialized(hCS,'TargetLinkObj')
                modelPath=fileparts(get_param(obj.ModelName,'filename'));
                codeGenPath=getSourcePaths(buildInfo,1,'BuildDir');
                obj=codertarget.data.getParameterValue(hCS,'TargetLinkObj');
                [path,name,ext]=fileparts(obj.Name);
                name=codertarget.utils.replaceTokens(hCS,[name,ext],tokens);
                name=codertarget.utils.replacePathSep(name);
                path=codertarget.utils.replaceTokens(hCS,path,tokens);
                path=codertarget.utils.replacePathSep(path);
                if~isfile(fullfile(path,name))


                    if~isfile(fullfile(codeGenPath,'..',path,name))


                        if~isfile(fullfile(modelPath,path,name))
                            DAStudio.error('codertarget:build:LinkerCommandFileNotFound',name,path);
                        else
                            path=fullfile(modelPath,path);
                        end
                    else
                        path=fullfile(codeGenPath,'..',path);
                    end
                else

                end
                buildInfo.addLinkObjects(name,path,1000,true,true);
            end
        end
        function addProfilerDefines(h,obj)
            hCS=getActiveConfigSet(obj.ModelName);
            buildInfo=obj.BuildInfo;
            if h.isPIL(obj)||h.isSIL(obj)||~h.isExe(obj)
                return;
            end
            if codertarget.target.isCodeInstrumentationProfiling(obj.ModelName)...
                &&~coder.internal.xcp.isXCPTarget(hCS)
                buildInfo.addDefines('MW_STANDALONE_EXECUTION_PROFILER_ON');
            end
        end
        function manageCPP(h,obj)



            hCS=getActiveConfigSet(obj.ModelName);
            buildInfo=obj.BuildInfo;
            language=get_param(hCS,'TargetLang');
            if isequal(language,'C++')


                srcsToRemove={'ert_main.c','rt_cppclass_main.cpp'};
                h.removeSourceFilesFromBuildInfo(buildInfo,srcsToRemove);
                osInfo=codertarget.rtos.getTargetHardwareRTOS(hCS);
                if~isempty(osInfo)&&isequal(osInfo.Name,'Linux')

                    src(1).Name='linuxinitialize.cpp';
                    src(1).Path=fullfile('$(MATLAB_ROOT)','toolbox','target','codertarget','rtos','src');
                    h.replaceSrcFiles(buildInfo,{'linuxinitialize.c'},src,'SkipForInTheLoop');

                    buildInfo.addCompileFlags('-fpermissive','SkipForSil');
                end
            end
        end
        function removeUnneededGeneratedFiles(h,obj)
            buildInfo=obj.BuildInfo;
            h.removeSourceFilesFromBuildInfo(buildInfo,{'rt_main.c'});
            h.removeSourceFilesFromBuildInfo(buildInfo,{'rt_main.cpp'});
            h.removeSourceFilesFromBuildInfo(buildInfo,{'rt_main.cu'});

            buildInfo=obj.BuildInfo;
            if~h.isPIL(obj)&&~h.isSIL(obj),return;end
            if h.isSIL(obj)
                skipPattern={'MW_c28xx_','ert_main.c'};
            else
                skipPattern={'ert_main.c'};
            end
            for i=1:length(skipPattern)
                srcs=buildInfo.getSourceFiles(false,false);
                found=strfind(srcs,skipPattern{i});



                for j=numel(found):-1:1
                    if found{j}
                        buildInfo.Src.Files(j)=[];
                        buildInfo.addSourceFiles(srcs{j},'','SkipForInTheLoop');
                    end
                end
            end
        end
        function createTestingArtifactsFile(~,hMdl,hCS)
            if isequal(get_param(hMdl,'Description'),...
                'Save Coder Target Resources Info')
                resources=codertarget.resourcemanager.getAllResources(hCS);
                save('coderTargetResourcesInfo.mat','resources');
            end
        end
        function createHardwareResourcesHeaderFile(~,hMdl,hCS)


            codegenMgr=coder.internal.ModelCodegenMgr.getInstance(hMdl);
            if~isempty(codegenMgr)



                lCodeGenerationId=codegenMgr.CodeGenerationIdCurrentBuild;


                lCompileInfo=coder.make.internal.CompileInfoFile(pwd);

                lClientChecksum=coder.internal.getClientChecksumForCompile...
                ({},lCodeGenerationId);
                setClientChecksum(lCompileInfo,lClientChecksum);
                lClientChecksumsMatch=clientChecksumsMatch(lCompileInfo);


                isNewCode=~lClientChecksumsMatch...
                (coder.internal.CompileChecksum.CodeGenerationId);

                if isNewCode
                    codertarget.data.writeCoderTargetDataInclude(hCS);
                end
            else
                codertarget.data.writeCoderTargetDataInclude(hCS);
            end
        end
        function manageScheduleEditor(h,obj,topMdl,hCS)%#ok<INUSD>
            if codertarget.utils.isESBEnabled&&h.isExe(obj)
                mgrBlk=soc.internal.connectivity.getTaskManagerBlock(topMdl,true);
                if isempty(mgrBlk)||(iscell(mgrBlk)&&numel(mgrBlk)>1),return;end
                useSchedEditor=isequal(get_param(mgrBlk,'UseScheduleEditor'),'on');
                if useSchedEditor
                    origWarnState=warning('off','Simulink:Engine:NoDataUploadBlocks');
                    mdlBlk=soc.internal.connectivity.getModelConnectedToTaskManager(mgrBlk);
                    refMdl=get_param(mdlBlk,'ModelName');
                    refSchedule=get_param(refMdl,'Schedule');
                    if~isempty(refSchedule)
                        topSchedule=get_param(topMdl,'Schedule');
                        topPart=locGetPeriodicPartitionsSortedByIndex(topSchedule);
                        refPart=locGetPeriodicPartitionsSortedByIndex(refSchedule);
                        refList=arrayfun(@(x)x.Name,refPart,'UniformOutput',false);
                        topPart=locFilterOutPartitionsNotInRefList(topPart,refList);
                        if~locArePartitionsEquivalent(topPart,refPart)
                            msg=message('soc:scheduler:ScheduleNotUpdated',topMdl,refMdl);
                            diag=MSLException([],msg);
                            throw(diag);
                        end
                        save([topMdl,'Schedule'],'refSchedule');
                    end
                    warning(origWarnState);
                end
            end
            function res=locArePartitionsEquivalent(topPart,refPart)

                topPartNames=arrayfun(@(x)x.Name,topPart,'UniformOutput',false);
                refPartNames=arrayfun(@(x)x.Name,refPart,'UniformOutput',false);
                res=isequal(topPartNames,refPartNames);
            end
            function parts=locFilterOutPartitionsNotInRefList(parts,refList)
                for i=numel(parts):-1:1
                    if~ismember(parts(i).Name,refList)
                        parts(i)=[];
                    end
                end
            end
            function sortedParts=locGetPeriodicPartitionsSortedByIndex(schedule)
                parts=[];
                sortedParts=[];
                idx=0;
                for i=1:numel(schedule.Order.Partition)
                    thisPart=schedule.Order.Partition{i};
                    if isequal(schedule.Order.Type(thisPart),'Periodic')
                        idx=idx+1;
                        parts(idx).Name=thisPart;%#ok<AGROW> 
                        parts(idx).Idx=schedule.Order.Index(thisPart);%#ok<AGROW> 
                    end
                    if~isempty(parts)
                        [~,pos]=sort(arrayfun(@(x)x.('Idx'),parts));
                        sortedParts=parts(pos);
                    end
                end
            end
        end
        function createProxyTaskDataFile(h,obj,hMdl,hCS)%#ok<INUSD>
            if codertarget.utils.isESBEnabled&&h.isExe(obj)
                info=soc.internal.getProxyTaskInfo(hMdl);
                if info.hasProxyTask
                    opt='SkipForInTheLoop';
                    srcFileName='mw_cpuloadgenerator.c';
                    filePath=fullfile(matlabroot,'toolbox','target',...
                    'codertarget','rtos','src');
                    buildInfo=obj.BuildInfo;
                    buildInfo.addSourceFiles(srcFileName,filePath,opt);
                    fileName=['mw_',hMdl,'_proxytask_data'];
                    srcFileName=[fileName,'.c'];
                    filePath=pwd;
                    soc.internal.createProxyTaskDataFile(hMdl,fileName);
                    buildInfo.addSourceFiles(srcFileName,filePath,opt);
                    if(info.numEventDrivenAperiodic>0)
                        fileName=['mw_',hMdl,'_proxytask_event'];
                        srcFileName=[fileName,'.c'];
                        filePath=pwd;
                        soc.internal.createProxyTaskEventSourceFile(hMdl,fileName);
                        buildInfo.addSourceFiles(srcFileName,filePath,opt);
                    end
                end
            end
        end
    end

    methods(Access=private)
        function ret=isPIL(~,obj)
            xilInfo=obj.MdlRefBuildArgs.XilInfo;
            ret=xilInfo.IsPil;
        end
        function ret=isSIL(~,obj)
            xilInfo=obj.MdlRefBuildArgs.XilInfo;
            ret=xilInfo.IsSil;
        end
        function ret=isExe(~,obj)
            try
                mdlRefTgtType=get_param(obj.ModelName,'ModelReferenceTargetType');
                ret=isequal(mdlRefTgtType,'NONE');
            catch
                ret=true;
            end
        end
        function ret=isExternalMode(~,hCS)
            extModeRunning=codertarget.data.isParameterInitialized(hCS,'ExtMode.Running')...
            &&isequal(codertarget.data.getParameterValue(hCS,'ExtMode.Running'),'on');
            ret=isequal(get_param(hCS,'ExtMode'),'on')||extModeRunning;
        end
        function allBCs=getToolchainBuildConfigurationInfo(~,hCS)
            allBCs=[];
            attribInfo=codertarget.attributes.getTargetHardwareAttributes(hCS);
            selectedToolchain=get_param(hCS,'Toolchain');
            selectedOS=codertarget.targethardware.getTargetRTOS(hCS);
            if~isempty(attribInfo)
                allBCs=attribInfo.getBuildConfigurationInfo(...
                'toolchain',selectedToolchain,'os',selectedOS);
            end
        end
        function allBCs=getCPUSyncBuildConfigurationInfo(~,hCS)
            allBCs=[];
            procUnitInfo=codertarget.targethardware.getProcessingUnitInfo(hCS);
            selectedToolchain=get_param(hCS,'Toolchain');
            selectedOS=codertarget.targethardware.getTargetRTOS(hCS);
            if~isempty(procUnitInfo)
                cpuSyncInfo=procUnitInfo.getMasterSlaveSyncInfo;
                allBCs=cpuSyncInfo.getBuildConfigurationInfo(...
                'toolchain',selectedToolchain,'os',selectedOS);
            end
        end
        function allBCs=getIPCBuildConfigurationInfo(~,hCS)
            allBCs=[];
            ipcInfo=codertarget.ipc.getTargetHardwareIPC(hCS);
            selectedToolchain=get_param(hCS,'Toolchain');
            selectedOS=codertarget.targethardware.getTargetRTOS(hCS);
            if~isempty(ipcInfo)
                allBCs=ipcInfo.getBuildConfigurationInfo(...
                'toolchain',selectedToolchain,'os',selectedOS);
            end
        end
        function allBCs=getSchedulerBuildConfigurationInfo(~,hCS)
            allBCs=[];
            selectedToolchain=get_param(hCS,'Toolchain');
            selectedOS=codertarget.targethardware.getTargetRTOS(hCS);
            if isequal(selectedOS,'Baremetal')
                schedulerInfo=codertarget.scheduler.getTargetHardwareScheduler(hCS);
                if~isempty(schedulerInfo)
                    allBCs=schedulerInfo.getBuildConfigurationInfo(...
                    'toolchain',selectedToolchain,'os',selectedOS);
                end
            else
                osInfo=codertarget.rtos.getTargetHardwareRTOS(hCS);
                if~isempty(osInfo)
                    allBCs=osInfo.getBuildConfigurationInfo(...
                    'toolchain',selectedToolchain,'os',selectedOS);
                end
            end
        end
        function allBCs=getExternalModeBuildConfigurationInfo(h,hCS)
            allBCs=[];
            if h.isExternalMode(hCS)
                attribInfo=codertarget.attributes.getTargetHardwareAttributes(hCS);
                selectedToolchain=get_param(hCS,'Toolchain');
                selectedOS=codertarget.targethardware.getTargetRTOS(hCS);
                if codertarget.attributes.getAttribute(hCS,'EnableOneClick')
                    ioInterface=codertarget.data.getParameterValue(hCS,...
                    'ExtMode.Configuration');
                else
                    ioInterface='firstandonly';
                end
                extModeInfo=attribInfo.getExternalModeInfoForIOInterface(ioInterface);
                if~isempty(extModeInfo)
                    allBCs=extModeInfo.getBuildConfigurationInfo(...
                    'toolchain',selectedToolchain,'os',selectedOS);
                end
            end
        end
        function allBCs=getProfilerBuildConfigurationInfo(~,hCS)
            allBCs=[];
            if isequal(get_param(hCS,'CodeExecutionProfiling'),'on')


            end
        end
        function removeSourceFilesFromBuildInfo(~,buildInfo,srcFilesToSkip)
            for i=1:length(srcFilesToSkip)
                [~,srcFileName,fExt]=fileparts(srcFilesToSkip{i});
                [found,idx]=ismember([srcFileName,fExt],buildInfo.getSourceFiles(false,false));
                if(found)
                    buildInfo.Src.Files(idx)=[];
                end
            end
        end
        function removeIncludePaths(~,hCS,buildInfo,pathsToDel,tokens)

            idxPathsToDel=[];
            for j=1:length(buildInfo.Inc.Paths)
                buildInfoPath=buildInfo.Inc.Paths(j).Value;
                buildInfoPath=codertarget.utils.replaceTokens(hCS,...
                buildInfoPath,tokens);

                if strcmpi(pathsToDel,buildInfoPath)
                    idxPathsToDel=j;
                    break;
                end
            end
            if~isempty(idxPathsToDel)
                buildInfo.Inc.Paths(idxPathsToDel)=[];
            end
        end
        function replaceSrcFiles(~,buildInfo,origSrc,repSrc,group)
            for i=1:length(origSrc)
                srcs=buildInfo.getSourceFiles(false,false);
                found=strcmp(srcs,origSrc{i});
                buildInfo.Src.Files(found)=[];
                if any(found)
                    buildInfo.addSourceFiles(repSrc(i).Name,repSrc(i).Path,group);
                end
            end
        end
    end
end




