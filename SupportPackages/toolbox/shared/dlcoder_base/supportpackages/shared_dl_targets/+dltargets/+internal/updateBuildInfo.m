function updateBuildInfo(buildInfoObject,...
    codegendir,...
    inputSizes,...
    dlcodeCfg,...
    calibrationBatchFilePath,...
    isYoloV2Network,...
    dlCodegenOptionsCallback,...
    networkInfo,...
    usePrecompiledLibraries)







    dlcfg=dlcodeCfg.DeepLearningConfig;
    target=dlcfg.TargetLibrary;


    switch target
    case 'arm-compute'
        target='arm_neon';
    case 'mkldnn'
        target='onednn';
    otherwise

    end






    modelCodegenMgr=[];
    if~usePrecompiledLibraries



        p=dnn_pir;
        hN=p.getTopNetwork();

        if(dltargets.internal.hasHandWrittenFilesForTarget(target))
            [csrcs,headers]=dltargets.internal.getLayerFiles(hN);
            [implsrc,implheader]=dltargets.internal.getImplFiles(hN,target,dlcfg);
        else
            csrcs={};
            headers={};
            implsrc={};
            implheader={};
        end


        if(strcmpi(dlcodeCfg.DeepLearningConfig.TargetLibrary,'cudnn')&&dlcodeCfg.DeepLearningConfig.Instrumentation)
            [implsrcfPath,~,~]=fileparts(implsrc{1});
            [implheaderfPath,~,~]=fileparts(implheader{1});
            implheader{end+1}=fullfile(implsrcfPath,'MWInstrumentationUtils.hpp');
            implsrc{end+1}=fullfile(implheaderfPath,'MWInstrumentationUtils.cu');
        end

        csrcs=[csrcs,implsrc];
        headers=[headers,implheader];

        srcnames=cellfun(@removeFilePath,csrcs,'UniformOutput',false);

        isSimulinkCoderInstalled=~isempty(which('coder.internal.ModelCodegenMgr'));
        if isSimulinkCoderInstalled


            modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance([]);
        end

        if~isempty(srcnames)
            buildInfoObject.addSourceFiles(srcnames);
            iAddSourceFilesToSimulinkBuildInfo(modelCodegenMgr,srcnames);
        end

        headernames=cellfun(@removeFilePath,headers,'UniformOutput',false);
        if~isempty(headernames)
            buildInfoObject.addIncludeFiles(headernames);
            iAddIncludeFilesToSimulinkBuildInfo(modelCodegenMgr,headernames);
        end


        moveFilesToCodeGenDir(csrcs,srcnames,codegendir);
        moveFilesToCodeGenDir(headers,headernames,codegendir);

        if(dltargets.internal.hasHandWrittenFilesForTarget(target))
            dltargets.internal.layerImplFactoryEmitter.updateLayerImplFactoryHeader(hN,target,codegendir);
            dltargets.internal.layerImplFactoryEmitter.updateLayerImplFactoryFile(hN,target,codegendir);
        end

    end



    parameterFiles=dltargets.internal.getGeneratedCNNBinaryFiles(codegendir);
    group='DeepLearningBinary';
    buildInfoObject.addNonBuildFiles(parameterFiles,codegendir,group);

    try


        modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance([]);
    catch
        modelCodegenMgr=[];
    end

    if~isempty(modelCodegenMgr)

        updateBinFilesForSimulink(modelCodegenMgr,parameterFiles,codegendir,target);
    end


    [tsrcs,theaders,datafiles]=...
    dltargets.internal.prepareTargetSpecificFiles(dlcodeCfg,...
    inputSizes,...
    calibrationBatchFilePath,...
    isYoloV2Network,...
    dlCodegenOptionsCallback,...
    networkInfo);

    if~isempty(tsrcs)
        tsrcnames=cellfun(@(x)removeFilePath,tsrcs,'UniformOutput',false);
        buildInfoObject.addSourceFiles(tsrcnames);
        iAddSourceFilesToSimulinkBuildInfo(modelCodegenMgr,tsrcnames);
    end

    if~isempty(theaders)
        theadernames=cellfun(@removeFilePath,theaders,'UniformOutput',false);
        buildInfoObject.addIncludeFiles(theadernames);
        iAddIncludeFilesToSimulinkBuildInfo(modelCodegenMgr,theadernames);
    end

    if~isempty(datafiles)
        datafilenames=cellfun(@removeFilePath,datafiles,'UniformOutput',false);
        datafiledirs=cellfun(@fileparts,datafiles,'UniformOutput',false);
        buildInfoObject.addNonBuildFiles(datafilenames,datafiledirs);
        iAddNonBuildFilesToSimulinkBuildInfo(modelCodegenMgr,datafilenames,datafiledirs);
    end

end


function updateBinFilesForSimulink(modelCodegenMgr,parameterFiles,codegendir,target)
    folders=Simulink.filegen.internal.FolderConfiguration(modelCodegenMgr.ModelName);
    sharedUtilDir=folders.CodeGeneration.absolutePath('SharedUtilityCode');

    if strcmp(modelCodegenMgr.BuildDirectory,codegendir)||strcmp(sharedUtilDir,codegendir)
        copyNonBuildFilesIfNeeded(modelCodegenMgr,parameterFiles,codegendir,target);
    end
end


function copyNonBuildFilesIfNeeded(modelCodegenMgr,parameterFiles,codegendir,target)
    bInfo=modelCodegenMgr.BuildInfo;
    iAddNonBuildFilesToSimulinkBuildInfo(modelCodegenMgr,parameterFiles,codegendir);


    isArmTarget=strcmp(target,'arm_neon');
    toolChain=modelCodegenMgr.MCMToolchainOrTMFName;
    isNvidiaTarget=strcmp(toolChain,'NVCC for NVIDIA Embedded Processors');
    if isArmTarget||isNvidiaTarget
        addDLDataPathForSimulink(codegendir,bInfo);
    end
end

function addDLDataPathForSimulink(codegendir,bInfo)
    workspaceDir='$(MATLAB_WORKSPACE)';
    dlDataPath=fullfile(workspaceDir,codegendir);

    bInfo.addDefines(['MW_DL_DATA_PATH=',dlDataPath],'TargetBasedPathFormattingGroup');
end

function moveFilesToCodeGenDir(filesrcs,fnames,codegendir)

    for k=1:numel(filesrcs)
        fullFileName=filesrcs{k};
        [~,fileName,fileExtension]=fileparts(fullFileName);
        targetFileName=fullfile(codegendir,[fileName,fileExtension]);
        if contains(fullFileName,'LayerImplFactory')&&...
            isfile(targetFileName)



            continue;
        end

        success=copyfile(fullFileName,codegendir,'f');
        if(success)
            matlab.io.internal.common.updateLastModified(targetFileName);
        end
    end

    if ispc
        userattrib='';
    else
        userattrib='u';
    end
    for k=1:numel(fnames)
        fileattrib(fullfile(codegendir,fnames{k}),'+w',userattrib);
    end

end

function fname=removeFilePath(ffile)
    [~,srcname,ext]=fileparts(ffile);
    fname=[srcname,ext];
end

function iAddIncludeFilesToSimulinkBuildInfo(modelCodegenMgr,includeFiles)
    if~isempty(modelCodegenMgr)
        c=get_param(modelCodegenMgr.ModelName,'CGModel');
        if~c.IsGeneratingToSharedLocation






            modelCodegenMgr.BuildInfo.addIncludeFiles(includeFiles);
        end
    end
end

function iAddSourceFilesToSimulinkBuildInfo(modelCodegenMgr,srcFiles)
    if~isempty(modelCodegenMgr)
        c=get_param(modelCodegenMgr.ModelName,'CGModel');
        if~c.IsGeneratingToSharedLocation






            modelCodegenMgr.BuildInfo.addSourceFiles(srcFiles);
        end
    end
end

function iAddNonBuildFilesToSimulinkBuildInfo(modelCodegenMgr,datafilenames,datafiledirs)


    if~isempty(modelCodegenMgr)




        modelCodegenMgr.BuildInfo.addNonBuildFiles(datafilenames,datafiledirs);
    end
end
