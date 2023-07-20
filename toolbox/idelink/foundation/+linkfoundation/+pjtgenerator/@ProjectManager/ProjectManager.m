classdef(Sealed=true)ProjectManager<handle





    properties(SetAccess='private')


        mAdaptorRegistry=[];

        mMatlabTarget=false;


        mERT=true;


        rtwBuildInProgress=false;


        mProjectBuildInfo=linkfoundation.pjtgenerator.ProjectBuildInfo;
        mBuildConfigurator=[];
        mChip=[];
        mOS=[];
        mAutomationHandle=[];
        mProject=[];
        mPjtGenInfo=[];
    end

    properties(Constant)
    end




    methods



        function h=ProjectManager(varargin)


            if nargin==1
                h.mERT=varargin{1};
            end
            h.mAdaptorRegistry=linkfoundation.pjtgenerator.AdaptorRegistry.manageInstance('get','EmbeddedIDELink');
        end




        function entry(h,modelName,rtwroot,tmf,buildOpts,buildArgs,buildInfo,targetBoard)
            if nargin==7
                targetBoard=[];
            end
            h.resetForBuild();
            h.initializeForBuild(modelName,rtwroot,tmf,buildOpts,buildArgs,buildInfo,targetBoard);


            rtw.targetNeedsCodeGen('set',true);


            h.mPjtGenInfo=lf_pjtgeninfo('getCache');
        end




        function before_tlc(h,modelName,rtwroot,tmf,buildOpts,buildArgs,buildInfo)%#ok<INUSD>

            lf_pjtgeninfo('setCache','','','','',h.mPjtGenInfo{1},h.mPjtGenInfo{2},h.mPjtGenInfo{3});
        end




        function after_tlc(h,modelName,rtwroot,tmf,buildOpts,buildArgs,buildInfo)%#ok<INUSD>

            h.saveRestoreModelProps_g336834('restore');



            h.mProjectBuildInfo.mCodeGenDir=pwd;
        end




        function before_make(h,modelName,rtwroot,tmf,buildOpts,buildArgs,buildInfo)%#ok<INUSD>

        end




        function after_make(h,modelName,rtwroot,tmf,buildOpts,buildArgs,buildInfo)%#ok<INUSL>

            if h.mBuildConfigurator.isSilBuild

                return
            end



            h.mProjectBuildInfo.mIRInfo=h.mBuildConfigurator.getSchedulerInfo();


            h.mProjectBuildInfo.mBuildInfo=buildInfo;
            h.mProjectBuildInfo.mOptions.buildOpts=buildOpts;
            h.mProjectBuildInfo.mOptions.tmf=tmf;


            h.mBuildConfigurator.controlValidateSystem('AfterMake',h.mProjectBuildInfo);


            h.createProject();
        end




        function exit(h,modelName,rtwroot,tmf,buildOpts,buildArgs,buildInfo)%#ok<INUSD>

            if h.mBuildConfigurator.isSilBuild

                return;
            end


            lInstrumentedCodeSubFolder=h.mProject.getInstrumentedSubFolder...
            (h.mProjectBuildInfo.mBuildInfo);
            if~isempty(lInstrumentedCodeSubFolder)

                prevFolder=cd(lInstrumentedCodeSubFolder);
                cdCleanup=onCleanup(@()cd(prevFolder));
            end


            h.mBuildConfigurator.controlValidateSystem('Exit',...
            h.mProjectBuildInfo,...
            h.mProject);

            h.preBuild();


            if h.mBuildConfigurator.getIsGenerateCodeOnlyInternal()
                h.resetForBuild();
                return
            end

            h.build();

            h.postBuild();

            h.resetForBuild();
        end




        function error(h,modelName,rtwroot,tmf,buildOpts,buildArgs,buildInfo)%#ok<INUSD>

            h.saveRestoreModelProps_g336834('restore');

            h.resetForBuild();
        end




        function ret=addToProject(h,type,addition)
            validTypes={'IncPath','Lib','LinkerOption',...
            'CompilerOption','PreProcSymbol','Src'};
            assert(any(strcmpi(type,validTypes)),['Invalid project type: ',type]);
            assert(~isempty(h.mProjectBuildInfo));
            current=h.mProjectBuildInfo.mAdditional.(type);
            h.mProjectBuildInfo.mAdditional.(type)=[current,addition];
            ret=1;
        end




        function updateTokens(h)

            h.mProjectBuildInfo.mTokens=struct(...
            'toolName','MATLAB',...
            'envVar','MATLAB_ROOT',...
            'value',matlabroot,...
            'processor','',...
            'type','built-in');



            if isequal(h.mProjectBuildInfo.mCGHook,'C2000')
                instalDir=codertarget.tic2000.internal.getSpPkgRootDir();
            elseif isequal(h.mProjectBuildInfo.mCGHook,'C6000')
                instalDir=tic6000.setup.internal.getSpPkgRootDir();
            else
                instalDir=h.mAdaptorRegistry.getTargetRoot(h.mProjectBuildInfo.mAdaptorName);
            end

            tmpToken=struct(...
            'toolName','SupportPackage',...
            'envVar','SUPPORT_PACKAGE_ROOT',...
            'value',instalDir,...
            'processor','',...
            'type','built-in');
            h.mProjectBuildInfo.mTokens=[tmpToken,h.mProjectBuildInfo.mTokens];


            tmpTokens=h.mChip.getAllTokens(h.mBuildConfigurator.getCurrentChipName());
            h.mProjectBuildInfo.mTokens=[tmpTokens,h.mProjectBuildInfo.mTokens];


            if~(h.mBuildConfigurator.getIsGenerateCodeOnlyInternal()||...
                h.mBuildConfigurator.isSilBuild)
                tmpTokens=struct(...
                'toolName','IDE',...
                'envVar','Install_dir',...
                'value',h.mAutomationHandle.getHomeDir,...
                'processor','',...
                'type','built-in');
                h.mProjectBuildInfo.mTokens=[tmpTokens,h.mProjectBuildInfo.mTokens];
            end

        end




        function preBuild(h)%#ok<MANU>


        end




        function postBuild(h)
            if(~isempty(h.mChip))



                modelInfo.tmf=h.mProjectBuildInfo.mOptions.tmf;
                modelInfo.name=h.mProjectBuildInfo.mModelName;
                modelInfo.rtwroot=h.mProjectBuildInfo.mOptions.rtwroot;
                modelInfo.buildOpts=h.mProjectBuildInfo.mOptions.buildOpts;
                modelInfo.buildArgs=h.mProjectBuildInfo.mOptions.buildArgs;
                modelInfo.buildInfo=h.mProjectBuildInfo.mBuildInfo;
                h.mChip.postProcess(modelInfo);
            end
        end




        function postCodeGen(h,projectInfo,buildInfo,configSet)

            h.mMatlabTarget=true;


            configSet.Name=projectInfo.Name;


            targetBoard=linkfoundation.util.getMATLABCodeGenTarget();





            hookpointArgs={projectInfo.Name,'rtwroot',configSet,...
            'buildOpts','buildArgs',buildInfo};


            h.entry(hookpointArgs{:},targetBoard);

            h.mProjectBuildInfo.mCodeGenDir=projectInfo.BldDirectory;

            h.after_make(hookpointArgs{:});

            h.exit(hookpointArgs{:});
        end






        function hChip=getChip(h)



            hChip=h.mChip;
        end

        function cgHook=queryCgHook(h)
            cgHook=h.mBuildConfigurator.getCGHook();
        end

        function ret=isRtwBuildInProgress(h)
            ret=h.rtwBuildInProgress;
        end

        function ret=isLibProject(h)
            ret=strcmp(h.mProjectBuildInfo.mBuildAction,'Archive_library');
        end

        function ret=isMatlabTargeting(h)
            ret=h.mMatlabTarget;
        end

        function retVal=get.mAdaptorRegistry(h)
            if(isa(h.mAdaptorRegistry,'linkfoundation.pjtgenerator.AdaptorRegistry')&&isvalid(h.mAdaptorRegistry))
                retVal=h.mAdaptorRegistry;
            else
                retVal=linkfoundation.pjtgenerator.AdaptorRegistry.manageInstance('get','EmbeddedIDELink');
                h.mAdaptorRegistry=retVal;
            end
        end
    end


    methods(Static=true)




        function rtwGenSettings=queryRTWSettings(modelName)
            adaptorRegistry=linkfoundation.pjtgenerator.AdaptorRegistry.manageInstance('get','EmbeddedIDELink');
            adaptorName=get_param(getActiveConfigSet(modelName),'AdaptorName');
            if(adaptorRegistry.isValidAdaptorName(adaptorName))

                rtwGenSettings.BuildDirSuffix=adaptorRegistry.getBuildFolderSuffix(adaptorName);

                rtwGenSettings.Version='1';

                [~,deviceType]=linkfoundation.pjtgenerator.ProjectManager.queryDevice(modelName);
                switch lower(deviceType)
                case 'c6000'
                    rtwGenSettings.StructByteAlignment='8';
                case 'blackfin'
                    rtwGenSettings.StructByteAlignment='4';
                end
            else

                if strcmpi(adaptorName,'none')

                    DAStudio.error('ERRORHANDLER:pjtgenerator:AdaptorNameNone');
                else

                    msg=linkfoundation.util.throwDeprecationMessage('AdaptorNotInstalled',adaptorName);
                    error(msg);
                end
            end
        end




        function tgtInfo=getTgtPrefInfo(modelname)
            try
                tgtInfo=getTgtPrefInfo(modelname);
            catch origEx
                newExc=MException('ERRORHANDLER:pjtgenerator:CannotGetTgtPrefInfo',DAStudio.message('ERRORHANDLER:pjtgenerator:CannotGetTgtPrefInfo'));
                lf_throwPjtGenError(newExc,origEx);
            end
        end





        function root=queryProductRoot(modelName)
            AdaptorRegistry=linkfoundation.pjtgenerator.AdaptorRegistry.manageInstance('get','EmbeddedIDELink');
            root=AdaptorRegistry.getProductRoot(get_param(getActiveConfigSet(modelName),'AdaptorName'));
        end

        function root=queryTargetRoot(modelName)
            AdaptorRegistry=linkfoundation.pjtgenerator.AdaptorRegistry.manageInstance('get','EmbeddedIDELink');
            root=AdaptorRegistry.getTargetRoot(get_param(getActiveConfigSet(modelName),'AdaptorName'));
        end

        function funcH=queryProcessorObjectFactory(AdaptorName)
            AdaptorRegistry=linkfoundation.pjtgenerator.AdaptorRegistry.manageInstance('get','EmbeddedIDELink');
            funcH=AdaptorRegistry.getProcessorObjectFactory(AdaptorName);
        end

        function funcH=queryOSObjectFactory(AdaptorName)
            AdaptorRegistry=linkfoundation.pjtgenerator.AdaptorRegistry.manageInstance('get','EmbeddedIDELink');
            funcH=AdaptorRegistry.getOSObjectFactory(AdaptorName);
        end

        function funcH=queryProjectOptions(AdaptorName)
            AdaptorRegistry=linkfoundation.pjtgenerator.AdaptorRegistry.manageInstance('get','EmbeddedIDELink');
            funcH=AdaptorRegistry.getProjectOptions(AdaptorName);
        end

        function preproc=queryPreProcessor(AdaptorName)
            AdaptorRegistry=linkfoundation.pjtgenerator.AdaptorRegistry.manageInstance('get','EmbeddedIDELink');
            preproc=AdaptorRegistry.getPreprocSymbols(AdaptorName);
        end

        function[deviceVendor,deviceType]=queryDevice(modelName)
            prodHWDevice=get_param(getActiveConfigSet(modelName),'ProdHWDeviceType');

            hh=targetrepository.getHardwareImplementationHelper();
            device=hh.getDevice(prodHWDevice);

            deviceType=device.Name;

            if isempty(device.Manufacturer)
                deviceVendor=device.Name;
            else
                deviceVendor=device.Manufacturer;
            end
        end

        function hTgt=queryTarget(modelName)
            cs=getActiveConfigSet(modelName);
            hTgt=linkfoundation.util.getTargetComponent(cs);
        end

    end


    methods(Access='private')




        function resetForBuild(h)
            h.rtwBuildInProgress=false;
            h.mProjectBuildInfo=linkfoundation.pjtgenerator.ProjectBuildInfo;
            h.mChip=[];
            h.mOS=[];
            h.mAutomationHandle=[];
            h.mProject=[];
            h.mBuildConfigurator=[];
        end




        function initializeForBuild(h,modelName,rtwroot,tmf,buildOpts,buildArgs,buildInfo,targetBoard)

            h.rtwBuildInProgress=true;


            if h.isMatlabTargeting

                h.mBuildConfigurator=linkfoundation.pjtgenerator.BuildConfiguratorML(tmf,targetBoard);
            else

                if isempty(get_param(modelName,'TargetHardwareResources'))
                    cs=getActiveConfigSet(modelName);
                    linkfoundation.util.initializeTargetHardwareResources(cs);
                end
                h.mBuildConfigurator=linkfoundation.pjtgenerator.BuildConfiguratorSL(modelName);
            end


            h.setProjectBuildInfoBeforeTgtInfoUpdate(buildInfo,rtwroot,tmf,buildOpts,buildArgs);


            if~h.isMatlabTargeting()

                if h.isCreateSILPILBlock('SIL')
                    error(message('ERRORHANDLER:pjtgenerator:SILNotSupported'));
                end

                if isequal(h.mBuildConfigurator.getConfigSetParam('TargetLang'),'C++')
                    error(message('ERRORHANDLER:pjtgenerator:CPPNotSupported'));
                end
            end


            if~h.isMatlabTargeting()
                if h.isPILProject()

                    h.mProjectBuildInfo.mPilConfigFile=h.mBuildConfigurator.getPilConfigFile();
                    h.mProjectBuildInfo.mPilBuildAction=h.mBuildConfigurator.getConfigSetParam('configPILBlockAction');
                    h.mProjectBuildInfo.mPilConfiguration=[];
                else

                    if h.isCreateSILPILBlock('PIL')
                        if h.isMakeFileBuild()
                            error(message('ERRORHANDLER:pjtgenerator:UnsupportedPILApproachForMakefile'));
                        else
                            error(message('ERRORHANDLER:pjtgenerator:PILIncorrectBuildAction'));
                        end
                    end
                end
            end


            if~h.isMatlabTargeting()
                h.saveRestoreModelProps_g336834('save');
            end




            h.mBuildConfigurator.verifyAndUpdateTargetInfo();



            h.checkCompatibilityForReference();


            h.setProjectBuildInfoAfterTgtInfoUpdate;


            h.createChip();

            if ismethod(h.mChip,'isSupportPackageInstalled')&&...
                ~h.mChip.isSupportPackageInstalled()
                chipName=h.mChip.ProdHWDeviceType();
                DAStudio.error('ERRORHANDLER:pjtgenerator:SupportPackageNotInstalled',...
                chipName,chipName,chipName);
            end

            if isequal(h.mProjectBuildInfo.mCGHook,'C2000')
                DAStudio.error('ERRORHANDLER:pjtgenerator:UAIDELink2CoderTarget_modelNotCompliant',modelName);
            end

            if ismethod(h.mChip,'getFamilyName')
                familyName=h.mChip.getFamilyName;
                packageFcn=['codertarget.internal.',lower(familyName),'.isBeingDeprecated'];
                packageFcnFile=which(packageFcn);
                if~isempty(packageFcnFile)
                    res=eval(packageFcn);
                    if res
                        MSLDiagnostic('ERRORHANDLER:pjtgenerator:SupportForProcessorDeprecated').reportAsWarning;
                    end
                end
            end


            h.createOS();


            h.mProjectBuildInfo.mIRInfo=h.mBuildConfigurator.controlSchedulerInfo('init');


            h.callDependent('SetEnvironment','');


            h.mBuildConfigurator.controlValidateSystem('Entry',h.mProjectBuildInfo);

            if~(h.mBuildConfigurator.getIsGenerateCodeOnlyInternal()||...
                h.mBuildConfigurator.isSilBuild)

                h.createAutomationHandle;

                h.setProjectBuildInfoForBuild;
            end


            h.updateTokens();

        end





        function setProjectBuildInfoBeforeTgtInfoUpdate(h,buildInfo,rtwroot,tmf,buildOpts,buildArgs)
            h.mProjectBuildInfo.mModelName=h.mBuildConfigurator.getName();
            h.mProjectBuildInfo.mBigEndian=strcmp(h.mBuildConfigurator.getEndianess(),'BigEndian');
            h.mProjectBuildInfo.mAdaptorName=h.mBuildConfigurator.getAdaptorName();
            h.mProjectBuildInfo.mBuildAction=h.mBuildConfigurator.getBuildAction();
            h.mProjectBuildInfo.mTimeout=h.mBuildConfigurator.getTimeout();
            h.mProjectBuildInfo.mBuildTimeout=h.mBuildConfigurator.getBuildTimeout();
            h.mProjectBuildInfo.mBuildConfig=h.mBuildConfigurator.getBuildConfig();
            h.mProjectBuildInfo.mStackSize=h.mBuildConfigurator.getStackSize();
            h.mProjectBuildInfo.mHeapSize=h.mBuildConfigurator.getHeapSize();
            h.mProjectBuildInfo.mBuildFormat=h.mBuildConfigurator.getBuildFormat();
            h.mProjectBuildInfo.mExportName=[];
            h.mProjectBuildInfo.mReferencedModelLibs=[];
            h.mProjectBuildInfo.mPreprocSymbolDelimiter=h.mAdaptorRegistry.getPreprocSymbolDelimiter(h.mProjectBuildInfo.mAdaptorName);
            h.mProjectBuildInfo.mIncludePathDelimiter=h.mAdaptorRegistry.getIncludePathDelimiter(h.mProjectBuildInfo.mAdaptorName);
            h.mProjectBuildInfo.mExportIDEObj=h.mBuildConfigurator.getExportIDEObj();
            if strcmpi(h.mProjectBuildInfo.mExportIDEObj,'on')
                h.mProjectBuildInfo.mExportName=h.mBuildConfigurator.getExportName();
            end
            h.mProjectBuildInfo.mModelReferenceTargetType=h.mBuildConfigurator.getModelReferenceTargetType();
            h.mProjectBuildInfo.mBuildInfo=buildInfo;
            if strcmp(h.mBuildConfigurator.getProfileGenCode(),'on')
                h.mProjectBuildInfo.mProfilingMethod=h.mBuildConfigurator.getProfilingMethod();
            else
                h.mProjectBuildInfo.mProfilingMethod='None';
            end
            h.mProjectBuildInfo.mTaskingMode=h.mBuildConfigurator.getTaskingMode();
            options=struct(...
            'rtwroot',rtwroot,...
            'tmf',tmf,...
            'buildOpts',buildOpts,...
            'buildArgs',buildArgs);
            h.mProjectBuildInfo.mOptions=options;
            h.mProjectBuildInfo.mConfigSet=h.mBuildConfigurator.getConfigSet();

        end





        function setProjectBuildInfoAfterTgtInfoUpdate(h)
            h.mBuildConfigurator.updateTargetRelatedProperties();
            h.mProjectBuildInfo.mTgtInfo=h.mBuildConfigurator.getTgtInfo();
            h.mProjectBuildInfo.mMvSwitch=h.mProjectBuildInfo.mTgtInfo.chipInfo.mvSwitch;
            h.mProjectBuildInfo.mCGHook=h.mBuildConfigurator.getCGHook();
            h.mProjectBuildInfo.mIDEOpts=h.mBuildConfigurator.getIDEOptions();
            h.mProjectBuildInfo.mChipName=h.mBuildConfigurator.getCurrentChipName();
            h.mProjectBuildInfo.mChipSubFamily=h.mBuildConfigurator.getCurrentChipSubFamily();
            h.mProjectBuildInfo.mOSName=h.mBuildConfigurator.getCurrentOSName();
        end





        function setProjectBuildInfoForBuild(h)

            h.mProjectBuildInfo.mProjectName=h.getFileNameFromAutomation('project-name');

            if h.isLibProject()
                h.mProjectBuildInfo.mBinaryName=h.getFileNameFromAutomation('library-name');
            else
                h.mProjectBuildInfo.mBinaryName=h.getFileNameFromAutomation('program-name');
            end
        end





        function checkCompatibilityForReference(h)
            if h.isMatlabTargeting
                return
            end
            if h.isReferencedModel()

                if~h.isLibProject()
                    if h.mProjectBuildInfo.mConfigSet.isValidParam('configurePIL')


                        set_param(h.mProjectBuildInfo.mConfigSet,'configurePIL','off');
                    end
                    set_param(h.mProjectBuildInfo.mConfigSet,'buildAction','Archive_library');
                    h.mProjectBuildInfo.mBuildAction='Archive_library';
                    set_param(h.mProjectBuildInfo.mConfigSet,'ProfileGenCode','off');
                    h.mProjectBuildInfo.mProfilingMethod='None';
                    warning(message('ERRORHANDLER:utils:InvalidBuildAction',h.mProjectBuildInfo.mModelName));
                end
            else

                if h.isExeProject()
                    slvr=h.mBuildConfigurator.getSolver();
                    if~strcmp(slvr,'FixedStepDiscrete')
                        error(message('ERRORHANDLER:pjtgenerator:InvalidSolver',h.mProjectBuildInfo.mModelName));
                    end
                end
            end
        end




        function ret=isExeProject(h)
            exeBuildActions={'Create','Create_project','Create_makefile','Build','Build_and_execute'};
            ret=any(strcmp(h.mProjectBuildInfo.mBuildAction,exeBuildActions));
        end




        function ret=isReferencedModel(h)
            ret=strcmp(h.mProjectBuildInfo.mModelReferenceTargetType,'RTW');
        end




        function ret=isPILProject(h)
            ret=strcmp(h.mProjectBuildInfo.mBuildAction,'Create_Processor_In_the_Loop_project');
        end




        function isCreateSILPILBlock=isCreateSILPILBlock(h,type)
            assert(strcmp(type,'SIL')||strcmp(type,'PIL'),'Type must be SIL or PIL');
            isCreateSILPILBlock=false;
            if h.mERT
                createSILPILBlock=h.mBuildConfigurator.getCreateSILPILBlock();
                if strcmp(createSILPILBlock,type)
                    isCreateSILPILBlock=true;
                end
            end
        end




        function ret=isProfilingRequested(h)
            ret=~strcmp(h.mProjectBuildInfo.mProfilingMethod,'None');
        end




        function ret=isExecuteProject(h)
            ret=strcmp(h.mProjectBuildInfo.mBuildAction,'Build_and_execute');
        end




        function ret=isBuildProject(h)
            needsBuild={'Archive_library','Build','Build_and_execute'};
            ret=any(strcmp(h.mProjectBuildInfo.mBuildAction,needsBuild));
        end




        function ran=callDependent(h,action,varargin)



            modelInfo.tmf=h.mProjectBuildInfo.mOptions.tmf;
            modelInfo.name=h.mProjectBuildInfo.mModelName;
            modelInfo.rtwroot=h.mProjectBuildInfo.mOptions.rtwroot;
            modelInfo.buildOpts=h.mProjectBuildInfo.mOptions.buildOpts;
            modelInfo.buildArgs=h.mProjectBuildInfo.mOptions.buildArgs;
            modelInfo.buildInfo=h.mProjectBuildInfo.mBuildInfo;




            if lf_existTgtPjtGenHookpoint(action,...
                h.mProjectBuildInfo.mCGHook,...
                h.mProjectBuildInfo.mTgtInfo,...
                h.mProjectBuildInfo.mBuildAction)
                tf_invokePjtGenHookpoint(action,modelInfo,varargin{:});
                ran=true;
            else
                ran=false;
            end
        end




        function createChip(h)
            funcHandle=h.queryProcessorObjectFactory(h.mProjectBuildInfo.mAdaptorName);
            h.mChip=funcHandle('chip',h.mProjectBuildInfo);
        end




        function createOS(h)
            if strcmp(h.mProjectBuildInfo.mOSName,'None')
                h.mOS=linkfoundation.pjtgenerator.OS;
                h.mOS.name='BareBoard';
                h.mOS.alias='bareboard';
                h.mOS.maxRealTimePriority=inf;
                h.mOS.minRealTimePriority=-inf;
                h.mOS.minSystemStackSize=0;
                h.mOS.mainIsAThread=1;
                h.mOS.isProcessorAware=1;
                h.mOS.baseRatePriority=40;
            else
                funcHandle=h.queryOSObjectFactory(h.mProjectBuildInfo.mAdaptorName);
                h.mOS=funcHandle(h.mProjectBuildInfo);
                if isfield(h.mProjectBuildInfo.mTgtInfo,'OS')
                    h.mOS.schedulingMode=h.mProjectBuildInfo.mTgtInfo.OS.schedulingMode;
                    h.mOS.baseRatePriority=h.mProjectBuildInfo.mTgtInfo.OS.baseRatePriority;
                end
            end
        end




        function createAutomationHandle(h)
            if h.isMakeFileBuild()
                if h.isLibProject()

                    pjttype=1;
                else

                    pjttype=0;
                end
                h.mAutomationHandle=linkfoundation.xmakefile.XMakefile(...
                'pjtname',h.mProjectBuildInfo.mModelName,...
                'pjttype',pjttype);
            else
                funcHandle=h.mAdaptorRegistry.getAutomationFactoryHandle(h.mProjectBuildInfo.mAdaptorName);
                h.mAutomationHandle=funcHandle(h.mProjectBuildInfo);
            end
        end




        function liblist=getReferencedModelLib(h)
            liblist='';
            for i=1:length(h.mProjectBuildInfo.mBuildInfo.ModelRefs)
                liblist{i}=h.getModelRefLibName(...
                h.mProjectBuildInfo.mBuildInfo.ModelRefs(i).Path,...
                h.mProjectBuildInfo.mBuildInfo.ModelRefs(i).Name);
            end
        end




        function liblist=getPILReferencedModelLib(h)

            liblist={};
            if~isempty(h.mProjectBuildInfo.mProjectName)
                lInstrumentedCodeSubFolder=...
                h.mProject.getInstrumentedSubFolder...
                (h.mProjectBuildInfo.mBuildInfo);
                liblist{1}=h.getModelRefLibName...
                (lInstrumentedCodeSubFolder,h.mProjectBuildInfo.mProjectName);
            end

            locCodeGenDir=h.mProjectBuildInfo.mCodeGenDir;
            h.mProjectBuildInfo.mCodeGenDir=h.mProjectBuildInfo.mCodeGenDir(...
            1:strfind(h.mProjectBuildInfo.mCodeGenDir,'slprj')+4);
            liblist=[liblist,h.getReferencedModelLib()];
            h.mProjectBuildInfo.mCodeGenDir=locCodeGenDir;
        end




        function fullname=getModelRefLibName(h,libPath,libName)


            [~,baseMdlRefName,ext]=fileparts(libName);%#ok<NASGU>
            baseLibName=strrep(baseMdlRefName,'_rtwlib','');






            libPathFcn=h.mAdaptorRegistry.getFullLibPathFcn(h.mProjectBuildInfo.mAdaptorName);
            fullname=libPathFcn(h.mProjectBuildInfo,libPath,baseLibName);

        end




        function callChip(h)



            lInstrumentedCodeSubFolder=...
            h.mProject.getInstrumentedSubFolder...
            (h.mProjectBuildInfo.mBuildInfo);
            if~isempty(lInstrumentedCodeSubFolder)

                prevFolder=cd('..');
                cdCleanup=onCleanup(@()cd(prevFolder));
            end

            h.mChip.generateCacheFunctions(h.mProject,h.mProjectBuildInfo.mModelName,h.mBuildConfigurator.getTgtInfo());
            h.mChip.writeCslHeaderEpilog;


            if~isempty(lInstrumentedCodeSubFolder)
                allCslFiles=dir('MW_*_csl.*');
                for i=1:length(allCslFiles)
copyfile...
                    (allCslFiles(i).name,...
                    fullfile(lInstrumentedCodeSubFolder,allCslFiles(i).name));
                end
            end






            if h.mBuildConfigurator.getIsRealTime()


                tgtInfo=h.mBuildConfigurator.getTgtInfo();
                tgtInfo.CodeInstrFolder=lInstrumentedCodeSubFolder;

                lnkCmdFile=h.mChip.generateLinkerCMDFile(h.mProjectBuildInfo.mModelName,...
                tgtInfo,...
                h.mProjectBuildInfo.mIRInfo);

                if~h.isLibProject()
                    group='SkipForSil';
                    h.mProject.addSourceFiles(lnkCmdFile,group);
                else
                    lnkCmdFile=fullfile(pwd,lnkCmdFile);
                    h.mProjectBuildInfo.markForRemovalFromLibPjt(lnkCmdFile);
                    h.mProjectBuildInfo.markForPILPjt(lnkCmdFile);
                end





                if isequal(h.mOS.alias,'bareboard')
                    vectorsFile='vectors.asm';
                    if h.mChip.generateVectors(vectorsFile,...
                        h.mBuildConfigurator.getTgtInfo(),...
                        h.mProjectBuildInfo.mIRInfo)
                        h.mProject.addSourceFiles(vectorsFile,'SkipForSil');

                        if~h.isLibProject()
                            vectorsFile=fullfile(pwd,vectorsFile);
                            h.mProjectBuildInfo.markForRemovalFromLibPjt(vectorsFile);
                            h.mProjectBuildInfo.markForPILPjt(vectorsFile);
                        end
                    end
                end


                if(isfield(h.mProjectBuildInfo.mIRInfo,'asmFileName')&&...
                    ~isempty(h.mProjectBuildInfo.mIRInfo.asmFileName)&&...
                    (exist(h.mProjectBuildInfo.mIRInfo.asmFileName,'file')==2))
                    h.mProject.addSourceFiles(h.mProjectBuildInfo.mIRInfo.asmFileName,'SkipForSil');
                end


                if~h.isLibProject()
                    procLibs=h.mChip.getProcLibraries(...
                    h.mBuildConfigurator.getTgtInfo(),...
                    h.mProjectBuildInfo.mIRInfo);
                    h.mProject.addLibraries(procLibs);
                end
            end




            if linkfoundation.pil.isTCPIPPILEnabled
                h.mProjectBuildInfo.mPilConfiguration='TCP/IP';
            else
                h.mProjectBuildInfo.mPilConfiguration=h.mChip.getFamilyName();
            end
        end




        function callOS(h)
            if(h.mOS.needsAdditionalFiles)
                osFiles=h.mOS.generateAdditionalFiles(h);
                h.mProject.addSourceFiles(osFiles,'BuildDir');
            end
            h.mProject.addSourceFiles(h.mOS.getSourceFiles);
            h.mProject.addLibraries(h.mOS.getLibraries);
            h.mProject.addIncludePaths(h.mOS.getIncludePaths);
            h.mProject.addPreprocessorSymbols(h.mOS.getPreprocessorSymbols);
            h.mProject.addCompilerOption(h.mOS.getCompilerOptions);
            h.mProject.addLinkerOption(h.mOS.getLinkerOptions);
        end




        function createProject(h)

            h.mProject=linkfoundation.pjtgenerator.Project(h);


            lInstrumentedCodeSubFolder=h.mProject.getInstrumentedSubFolder...
            (h.mProjectBuildInfo.mBuildInfo);
            if~isempty(lInstrumentedCodeSubFolder)

                prevFolder=cd(lInstrumentedCodeSubFolder);
                cdCleanup=onCleanup(@()cd(prevFolder));
            end

            isLibPjt=h.isLibProject();

            if isLibPjt
                h.mProjectBuildInfo.mReferencedModelLibs=h.getPILReferencedModelLib();
            else

                try
                    h.mProject.addLibraries(h.getReferencedModelLib());
                catch origEx
                    newExc=MException('ERRORHANDLER:pjtgenerator:CannotAddLibsToProject',DAStudio.message('ERRORHANDLER:pjtgenerator:CannotAddLibsToProject'));
                    lf_throwPjtGenError(newExc,origEx);
                end
            end

            h.callChip();

            try

                tokens=h.mProjectBuildInfo.mTokens;
                srcs=h.mBuildConfigurator.getListOfBoardSourceFiles();
                for i=1:length(srcs)
                    if~isempty(srcs{i})
                        srcs{i}=tgtLibEvalTokens(srcs{i},tokens,'src',false);
                    end
                end
                h.mProject.addSourceFiles(srcs,'CustomCode');
                h.mProject.addSourceFiles(h.mProjectBuildInfo.mAdditional.Src,'BuildDir');

                if~h.mERT
                    h.mProject.addSourceFiles(fullfile(matlabroot,'rtw','c','src','rt_sim.c'),'BuildDir');
                end

                paths=h.mBuildConfigurator.getListOfIncludePaths();
                for i=1:length(paths)
                    if~isempty(paths{i})
                        paths{i}=tgtLibEvalTokens(paths{i},tokens,'inc',false);
                    end
                end

                h.mProject.addIncludePaths(paths,'put-on-top');
                h.mProject.addIncludePaths(h.mProjectBuildInfo.mAdditional.IncPath);


                dspIncludesFolder=fullfile(matlabroot,'toolbox','dspblks','include');
                if(exist(dspIncludesFolder,'dir')==7)
                    h.mProject.addIncludePaths({dspIncludesFolder});
                    h.mProject.addIncludePaths({fullfile(matlabroot,'toolbox','rtw','dspblks','c')});
                end

                Libraries=h.mBuildConfigurator.getListOfLibraries(h.mProjectBuildInfo.mBigEndian);
                for i=1:length(Libraries)
                    if~isempty(Libraries{i})
                        Libraries{i}=tgtLibEvalTokens(Libraries{i},tokens,'src',false);
                    end
                end

                h.mProject.checkAndAddReqdLibraries(Libraries);
                h.mProject.addLibraries(h.mProjectBuildInfo.mAdditional.Lib);

                h.mProject.addPreprocessorSymbols(h.mBuildConfigurator.getListOfPreProc());
                h.mProject.addPreprocessorSymbols(h.mProjectBuildInfo.mAdditional.PreProcSymbol);

                h.mProject.addPreprocessorSymbols(h.queryPreProcessor(h.mProjectBuildInfo.mAdaptorName));
                h.mProject.addPreprocessorSymbols({'RT','USE_RTMODEL'});

                h.mProject.addCompilerOption(h.mProjectBuildInfo.mCompilerOptions,'put-on-top');
                h.mProject.addCompilerOption(h.mBuildConfigurator.getListOfCompilerOptions());

                if h.isPILProject()
                    h.mProject.addCompilerOption({'-g'});
                end

                if h.isProfilingRequested()
                    h.mProject.addCompilerOption(h.getProfilingBuildOptions(h.mProjectBuildInfo.mAdaptorName));
                end

                h.mProject.addCompilerOption(h.mProjectBuildInfo.mAdditional.CompilerOption);

                h.mProject.addLinkerOption(h.mProjectBuildInfo.mLinkerOptions,'put-on-top');
                h.mProject.addLinkerOption(h.mBuildConfigurator.getListOfLinkerOptions());
                h.mProject.addLinkerOption(h.mProjectBuildInfo.mAdditional.LinkerOption);

                h.addAdditionalProjectOptions();


                if h.isProfilingRequested()
                    h.mProject.addSourceFiles(fullfile(matlabroot,'toolbox','idelink','foundation','pjtgenerator','profiler','profile.c'),'BuildDir');
                    h.mProject.addIncludePaths({fullfile(matlabroot,'toolbox','idelink','foundation','pjtgenerator','profiler')});
                    h.mProject.addPreprocessorSymbols({'PROFILING_ENABLED'});


                    S=accessPersistentProfileInfo;
                    if isfield(S,'sys')
                        h.mProject.addPreprocessorSymbols({'PROFILE_SUBSYSTEMS'...
                        ,['NUMSUBSYS=',num2str(length(S.sys))]});
                    end


                    h.mProject.addPreprocessorSymbols(...
                    {['NUM_ISRS=',num2str(h.mProjectBuildInfo.mIRInfo.numInterrupts-h.mProjectBuildInfo.mIRInfo.numInterruptsInclBaseRate)]});


                    h.mProject.addPreprocessorSymbols(...
                    {['NUM_IDLETASKS=',num2str(h.mProjectBuildInfo.mIRInfo.numIdleTasks)]});
                end

            catch pjtException
                newExc=MException('ERRORHANDLER:pjtgenerator:ProjectObjectCreationError',DAStudio.message('ERRORHANDLER:pjtgenerator:ProjectObjectCreationError'));
                lf_throwPjtGenError(newExc,pjtException);
            end



            h.mProject.update();






            h.callOS();




            h.saveBuildInfoMatFile();
        end





        function build(h)



            artifact=h.mProjectBuildInfo.mBuildFormat;
            try

                disp(['### Creating ',lower(artifact),': ',h.getFileNameFromAutomation('project')]);
                h.mAutomationHandle.emitProject(h.mProjectBuildInfo);
                disp(['### ',artifact,' creation done.']);

            catch pjtException
                newExc=MException('ERRORHANDLER:pjtgenerator:ProjectCreationError',DAStudio.message('ERRORHANDLER:pjtgenerator:ProjectCreationError'));
                lf_throwPjtGenError(newExc,pjtException);
            end




            try
                h.mAutomationHandle.save(h.getFileNameFromAutomation('project'),'project');
            catch pjtException
                newExc=MException('ERRORHANDLER:pjtgenerator:ProjectSaveError',DAStudio.message('ERRORHANDLER:pjtgenerator:ProjectSaveError'));
                lf_throwPjtGenError(newExc,pjtException);
            end




            if h.mBuildConfigurator.getIsGenerateCodeOnly()
                return;
            end




            try
                if h.isBuildProject
                    disp(['### Building ',lower(artifact),'...']);
                    h.mAutomationHandle.halt();
                    h.mAutomationHandle.build();
                    disp('### Build done.');
                end
            catch pjtException


                h.exportIDEObjectToWorkspace;
                newExc=MException('ERRORHANDLER:pjtgenerator:ProjectBuildError',DAStudio.message('ERRORHANDLER:pjtgenerator:ProjectBuildError'));
                lf_throwPjtGenError(newExc,pjtException);
            end




            try

                specialLoadExecuteDone=h.callDependent('LoadExecute',...
                h.mProjectBuildInfo.mBuildAction,...
                h.getFileNameFromAutomation('program'),...
                h.mAutomationHandle,...
                h.mBuildConfigurator.getTgtInfo());

                if~specialLoadExecuteDone



                    if(h.isExecuteProject&&~h.isPILProject)
                        if~h.isMakeFileBuild
                            disp(['### Downloading program: ',h.getFileNameFromAutomation('program')]);
                            h.mAutomationHandle.executeProject(h.mProjectBuildInfo);
                            disp('### Download done.');
                        else
                            disp(DAStudio.message('ERRORHANDLER:pjtgenerator:MakeExecuteToolCall',h.getFileNameFromAutomation('program')));
                            h.mAutomationHandle.executeProject(h.mProjectBuildInfo);
                        end
                    end
                end
            catch pjtException
                newExc=MException('ERRORHANDLER:pjtgenerator:LoadRunError',DAStudio.message('ERRORHANDLER:pjtgenerator:LoadRunError'));
                lf_throwPjtGenError(newExc,pjtException);
            end




            h.exportIDEObjectToWorkspace;




            try
                if h.isPILProject

                    h.mAutomationHandle.pilStoreTargetInfo(h.mProjectBuildInfo);
                end
            catch pjtException

                rethrow(pjtException);
            end







            h.mAutomationHandle.logProjectInfo(h.mProjectBuildInfo);
        end




        function addAdditionalProjectOptions(h)
            funcHandle=h.queryProjectOptions(h.mProjectBuildInfo.mAdaptorName);
            opt=funcHandle(h.mProjectBuildInfo);
            if(~isempty(opt))


                if(~isempty(opt.Compiler))
                    h.mProject.addCompilerOption(opt.Compiler);
                end
                if(~isempty(opt.Linker))
                    h.mProject.addLinkerOption(opt.Linker);
                end
            end
        end




        function ret=getFileNameFromAutomation(h,filetype)
            if strcmpi(h.mProjectBuildInfo.mBuildFormat,'Makefile')
                ret=[h.mProjectBuildInfo.mModelName,...
                h.mAutomationHandle.ide_getFileExt(strrep(filetype,'-name',''))];
                if~any(strfind(filetype,'-name'))
                    if strcmpi(filetype,'program')
                        ret=fullfile(h.mProjectBuildInfo.mCodeGenDir,...
                        [get_param(h.mProjectBuildInfo.mModelName,'projectOptions'),'MW'],...
                        ret);
                    else
                        ret=fullfile(h.mProjectBuildInfo.mCodeGenDir,ret);
                    end
                end
            else
                artifactFcn=h.mAdaptorRegistry.getCodeGenArtifactFcn(h.mProjectBuildInfo.mAdaptorName);
                ret=artifactFcn(h.mProjectBuildInfo,filetype);
            end
            if~any(strfind(filetype,'-name'))
                if strcmpi(filetype,'project')
                    lInstrumentedCodeSubFolder=h.mProject.getInstrumentedSubFolder...
                    (h.mProjectBuildInfo.mBuildInfo);
                    if~isempty(lInstrumentedCodeSubFolder)
                        [fPath,fName,fExt]=fileparts(ret);
                        ret=fullfile(fPath,lInstrumentedCodeSubFolder,[fName,fExt]);
                    end
                end
            end
        end




        function ret=isMakeFileBuild(h)
            ret=strcmpi(h.mProjectBuildInfo.mBuildFormat,'Makefile');
        end




        function ret=exportIDEObjectToWorkspace(h)
            if~isempty(h.mProjectBuildInfo.mExportName)&&~h.isMakeFileBuild()
                if iscvar(h.mProjectBuildInfo.mExportName)
                    assignin('base',h.mProjectBuildInfo.mExportName,h.mAutomationHandle);
                    ret=1;
                else
                    warning(message('ERRORHANDLER:utils:InvalidIdeObjectName'));
                    ret=0;
                end
            end
        end







        function saveRestoreModelProps_g336834(h,action)

            if(~h.isRtwBuildInProgress())






                return;
            end

            hTgt=h.queryTarget(h.mProjectBuildInfo.mModelName);

            switch(action)
            case 'save'
                h.mProjectBuildInfo.mCompilerOptions=hTgt.compilerOptionsStr;
                h.mProjectBuildInfo.mLinkerOptions=hTgt.linkerOptionsStr;
                h.mProjectBuildInfo.mDirtyFlag=h.mBuildConfigurator.getDirtyFlag();

            case 'restore'



                if(~strcmp(h.mProjectBuildInfo.mCompilerOptions,hTgt.compilerOptionsStr))
                    hTgt.compilerOptionsStr=h.mProjectBuildInfo.mCompilerOptions;
                end
                if(~strcmp(h.mProjectBuildInfo.mLinkerOptions,hTgt.linkerOptionsStr))
                    hTgt.linkerOptionsStr=h.mProjectBuildInfo.mLinkerOptions;
                end



                if strcmpi(h.mProjectBuildInfo.mDirtyFlag,'off')&&...
                    strcmpi(h.mBuildConfigurator.getDirtyFlag(),'on')
                    h.mBuildConfigurator.setDirtyFlag('off');
                end
            end
        end




        function saveBuildInfoMatFile(h)

            if(exist('buildInfo.mat','file')==2)


                bimat=load('buildInfo.mat');
                if isfield(bimat,'buildInfo')
                    bimat.buildInfo=h.mProjectBuildInfo.mBuildInfo;
                end
                save('buildInfo.mat','-struct','bimat');
            else
                buildOpts=h.mProjectBuildInfo.mOptions.buildOpts;%#ok<NASGU>
                buildInfo=h.mProjectBuildInfo.mBuildInfo;%#ok<NASGU>
                save('buildInfo.mat','buildInfo','buildOpts');
            end
            if h.mMatlabTarget||~h.mProjectBuildInfo.mOptions.buildOpts.codeWasUpToDate





                ProjectBuildInfo=h.mProjectBuildInfo;
                save projectBuildInfo.mat ProjectBuildInfo
            end
        end

    end
end



