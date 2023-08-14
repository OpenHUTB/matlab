classdef(Hidden=true)BuildHook<coder.coverage.BuildHook




    methods(Static=true)
        function val=useTopOfXilModelAsHost







            val=true;
        end
    end

    properties(Access=private)
        CleanupAfterCodeGenGlobals;
    end

    properties(Access=public)
        ConstructorArg;
    end
    methods(Access=private)
        function out=isExeAndNotXIL(this)
            modelName=this.getModelName;
            isStandaloneTarget=false;
            if bdIsLoaded(modelName)
                mdlRefTargetType=get_param(modelName,'ModelReferenceTargetType');
                isStandaloneTarget=strcmp(mdlRefTargetType,'NONE');
            end
            out=isStandaloneTarget&&~this.isSilBuild&&~this.isPilBuild;
        end

        function changeToInstrumentedCodeFolderIfProfiling(this,hCS)
            if isequal(get_param(hCS,'CodeExecutionProfiling'),'on')||...
                ~strcmp(get_param(hCS,'CodeProfilingInstrumentation'),'off')
                buildInfo=getComponentBuildInfo(this);
                lCodeDir=getSourcePaths(buildInfo,true,'BuildDir');
                if iscell(lCodeDir)
                    lCodeDir=lCodeDir{1};
                end
                [~,candidateObjFolderLastPart]=fileparts(lCodeDir);
                if~isequal(candidateObjFolderLastPart,'instrumented')
                    lCodeDir=fullfile(lCodeDir,'instrumented');
                end
                cd(lCodeDir);
            end
        end

        function usingSLC=isSLCUsed(this,mdlName)
            hCS=this.getComponentConfigSet;
            if~isa(hCS,'Simulink.ConfigSet')

                hCS=getActiveConfigSet(mdlName);
            end

            usingSLC=isequal(get_param(hCS,'IsSLCInUse'),'on');
        end

        function deleteTopModelSourceCode(~,buildFolder,modelName)


            targetDataMap=realtime.getTargetDataMapFileName(modelName,buildFolder);
            exeFile=codertarget.utils.getExecutableFile(modelName,buildFolder);
            makeFile=[modelName,'.mk'];
            filesToKeep={targetDataMap,exeFile,makeFile,...
            'buildInfo.mat','binfo.mat',...
            'minfo.mat','extmode_task_info.m','codedescriptor.dmr',...
            'codedescriptor_mf0.dmr'};



            extToKeep={'.lib','.a','.o','.tmw'};


            modelObjFiles=dir([modelName,'*.o']);
            objFilesToDelete={modelObjFiles.name,'ert_main.o'};

            files=dir(buildFolder);
            for i=1:length(files)
                if~files(i).isdir
                    fileName=files(i).name;
                    [~,~,fileExt]=fileparts(fileName);
                    if~ismember(fileExt,extToKeep)&&...
                        ~ismember(fileName,filesToKeep)
                        delete(fullfile(buildFolder,fileName));
                    end
                    if ismember(fileName,objFilesToDelete)
                        delete(fullfile(buildFolder,fileName));
                    end
                end
            end
        end

        function deleteRefModelSourceCode(this,buildFolder,modelName)%#ok<INUSL>



            models=find_mdlrefs(modelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
            for i=1:length(models)
                if~isequal(models{i},modelName)
                    refMdlDir=fullfile(buildFolder,'..','slprj','ert',models{i});
                    fileList=dir(refMdlDir);
                    for j=1:length(fileList)
                        if~fileList(j).isdir
                            delete(fullfile(refMdlDir,fileList(j).name));
                        end
                    end
                end
            end
        end
    end

    methods(Access=public,Hidden=true)
        function cleanResourcesAndCode(this,mdlName)
            hCS=getActiveConfigSet(mdlName);
            codertarget.resourcemanager.resetAllResources(hCS,true);
            targetType=get_param(mdlName,'ModelReferenceTargetType');
            isReferenceModel=~isequal(targetType,'NONE');




            if~isReferenceModel
                buildFolder=this.getBuildFolder;
                if isempty(buildFolder)
                    buildDir=RTW.getBuildDir(mdlName);
                    buildFolder=buildDir.BuildDirectory;
                end
                if~this.isSLCUsed(mdlName)
                    oldState=recycle('off');
                    try
                        this.deleteTopModelSourceCode(buildFolder,mdlName);
                        this.deleteRefModelSourceCode(buildFolder,mdlName);
                        recycle(oldState);
                    catch
                        recycle(oldState);
                    end
                end
            end
        end
    end

    methods(Access=public)

        function this=HBuildHook_A(constructorArg,varargin)
            if nargin<0
                this.ConstructorArg=constructorArg;
            else
                this.ConstructorArg=[];
            end
        end

        function entry(this)
            hCS=this.getComponentConfigSet;
            if codertarget.target.isCoderTarget(hCS)
                targetInfo=codertarget.attributes.getTargetHardwareAttributes(hCS);
                if~isempty(targetInfo.getOnBuildEntryHook)
                    try
                        feval(targetInfo.getOnBuildEntryHook,hCS);
                    catch ME
                        codertarget.resourcemanager.resetAllResources(...
                        hCS,true);
                        rethrow(ME);
                    end
                end
            end
        end

        function error(this)
            this.cleanResourcesAndCode;
            hCS=this.getComponentConfigSet;
            if codertarget.target.isCoderTarget(hCS)
                codertarget.resourcemanager.resetAllResources(hCS,true);
            end
        end

        function after_code_generation(this)
            hCS=this.getComponentConfigSet;
            if codertarget.target.isCoderTarget(hCS)
                targetInfo=codertarget.attributes.getTargetHardwareAttributes(hCS);
                hwInfo=codertarget.targethardware.getHardwareConfiguration(hCS);
                if codertarget.utils.isXCPBuild(hCS)
                    xcpMemConfig=codertarget.utils.XCPMemoryConfiguration(this.getModelName,this.getBuildFolder,this.getComponentBuildInfo);
                    xcpMemConfig.generate();
                end
                if~isempty(targetInfo.getOnAfterCodeGenHook)
                    buildInfo=this.getComponentBuildInfo;


                    codertarget.tools.AfterCodeGenGlobals.setIsNewGeneratedCode...
                    (this.IsNewGeneratedCode);
                    codertarget.tools.AfterCodeGenGlobals.setIsPil(this.isPilBuild);


                    this.CleanupAfterCodeGenGlobals=...
                    onCleanup(@codertarget.tools.AfterCodeGenGlobals.clear);
                    try
                        feval(targetInfo.getOnAfterCodeGenHook,hCS,buildInfo);
                    catch ME
                        codertarget.resourcemanager.resetAllResources(...
                        hCS,true);
                        rethrow(ME);
                    end
                    selectedToolChain=get_param(hCS,'Toolchain');
                    allowedToolChains={hwInfo.ToolChainInfo(:).Name};
                    [isMatch,idx]=ismember(selectedToolChain,allowedToolChains);
                    if isMatch
                        data=codertarget.data.getData(hCS);
                        toolchain=coder.make.internal.getToolchainInfoFromRegistry(selectedToolChain);
                        needsTC4LoadAndRun=~hwInfo.ToolChainInfo(idx).IsLoadCommandMATLABFcn...
                        &&isfield(data,'Runtime');
                        if needsTC4LoadAndRun
                            useToolchainToDownload=toolchain.PostbuildTools.isKey('Download');
                            useToolchainToExecute=toolchain.PostbuildTools.isKey('Execute');
                            lIsExeAndNotXIL=this.isExeAndNotXIL;
                            lBuildActions=[coder.make.enum.BuildAction.GENERATE_ARTIFACT,...
                            coder.make.enum.BuildAction.BUILD];
                            if lIsExeAndNotXIL&&useToolchainToDownload
                                if~isempty(regexpi(data.Runtime.BuildAction,'load'))
                                    lBuildActions=[lBuildActions,...
                                    coder.make.enum.BuildAction.DOWNLOAD];
                                    buildInfo.BuildTools.setBuildActions(lBuildActions);
                                end
                            end
                            if lIsExeAndNotXIL&&useToolchainToExecute
                                if~isempty(regexpi(data.Runtime.BuildAction,'execute'))
                                    lBuildActions=[lBuildActions,...
                                    coder.make.enum.BuildAction.EXECUTE];
                                    buildInfo.BuildTools.setBuildActions(lBuildActions);
                                end
                            end
                        end
                    end
                end
            end
        end

        function after_make(this)





            hCS=this.getComponentConfigSet;
            if codertarget.target.isCoderTarget(hCS)
                modelName=this.getModelName;
                if~Simulink.ModelReference.ProtectedModel.protectingModel(modelName)&&...
                    strcmp(get_param(hCS,'GenCodeOnly'),'off')
                    hwInfo=codertarget.targethardware.getHardwareConfiguration(hCS);
                    try
                        selectedToolChain=get_param(hCS,'Toolchain');
                        targetType=get_param(modelName,'ModelReferenceTargetType');
                        isReferenceModel=~isequal(targetType,'NONE');
                        if isprop(hwInfo,'ASAP2ToolInfo')&&...
                            ~isempty(hwInfo.ASAP2ToolInfo)&&...
                            ~isReferenceModel
                            feval(hwInfo.ASAP2ToolInfo,modelName,this.getBuildFolder);
                        end
                        allowedToolChains={hwInfo.ToolChainInfo(:).Name};
                        [isMatch,idx]=ismember(selectedToolChain,allowedToolChains);
                        if this.isExeAndNotXIL&&isMatch&&...
                            ~isempty(hwInfo.ToolChainInfo(idx).LoadCommand)
                            toolchainInfo=hwInfo.ToolChainInfo(idx);
                            data=codertarget.data.getData(hCS);
                            exeFile=codertarget.utils.getExecutableFile(modelName,...
                            this.getCodeGenFolder());
                            if isfield(data,'Runtime')
                                runTime=data.Runtime;
                                if~isequal(runTime.BuildAction,'Build')
                                    codertarget.utils.invokeDownloader(modelName,...
                                    hCS,toolchainInfo,exeFile);
                                end
                            else
                                codertarget.utils.invokeDownloader(modelName,...
                                hCS,toolchainInfo,exeFile);
                            end
                        end
                    catch ME
                        codertarget.resourcemanager.resetAllResources(...
                        hCS,true);
                        rethrow(ME);
                    end
                end
            end
        end

        function exit(this)

            cleanResourcesAndCode(this,this.getModelName);

            this.CleanupAfterCodeGenGlobals=[];
        end

        function envCmds=before_makefilebuilder_make(this)%#ok<STOUT,MANU> % e.g. PIL simulation
        end

        function envCmds=after_makefilebuilder_make(this)%#ok<STOUT,MANU> % e.g. PIL simulation
        end

        function after_on_target_execution(this)%#ok<MANU> % e.g. PIL simulation
        end
    end
end


