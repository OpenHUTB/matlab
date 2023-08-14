








function[]=dlbuild(projName,sources,headers,tfiles,dlcodeCfg)

    bldparams=struct();


    project=coder.internal.Project;
    project.Name=projName;
    project.FileName=projName;
    project.CodingTarget=['rtw:',lower(dlcodeCfg.OutputType)];
    project.BldDirectory=dlcodeCfg.TargetDir;
    project.TargetDirectory=dlcodeCfg.TargetDir;
    project.IsUserSpecifiedOutputDir=1;
    project.OutDirectory=pwd;
    project.EntryPoints=coder.internal.EntryPoint(projName);




    cfg=dlcodeCfg.coderCfg;


    switch cfg.DeepLearningConfig.TargetLibrary
    case 'cudnn'
        tplUseClassNames={'dltargets.cudnn.cudnnApi'};
    case 'tensorrt'
        tplUseClassNames={'dltargets.tensorrt.tensorrtApi'};
    case{'mkldnn','onednn'}
        tplUseClassNames={'dltargets.onednn.onednnApi'};
    case 'arm-compute'
        tplUseClassNames={'dltargets.arm_neon.armcomputeApi'};
    case 'arm-compute-mali'
        tplUseClassNames={'dltargets.arm_mali.armmaliApi'};
    case 'cmsis-nn'
        tplUseClassNames={'dltargets.cmsis_nn.cmsisnnApi'};
    otherwise
        assert(false,'DeepLearningConfig is not valid.');
    end


    buildInfo=RTW.BuildInfo;


    buildInfo.addTMFTokens('EMC_PROJECT',projName);
    buildInfo.addTMFTokens('EMC_ENTRY_POINTS',projName);
    buildInfo.addTMFTokens('|>TGT_FCN_LIB<|','ISO_C++11');
    buildInfo.addBuildArgs('MLC_TARGET_NAME',projName,'BUILD_ARG');
    buildInfo.addBuildArgs('GENERATE_REPORT','1','BUILD_ARG');
    buildInfo.addBuildArgs('ADD_MDL_NAME_TO_GLOBALS','0','BUILD_ARG');



    codeInfo=RTW.ComponentInterface;
    codeInfo.Name=projName;
    codeInfo.GraphicalPath=projName;
    outputFunctionIf=RTW.FunctionInterface;
    codeInfo.OutputFunctions=outputFunctionIf;



    project.FeatureControl=coder.internal.FeatureControl;
    project.FeatureControl.EnablePARFOR=false;
    project.FeatureControl.EnableParallel=false;
    project.FeatureControl.EMLParallelCodeGen=false;
    if(isa(cfg,'coder.EmbeddedCodeConfig')||isa(cfg,'coder.CodeConfig')||isa(cfg,'coder.MexConfig'))
        project.FeatureControl.EnableGPU=~isempty(cfg.GpuConfig)&&cfg.GpuConfig.Enabled;
    end



    bldparams.project=project;



    bldparams.tflControl=emlcprivate('getEmlTflControl','SIM');
    bldparams.configInfo=cfg;
    bldparams.codeInfo=codeInfo;
    bldparams.buildInfo=buildInfo;


    bldparams.tplUseClassNames=tplUseClassNames;
    emlcprivate('updateBuildInfoWithExternSource',bldparams);




    buildInfo.addIncludePaths(project.BldDirectory,'BuildDir');
    buildInfo.addSourcePaths(project.BldDirectory,'BuildDir');




    buildInfo.addIncludePaths(project.OutDirectory,'StartDir');
    buildInfo.addSourcePaths(project.OutDirectory,'StartDir');




    if~isempty(sources)
        buildInfo.addSourceFiles(sources,project.BldDirectory);
    end

    if~isempty(headers)
        buildInfo.addIncludeFiles(headers,project.BldDirectory);
    end


    if~isempty(tfiles.srcs)
        [tsrcnames,srcpaths]=cellfun(@(x)getFileNameAndPath,tfiles.srcs,'UniformOutput',false);
        buildInfo.addSourceFiles(tsrcnames,srcpaths);
    end

    if~isempty(tfiles.headers)
        [theadernames,headerpaths]=cellfun(@getFileNameAndPath,tfiles.headers,'UniformOutput',false);
        buildInfo.addIncludeFiles(theadernames,headerpaths);
    end

    if~isempty(tfiles.datafiles)
        [datafilenames,datapaths]=cellfun(@getFileNameAndPath,tfiles.datafiles,'UniformOutput',false);
        buildInfo.addNonBuildFiles(datafilenames,datapaths);
    end



    parameterFiles=dltargets.internal.getGeneratedCNNBinaryFiles(project.BldDirectory);
    buildInfo.addNonBuildFiles(parameterFiles,project.BldDirectory);




    if strcmpi(cfg.DeepLearningConfig.TargetLibrary,'cudnn')&&...
        dlcoderfeature('cuDNNFp16')&&...
        strcmpi(cfg.DeepLearningConfig.DataType,'FP16')
        buildInfo.addDefines('FP16_ENABLED=1');
    elseif strcmp(cfg.DeepLearningConfig.TargetLibrary,'arm-compute-mali')
        buildInfo.addCompileFlags('-Wno-ignored-attributes');
    end

    if isa(cfg,'coder.EmbeddedCodeConfig')&&strcmpi(cfg.BuildConfiguration,'Debug')
        buildInfo.addDefines('DEBUG=1');
    end


    bldparams.buildInfo=buildInfo;


    buildResults=emlcprivate('emcBuildTarget',bldparams);
    dumpBuildLog(buildResults);


    if strcmp(cfg.DeepLearningConfig.TargetLibrary,'arm-compute-mali')||strcmp(cfg.DeepLearningConfig.TargetLibrary,'arm-compute')
        if(isempty(dlcodeCfg.coderCfg.Hardware))

            updateFilePathsAndExtensions(project);
        end
        disp('### Codegen Successfully Generated for arm device');
    end

    cleanup(dlcodeCfg);

end



function updateFilePathsAndExtensions(project)
    makeFileName=[project.BldDirectory,filesep,project.Name,'_rtw.mk'];
    batchStream=fileread(makeFileName);

    if ispc


        if contains(batchStream,strrep(project.BldDirectory,'\','/'))
            batchStream=strrep(batchStream,strrep(project.BldDirectory,'\','/'),'.');
        else

            batchStream=strrep(batchStream,strrep(RTW.transformPaths(project.BldDirectory),'\','/'),'.');
        end



        if contains(batchStream,strrep(project.OutDirectory,'\','/'))
            batchStream=strrep(batchStream,strrep(project.OutDirectory,'\','/'),'..');
        else

            batchStream=strrep(batchStream,strrep(RTW.transformPaths(project.OutDirectory),'\','/'),'..');
        end

        if contains(batchStream,strrep(matlabroot,'\','/'))
            batchStream=strrep(batchStream,strrep(matlabroot,'\','/'),'.');
        else


            batchStream=strrep(batchStream,strrep(RTW.transformPaths(matlabroot),'\','/'),'.');
        end
    else



        if contains(batchStream,project.BldDirectory)
            batchStream=strrep(batchStream,project.BldDirectory,'.');
        else

            batchStream=strrep(batchStream,RTW.transformPaths(project.BldDirectory),'.');
        end


        if contains(batchStream,project.OutDirectory)
            batchStream=strrep(batchStream,project.OutDirectory,'..');
        else

            batchStream=strrep(batchStream,RTW.transformPaths(project.OutDirectory),'..');
        end

        if contains(batchStream,matlabroot)
            batchStream=strrep(batchStream,matlabroot,'.');
        else


            batchStream=strrep(batchStream,RTW.transformPaths(matlabroot),'.');
        end
    end

    fp=fopen(makeFileName,'w');
    fprintf(fp,'%s',batchStream);
    fclose(fp);
end


function dumpBuildLog(buildResults)
    if~iscell(buildResults)
        buildResults={buildResults};
    end







    for i=1:numel(buildResults)
        buildResult=buildResults{i};
        if~isempty(buildResult)
            disp(repmat('-',1,72));
            disp(buildResult);
            disp(repmat('-',1,72));
        end
    end
end


function[fname,path]=getFileNameAndPath(ffile)
    [path,srcname,ext]=fileparts(ffile);
    fname=[srcname,ext];
end
