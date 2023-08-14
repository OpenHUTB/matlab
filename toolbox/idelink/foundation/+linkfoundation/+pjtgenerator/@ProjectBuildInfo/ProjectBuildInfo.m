classdef ProjectBuildInfo<handle






    properties
        mAdaptorName=[];
        mAdditional=[];
        mBigEndian=[];
        mBinaryName=[];
        mBuildAction=[];
        mBuildConfig=[];
        mBuildFormat=[];
        mBuildInfo=[];
        mBuildTimeout=[];
        mChipName=[];
        mChipSubFamily=[];
        mCodeGenDir=[];
        mCGHook=[];
        mCompilerOptions=[];
        mConfigSet=[];
        mDirtyFlag=[];
        mExportName=[];
        mExportIDEObj=[];
        mHeapSize=[];
        mIDEOpts=[];
        mIRInfo=[];
        mIncludePathDelimiter=[];
        mLinkerOptions=[];
        mModelName=[];
        mModelReferenceTargetType=[];
        mMvSwitch=[];
        mOptions=[];
        mOSName=[];
        mPilBuildAction=[];
        mPilConfigFile=[];
        mPilConfiguration=[];
        mPilSupportFiles=[];
        mPreprocSymbolDelimiter=[];
        mProfilingMethod=[];
        mProjectName=[];
        mReferencedModelLibs=[];
        mRemoveFromLibPjt=[];
        mStackSize=[];
        mTaskingMode=[];
        mTgtInfo=[];
        mTimeout=[];
        mTokens=[];
    end


    methods
        function obj=set.mAdaptorName(obj,mAdaptorName)
            obj.mAdaptorName=mAdaptorName;
        end
        function mAdaptorName=get.mAdaptorName(obj)
            mAdaptorName=obj.mAdaptorName;
        end

        function obj=set.mAdditional(obj,mAdditional)
            obj.mAdditional=mAdditional;
        end
        function mAdditional=get.mAdditional(obj)
            mAdditional=obj.mAdditional;
        end

        function obj=set.mBigEndian(obj,mBigEndian)
            obj.mBigEndian=mBigEndian;
        end
        function mBigEndian=get.mBigEndian(obj)
            mBigEndian=obj.mBigEndian;
        end

        function obj=set.mBinaryName(obj,mBinaryName)
            obj.mBinaryName=mBinaryName;
        end
        function mBinaryName=get.mBinaryName(obj)
            mBinaryName=obj.mBinaryName;
        end

        function obj=set.mBuildAction(obj,mBuildAction)
            obj.mBuildAction=mBuildAction;
        end
        function mBuildAction=get.mBuildAction(obj)
            mBuildAction=obj.mBuildAction;
        end

        function obj=set.mBuildConfig(obj,mBuildConfig)
            obj.mBuildConfig=mBuildConfig;
        end
        function mBuildConfig=get.mBuildConfig(obj)
            mBuildConfig=obj.mBuildConfig;
        end

        function obj=set.mBuildFormat(obj,mBuildFormat)
            obj.mBuildFormat=mBuildFormat;
        end
        function mBuildFormat=get.mBuildFormat(obj)
            mBuildFormat=obj.mBuildFormat;
        end

        function obj=set.mBuildInfo(obj,mBuildInfo)
            obj.mBuildInfo=mBuildInfo;
        end
        function mBuildInfo=get.mBuildInfo(obj)
            mBuildInfo=obj.mBuildInfo;
        end

        function obj=set.mBuildTimeout(obj,mBuildTimeout)
            obj.mBuildTimeout=mBuildTimeout;
        end
        function mBuildTimeout=get.mBuildTimeout(obj)
            mBuildTimeout=obj.mBuildTimeout;
        end

        function obj=set.mChipName(obj,mChipName)
            obj.mChipName=mChipName;
        end
        function mChipName=get.mChipName(obj)
            mChipName=obj.mChipName;
        end

        function obj=set.mChipSubFamily(obj,mChipSubFamily)
            obj.mChipSubFamily=mChipSubFamily;
        end
        function mChipSubFamily=get.mChipSubFamily(obj)
            mChipSubFamily=obj.mChipSubFamily;
        end


        function obj=set.mCodeGenDir(obj,mCodeGenDir)
            obj.mCodeGenDir=mCodeGenDir;
        end
        function mCodeGenDir=get.mCodeGenDir(obj)
            mCodeGenDir=obj.mCodeGenDir;
        end

        function obj=set.mCGHook(obj,mCGHook)
            obj.mCGHook=mCGHook;
        end
        function mCGHook=get.mCGHook(obj)
            mCGHook=obj.mCGHook;
        end

        function obj=set.mCompilerOptions(obj,mCompilerOptions)
            obj.mCompilerOptions=mCompilerOptions;
        end
        function mCompilerOptions=get.mCompilerOptions(obj)
            mCompilerOptions=obj.mCompilerOptions;
        end

        function obj=set.mConfigSet(obj,mConfigSet)
            obj.mConfigSet=mConfigSet;
        end
        function mConfigSet=get.mConfigSet(obj)
            mConfigSet=obj.mConfigSet;
        end

        function obj=set.mDirtyFlag(obj,mDirtyFlag)
            obj.mDirtyFlag=mDirtyFlag;
        end
        function mDirtyFlag=get.mDirtyFlag(obj)
            mDirtyFlag=obj.mDirtyFlag;
        end

        function obj=set.mExportName(obj,mExportName)
            obj.mExportName=mExportName;
        end
        function mExportName=get.mExportName(obj)
            mExportName=obj.mExportName;
        end

        function obj=set.mExportIDEObj(obj,mExportIDEObj)
            obj.mExportIDEObj=mExportIDEObj;
        end
        function mExportIDEObj=get.mExportIDEObj(obj)
            mExportIDEObj=obj.mExportIDEObj;
        end

        function obj=set.mHeapSize(obj,mHeapSize)
            obj.mHeapSize=mHeapSize;
        end
        function mHeapSize=get.mHeapSize(obj)
            mHeapSize=obj.mHeapSize;
        end

        function obj=set.mIDEOpts(obj,mIDEOpts)
            obj.mIDEOpts=mIDEOpts;
        end
        function mIDEOpts=get.mIDEOpts(obj)
            mIDEOpts=obj.mIDEOpts;
        end

        function obj=set.mIRInfo(obj,mIRInfo)
            obj.mIRInfo=mIRInfo;
        end
        function mIRInfo=get.mIRInfo(obj)
            mIRInfo=obj.mIRInfo;
        end

        function obj=set.mIncludePathDelimiter(obj,mIncludePathDelimiter)
            obj.mIncludePathDelimiter=mIncludePathDelimiter;
        end
        function mIncludePathDelimiter=get.mIncludePathDelimiter(obj)
            mIncludePathDelimiter=obj.mIncludePathDelimiter;
        end

        function obj=set.mLinkerOptions(obj,mLinkerOptions)
            obj.mLinkerOptions=mLinkerOptions;
        end
        function mLinkerOptions=get.mLinkerOptions(obj)
            mLinkerOptions=obj.mLinkerOptions;
        end

        function obj=set.mModelName(obj,mModelName)
            obj.mModelName=mModelName;
        end
        function mModelName=get.mModelName(obj)
            mModelName=obj.mModelName;
        end

        function obj=set.mModelReferenceTargetType(obj,mModelReferenceTargetType)
            obj.mModelReferenceTargetType=mModelReferenceTargetType;
        end
        function mModelReferenceTargetType=get.mModelReferenceTargetType(obj)
            mModelReferenceTargetType=obj.mModelReferenceTargetType;
        end

        function obj=set.mMvSwitch(obj,mMvSwitch)
            obj.mMvSwitch=mMvSwitch;
        end
        function mMvSwitch=get.mMvSwitch(obj)
            mMvSwitch=obj.mMvSwitch;
        end

        function obj=set.mOptions(obj,mOptions)
            obj.mOptions=mOptions;
        end
        function mOptions=get.mOptions(obj)
            mOptions=obj.mOptions;
        end

        function obj=set.mOSName(obj,mOSName)
            obj.mOSName=mOSName;
        end
        function mOSName=get.mOSName(obj)
            mOSName=obj.mOSName;
        end

        function obj=set.mPilBuildAction(obj,mPilBuildAction)
            obj.mPilBuildAction=mPilBuildAction;
        end
        function mPilBuildAction=get.mPilBuildAction(obj)
            mPilBuildAction=obj.mPilBuildAction;
        end

        function obj=set.mPilConfigFile(obj,mPilConfigFile)
            obj.mPilConfigFile=mPilConfigFile;
        end
        function mPilConfigFile=get.mPilConfigFile(obj)
            mPilConfigFile=obj.mPilConfigFile;
        end

        function obj=set.mPilConfiguration(obj,mPilConfiguration)
            obj.mPilConfiguration=mPilConfiguration;
        end
        function mPilConfiguration=get.mPilConfiguration(obj)
            mPilConfiguration=obj.mPilConfiguration;
        end

        function obj=set.mPilSupportFiles(obj,mPilSupportFiles)
            obj.mPilSupportFiles=mPilSupportFiles;
        end
        function mPilSupportFiles=get.mPilSupportFiles(obj)
            mPilSupportFiles=obj.mPilSupportFiles;
        end

        function obj=set.mPreprocSymbolDelimiter(obj,mPreprocSymbolDelimiter)
            obj.mPreprocSymbolDelimiter=mPreprocSymbolDelimiter;
        end
        function mPreprocSymbolDelimiter=get.mPreprocSymbolDelimiter(obj)
            mPreprocSymbolDelimiter=obj.mPreprocSymbolDelimiter;
        end

        function obj=set.mProfilingMethod(obj,mProfilingMethod)
            obj.mProfilingMethod=mProfilingMethod;
        end
        function mProfilingMethod=get.mProfilingMethod(obj)
            mProfilingMethod=obj.mProfilingMethod;
        end

        function obj=set.mProjectName(obj,mProjectName)
            obj.mProjectName=mProjectName;
        end
        function mProjectName=get.mProjectName(obj)
            mProjectName=obj.mProjectName;
        end

        function obj=set.mReferencedModelLibs(obj,mReferencedModelLibs)
            obj.mReferencedModelLibs=mReferencedModelLibs;
        end
        function mReferencedModelLibs=get.mReferencedModelLibs(obj)
            mReferencedModelLibs=obj.mReferencedModelLibs;
        end

        function obj=set.mRemoveFromLibPjt(obj,mRemoveFromLibPjt)
            obj.mRemoveFromLibPjt=mRemoveFromLibPjt;
        end
        function mRemoveFromLibPjt=get.mRemoveFromLibPjt(obj)
            mRemoveFromLibPjt=obj.mRemoveFromLibPjt;
        end

        function obj=set.mStackSize(obj,mStackSize)
            obj.mStackSize=mStackSize;
        end
        function mStackSize=get.mStackSize(obj)
            mStackSize=obj.mStackSize;
        end

        function obj=set.mTaskingMode(obj,mTaskingMode)
            obj.mTaskingMode=mTaskingMode;
        end
        function mTaskingMode=get.mTaskingMode(obj)
            mTaskingMode=obj.mTaskingMode;
        end

        function obj=set.mTgtInfo(obj,mTgtInfo)
            obj.mTgtInfo=mTgtInfo;
        end
        function mTgtInfo=get.mTgtInfo(obj)
            mTgtInfo=obj.mTgtInfo;
        end

        function obj=set.mTimeout(obj,mTimeout)
            obj.mTimeout=mTimeout;
        end
        function mTimeout=get.mTimeout(obj)
            mTimeout=obj.mTimeout;
        end

        function obj=set.mTokens(obj,mTokens)
            obj.mTokens=mTokens;
        end
        function mTokens=get.mTokens(obj)
            mTokens=obj.mTokens;
        end


    end

    methods(Hidden=true)



        function This=ProjectBuildInfo
            This.mAdditional=struct('IncPath',[],...
            'Lib',[],...
            'LinkerOption',[],...
            'CompilerOption',[],...
            'PreProcSymbol',[],...
            'Src',[]);
        end




        function[varargout]=markForRemovalFromLibPjt(obj,file)

            if~isempty(file)&&~any(strncmpi(file,obj.mRemoveFromLibPjt,length(file)))
                if isempty(obj.mRemoveFromLibPjt)
                    obj.mRemoveFromLibPjt{1}=file;
                else
                    obj.mRemoveFromLibPjt{end+1}=file;
                end





                rtw.connectivity.Utils.buildInfoAddSrcFileToSilSkipGroup(...
                obj.mModelName,file);





                if rtw.connectivity.Utils.isSilAndPWSBuild(obj.mModelName)
                    silHostObjDir=fullfile(fileparts(file),...
                    rtw.connectivity.Utils.getSilHostObjSubDir);
                    if~exist(silHostObjDir,'dir')
                        mkdir(silHostObjDir)
                    end
                    libFilesToSkip=fullfile(silHostObjDir,'libFilesToSkip.txt');
                    fid=fopen(libFilesToSkip,'a');
                    fprintf(fid,'%s\n',file);
                    fclose(fid);
                end
            end

            for i=1:nargout
                varargout(i)={''};%#ok<AGROW>
            end
        end




        function[varargout]=markForPILPjt(obj,file)

            if~isempty(file)&&~any(strncmpi(file,obj.mPilSupportFiles,length(file)))
                if isempty(obj.mPilSupportFiles)
                    obj.mPilSupportFiles{1}=file;
                else
                    obj.mPilSupportFiles{end+1}=file;
                end





                if rtw.connectivity.Utils.isSilAndPWSBuild(obj.mModelName)
                    silHostObjDir=fullfile(fileparts(file),...
                    rtw.connectivity.Utils.getSilHostObjSubDir);
                    if~exist(silHostObjDir,'dir')
                        mkdir(silHostObjDir)
                    end
                    pilFilesToAdd=fullfile(silHostObjDir,'pilFilesToAdd.txt');
                    fid=fopen(pilFilesToAdd,'a');
                    fprintf(fid,'%s\n',file);
                    fclose(fid);
                end
            end

            for i=1:nargout
                varargout(i)={''};%#ok<AGROW>
            end
        end




        function path=getBinaryPath(obj)
            path=fullfile(obj.mCodeGenDir,[obj.mBuildConfig,'MW'],obj.mBinaryName);
        end
    end


    methods(Static=true)
    end

end
