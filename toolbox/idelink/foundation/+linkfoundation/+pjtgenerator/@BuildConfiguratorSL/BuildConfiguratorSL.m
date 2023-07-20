classdef BuildConfiguratorSL<handle






    properties(SetAccess='private')
        mModelName=[];
        mConfigSet=[];
        mTgtInfo=[];
        mTarget=[];
        mTgtPrefData=[];
    end


    properties(Constant)
    end


    methods



        function h=BuildConfiguratorSL(modelName)
            h.mModelName=modelName;

            h.mConfigSet=getActiveConfigSet(h.mModelName);

            rtwcc=h.mConfigSet.getComponent('Real-Time Workshop');
            h.mTarget=rtwcc.getComponent('Target');
        end




        function updateTargetRelatedProperties(h)

            h.mTgtInfo=getTgtPrefInfo(h.mModelName);
            lTgtPrefBlockName=h.getTgtPrefBlockName();

            h.mTgtPrefData=targetpref.Data(getActiveConfigSet(h.mModelName),lTgtPrefBlockName);
        end




        function verifyAndUpdateTargetInfo(h)




            synchronizeProcessorData(h.mModelName,'modelbuild');







            cs=getActiveConfigSet(h.mModelName);
            TgtPref_version([],['update to ',getTgtPrefVersion],cs);
        end





        function irInfo=controlSchedulerInfo(h,action)
            switch action
            case 'init'
                irInfo=idelink_initIrInfo(...
                h.mModelName,...
                h.getCGHook(),...
                h.mTgtPrefData.getCurOS());
            otherwise
                irInfo=[];
            end
        end

        function ret=controlValidateSystem(h,hookname,mProjectBuildInfo,varargin)

            arg{1}=mProjectBuildInfo.mCGHook;
            arg{end+1}=h.getTgtInfo();

            switch lower(hookname)
            case 'entry'
                arg{end+1}=mProjectBuildInfo.mModelName;
            case 'aftermake'
                arg{end+1}=mProjectBuildInfo.mIRInfo;
            case 'exit'

                modelInfo.tmf=mProjectBuildInfo.mOptions.tmf;
                modelInfo.name=mProjectBuildInfo.mModelName;
                modelInfo.rtwroot=mProjectBuildInfo.mOptions.rtwroot;
                modelInfo.buildOpts=mProjectBuildInfo.mOptions.buildOpts;
                modelInfo.buildArgs=mProjectBuildInfo.mOptions.buildArgs;
                modelInfo.buildInfo=mProjectBuildInfo.mBuildInfo;

                assert((nargin==4)&&(isa(varargin{1},'linkfoundation.pjtgenerator.Project')));
                arg{end+1}=mProjectBuildInfo.mIRInfo;
                arg{end+1}=modelInfo;
                arg{end+1}=varargin{1};
            end


            lf_validateModel(hookname,arg{:});
            ret=true;
        end





        function adaptorName=getAdaptorName(h)
            adaptorName=h.getConfigSetParam('AdaptorName');
        end

        function buildAction=getBuildAction(h)
            buildAction=h.getConfigSetParam('buildAction');
        end

        function buildConfig=getBuildConfig(h)
            buildConfig=h.getConfigSetParam('projectOptions');
        end

        function buildFormat=getBuildFormat(h)
            buildFormat=h.getConfigSetParam('buildFormat');
        end

        function buildTimeout=getBuildTimeout(h)
            buildTimeout=h.getConfigSetParam('ideObjBuildTimeout');
        end

        function cgHook=getCGHook(h)

            cgHook=h.getTgtInfo().chipInfo.codegenhookpoint;
        end

        function chipName=getCurrentChipName(h)
            chipName=h.mTgtPrefData.getCurChipName();
        end

        function chipSubFamily=getCurrentChipSubFamily(h)
            chipSubFamily=h.mTgtPrefData.getCurChipSubFamily();
        end

        function configSet=getConfigSet(h)
            configSet=h.mConfigSet;
        end

        function configSetParam=getConfigSetParam(h,param)
            configSetParam=get_param(h.mConfigSet,param);
        end

        function createSILPILBlock=getCreateSILPILBlock(h)
            createSILPILBlock=get_param(h.mModelName,'CreateSILPILBlock');
        end

        function dirtyFlag=getDirtyFlag(h)
            dirtyFlag=get_param(h.mModelName,'Dirty');
        end

        function endianess=getEndianess(h)
            endianess=h.getConfigSetParam('ProdEndianess');
        end

        function exportIDEObj=getExportIDEObj(h)
            exportIDEObj=h.getConfigSetParam('exportIDEObj');
        end

        function exportName=getExportName(h)
            exportName=h.getConfigSetParam('ideObjName');
        end

        function IDEOpts=getIDEOptions(h)
            IDEOpts=h.mTgtPrefData.getIDEOptions();
        end

        function heapSize=getHeapSize(h)
            heapSize=h.getConfigSetParam('systemHeapSize');
        end

        function irInfo=getSchedulerInfo(h)
            irInfo=idelink_getIrInfo(...
            h.mModelName,...
            h.getCGHook(),...
            h.mTgtPrefData.getCurOS());
        end

        function isGenerateCodeOnly=getIsGenerateCodeOnly(h)
            isGenerateCodeOnly=strcmpi(get_param(h.mModelName,'GenCodeOnly'),'on');
        end

        function isGenerateCodeOnly=getIsGenerateCodeOnlyInternal(h)
            isGenerateCodeOnly=lf_isGenerateCodeOnly(h.mModelName);
        end

        function isRealTime=getIsRealTime(h)
            isRealTime=h.mTgtPrefData.isRealTime();
        end

        function boardSrcFiles=getListOfBoardSourceFiles(h)
            boardSrcFiles=h.mTgtPrefData.getListOfBoardSourceFiles();
        end

        function compilerOpts=getListOfCompilerOptions(h)
            compilerOpts=h.mTgtPrefData.getListOfCompilerOption();
        end

        function includePaths=getListOfIncludePaths(h)
            includePaths=h.mTgtPrefData.getListOfIncludePaths();
        end

        function libraries=getListOfLibraries(h,isBigEndian)
            if(isBigEndian)
                libraries=h.mTgtPrefData.getListOfLibrariesBigEndian();
            else
                libraries=h.mTgtPrefData.getListOfLibrariesLittleEndian();
            end
        end

        function linkerOpts=getListOfLinkerOptions(h)
            linkerOpts=h.mTgtPrefData.getListOfLinkerOption();
        end

        function preProc=getListOfPreProc(h)
            preProc=h.mTgtPrefData.getListOfPreProc();
        end

        function Name=getName(h)
            Name=h.mModelName;
        end

        function modelRefTgtType=getModelReferenceTargetType(h)
            modelRefTgtType=get_param(h.mModelName,'ModelReferenceTargetType');
        end

        function mvSwitch=getMvSwitch(h)
            mvSwitch=h.mTgtPrefData.getCurChipMvSwitch();
        end

        function osBaseRatePriority=getOSBaseRatePriority(h)
            osBaseRatePriority=h.mTgtPrefData.getOSBaseRatePriority();
        end

        function osName=getCurrentOSName(h)
            osName=h.mTgtPrefData.getCurOS();
        end

        function osSchedulingMode=getOSSchedulingMode(h)
            osSchedulingMode=h.mTgtPrefData.getCurOSSchedulingMode();
        end

        function ProfileGenCode=getProfileGenCode(h)
            ProfileGenCode=h.getConfigSetParam('ProfileGenCode');
        end

        function profilingMethod=getProfilingMethod(h)
            profilingMethod=h.getConfigSetParam('profileBy');
        end

        function stackSize=getStackSize(h)
            stackSize=h.getConfigSetParam('systemStackSize');
        end

        function solver=getSolver(h)
            solver=h.getConfigSetParam('Solver');
        end

        function taskingMode=getTaskingMode(h)
            taskingMode=getProp(h.mConfigSet,'SolverMode');
        end

        function tgtCompilerOpts=getTgtCompilerOptions(h)
            tgtCompilerOpts=h.mTarget.compilerOptionsStr;
        end

        function tgtLinkerOpts=getTgtLinkerOptions(h)
            tgtLinkerOpts=h.mTarget.linkerOptionsStr;
        end

        function tgtPrefData=getTgtPrefData(h)
            tgtPrefData=h.mTgtPrefData;
        end

        function tgtPrefInfo=getTgtInfo(h)

            tgtPrefInfo=h.mTgtInfo;
        end

        function timeout=getTimeout(h)
            timeout=h.getConfigSetParam('ideObjTimeout');
        end

        function pilConfigFile=getPilConfigFile(h)
            pilConfigFile=[h.mModelName,'_pilinfo.dat'];
        end

        function tgtPrefBlockName=getTgtPrefBlockName(h)
            tgtPrefBlockName=getTgtPrefBlock(h.mModelName);
        end





        function setTgtCompilerOptions(h,opts)
            h.mTarget.compilerOptionsStr=opts;
        end

        function setTgtLinkerOptions(h,opts)
            h.mTarget.compilerLinkerStr=opts;
        end

        function setDirtyFlag(h,flag)
            set_param(h.mModelName,'Dirty',flag);
        end

        function isSil=isSilBuild(h)
            isSil=rtw.connectivity.Utils.isSil(h.mModelName);
        end
    end


    methods(Static)
    end


    methods(Access='private')
    end
end
