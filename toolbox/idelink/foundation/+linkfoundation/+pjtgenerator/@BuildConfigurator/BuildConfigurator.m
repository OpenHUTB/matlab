classdef BuildConfigurator<handle






    properties(SetAccess='private')
    end


    properties(Constant)
    end


    methods
    end


    methods(Abstract)



        updateTargetRelatedProperties(h);
        verifyAndUpdateTargetInfo(h);



        irInfo=controlSchedulerInfo(h,action);
        ret=controlValidateSystem(h,hookname,mProjectBuildInfo,mProject);





        adaptorName=getAdaptorName(h);
        boardSrcFiles=getListOfBoardSourceFiles(h);
        buildAction=getBuildAction(h);
        buildConfig=getBuildConfig(h);
        buildFormat=getBuildFormat(h);
        buildTimeout=getBuildTimeout(h);
        cgHook=getCGHook(h);
        chipName=getCurrentChipName(h);
        chipSubFamily=getCurrentChipSubFamily(h);
        compilerOpts=getListOfCompilerOptions(h);
        configSet=getConfigSet(h);
        configSetParam=getConfigSetParam(h,param);
        createSILPILBlock=getCreateSILPILBlock(h);
        dirtyFlag=getDirtyFlag(h);
        endianess=getEndianess(h);
        exportIDEObj=getExportIDEObj(h);
        exportName=getExportName(h);
        heapSize=getHeapSize(h);
        IDEOpts=getIDEOptions(h);
        isGenerateCodeOnly=getIsGenerateCodeOnly(h);
        isGenerateCodeOnly=getIsGenerateCodeOnlyInternal(h);
        includePaths=getListOfIncludePaths(h);
        irInfo=getSchedulerInfo(h);
        isRealTime=getIsRealTime(h);
        libraries=getListOfLibraries(h,isBigEndian);
        linkerOpts=getListOfLinkerOptions(h);
        name=getName(h);
        modelRefTgtType=getModelReferenceTargetType(h);
        mvSwitch=getMvSwitch(h);
        osBaseRatePriority=getOSBaseRatePriority(h);
        osName=getCurrentOSName(h);
        osSchedulingMode=getOSSchedulingMode(h);
        preProc=getListOfPreProc(h);
        ProfileGenCode=getProfileGenCode(h);
        profilingMethod=getProfilingMethod(h);
        solver=getSolver(h);
        stackSize=getStackSize(h);
        tgtCompilerOpts=getTgtCompilerOptions(h);
        tgtLinkerOpts=getTgtLinkerOptions(h);
        tgtPrefData=getTgtPrefData(h);
        tgtInfo=getTgtInfo(h);
        taskingMode=getTaskingMode(h);
        timeout=getTimeout(h);
        pilConfigFile=getPilConfigFile(h);
        tgtPrefBlockName=getTgtPrefBlockName(h);

        isPjtSilBuild=isSilBuild(h);




        setTgtCompilerOptions(h,opts);
        setTgtLinkerOptions(h,opts);
        setDirtyFlag(h,opts);


    end


    methods(Access='private')
    end
end
