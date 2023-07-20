classdef BuildConfiguratorML<handle






    properties(SetAccess='private')
        mTgtInfo=[];
        mConfigSet=[];
    end


    properties(Constant)
    end


    methods



        function h=BuildConfiguratorML(cs,targetBoard)
            h.mConfigSet=cs;
            h.mTgtInfo=targetBoard;
        end




        function updateTargetRelatedProperties(h)
        end




        function verifyAndUpdateTargetInfo(h)
        end





        function irInfo=controlSchedulerInfo(h,action)
            irInfo=[];
        end

        function ret=controlValidateSystem(h,hookname,mProjectBuildInfo,varargin)
            ret=true;
        end





        function adaptorName=getAdaptorName(h)
            adaptorName='Eclipse';
        end

        function buildAction=getBuildAction(h)
            if(strcmpi(h.mConfigSet.OutputType,'exe'))
                buildAction='Build_and_execute';
            else
                buildAction='Archive_library';
            end
        end

        function buildConfig=getBuildConfig(h)
            buildConfig='Custom';
        end

        function buildFormat=getBuildFormat(h)
            if(h.mConfigSet.GenerateMakefile)
                buildFormat='Makefile';
            else
                buildFormat='CustomMW';
            end
        end

        function buildTimeout=getBuildTimeout(h)
            buildTimeout=2000;
        end

        function cgHook=getCGHook(h)
            cgHook='host';
        end

        function chipName=getCurrentChipName(h)
            chipName='';
        end

        function chipSubFamily=getCurrentChipSubFamily(h)
            chipSubFamily='';
        end

        function configSet=getConfigSet(h)
            configSet=h.mConfigSet;
        end

        function configSetParam=getConfigSetParam(h,param)
            if isprop(h.mConfigSet,param)
                configSetParam=h.mConfigSet.(param);
            else
                configSetParam=[];
            end
        end

        function createSILPILBlock=getCreateSILPILBlock(h)
            createSILPILBlock=false;
        end

        function dirtyFlag=getDirtyFlag(h)
            dirtyFlag=false;
        end

        function endianess=getEndianess(h)
            endianess='';
        end

        function exportIDEObj=getExportIDEObj(h)
            exportIDEObj=false;
        end

        function exportName=getExportName(h)
            exportName='';
        end

        function heapSize=getHeapSize(h)
            heapSize=1024;
        end

        function IDEOpts=getIDEOptions(h)
            IDEOpts='';
        end

        function irInfo=getSchedulerInfo(h)
            irInfo=[];
        end

        function isGenerateCodeOnly=getIsGenerateCodeOnly(h)
            isGenerateCodeOnly=h.getConfigSetParam('GenCodeOnly');
        end

        function isGenerateCodeOnly=getIsGenerateCodeOnlyInternal(h)
            isGenerateCodeOnly=false;
        end

        function isRealTime=getIsRealTime(h)
            isRealTime=false;
        end

        function boardSrcFiles=getListOfBoardSourceFiles(h)
            boardSrcFiles=[];
        end

        function compilerOpts=getListOfCompilerOptions(h)
            compilerOpts=[];
        end

        function includePaths=getListOfIncludePaths(h)
            includePaths=[];
        end

        function libraries=getListOfLibraries(h,isBigEndian)
            libraries=[];
        end

        function linkerOpts=getListOfLinkerOptions(h)
            linkerOpts=[];
        end

        function preProc=getListOfPreProc(h)
            preProc=[];
        end

        function Name=getName(h)
            Name=h.mConfigSet.Name;
        end

        function modelRefTgtType=getModelReferenceTargetType(h)
            modelRefTgtType=[];
        end

        function mvSwitch=getMvSwitch(h)
            mvSwitch='';
        end

        function ProfileGenCode=getProfileGenCode(h)
            ProfileGenCode='';
        end

        function profilingMethod=getProfilingMethod(h)
            profilingMethod='';
        end

        function osBaseRatePriority=getOSBaseRatePriority(h)
            osBaseRatePriority='';
        end

        function osName=getCurrentOSName(h)
            osName='';
        end

        function schedulingMode=getOSSchedulingMode(h)
            schedulingMode=[];
        end

        function stackSize=getStackSize(h)
            stackSize='';
        end

        function solver=getSolver(h)
            solver='';
        end

        function taskingMode=getTaskingMode(h)
            taskingMode='';
        end

        function tgtCompilerOpts=getTgtCompilerOptions(h)
            tgtCompilerOpts=[];
        end

        function tgtLinkerOpts=getTgtLinkerOptions(h)
            tgtLinkerOpts=[];
        end

        function tgtPrefData=getTgtPrefData(h)
            tgtPrefData=[];
        end

        function tgtPrefInfo=getTgtInfo(h)
            tgtPrefInfo=h.mTgtInfo;
        end

        function timeout=getTimeout(h)
            timeout=100;
        end

        function pilConfigFile=getPilConfigFile(h)
            pilConfigFile='';
        end

        function tgtPrefBlockName=getTgtPrefBlockName(h)
            tgtPrefBlockName='';
        end





        function setTgtCompilerOptions(h,opts)
        end

        function setTgtLinkerOptions(h,opts)
        end

        function setDirtyFlag(h,flag)
        end

        function isSil=isSilBuild(h)%#ok<MANU>
            isSil=false;
        end

    end


    methods(Static)
    end


    methods(Access='private')
    end
end
