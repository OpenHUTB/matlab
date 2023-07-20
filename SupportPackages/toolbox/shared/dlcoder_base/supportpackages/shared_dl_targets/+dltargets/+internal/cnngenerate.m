













function[srcs,headers,tfiles]=cnngenerate(networkInfo,dlcodeCfg,transformProperties,quantizationInfo)


    networkName='CnnMain';
    codetarget=['rtw:',lower(dlcodeCfg.OutputType)];

    codegendir=dlcodeCfg.TargetDir;
    dltargets.internal.makeCodegendir(codegendir);

    [~,tgtName,tgtExt]=fileparts(dlcodeCfg.TargetFile);
    if(isempty(tgtExt)||(~strcmp(tgtExt,'.cpp')))
        tgtExt='.cpp';
        warning(message('dlcoder_spkg:cnncodegen:forcing_target_file_ext',dlcodeCfg.TargetFile));
    end



    dltargets.internal.NetworkFileSaver.generateNetworkInfoFileForUnsupportedTargets(networkName,...
    codegendir,lower(dlcodeCfg.OutputType),dlcodeCfg.DeepLearningConfig.TargetLibrary);





    tensorrtQuantSpecMatFile='';



    globalDnnContext=dltargets.internal.cnnbuildpir(networkInfo,...
    networkName,...
    codegendir,...
    codetarget,...
    dlcodeCfg.DeepLearningConfig,...
    transformProperties,...
    -1,...
    tensorrtQuantSpecMatFile);


    targetFileName=fullfile(codegendir,tgtName);

    globalDnnContext.invokeDnnBackend(networkName,...
    targetFileName,...
    dlcodeCfg.DeepLearningConfig,...
    dlcodeCfg.BatchSize,...
    quantizationInfo);


    hN=globalDnnContext.getTopNetwork();
    [isrcs,headers]=copyInterfaceCode(hN,codegendir,codetarget,dlcodeCfg);
    srcs=isrcs;

    inputLayers=networkInfo.InputLayers;
    for i=1:numel(inputLayers)

        assert(isa(inputLayers{i},'nnet.cnn.layer.ImageInputLayer')||...
        isa(inputLayers{i},'nnet.cnn.layer.SequenceInputLayer')||...
        isa(inputLayers{i},'nnet.cnn.layer.FeatureInputLayer'),...
        ['Unsupported Input Layer ',class(inputLayers{i})]);
    end


    inputSizes=networkInfo.InputLayerSizes;
    tfiles=struct();
    isYoloV2Network=any(arrayfun(@(layer)isa(layer,'nnet.cnn.layer.YOLOv2TransformLayer'),...
    networkInfo.SortedLayers));


    calibrationBatchFilePath=fullfile(codegendir,'tensorrt',networkName);
    [tfiles.srcs,tfiles.headers,tfiles.datafiles]=dltargets.internal.prepareTargetSpecificFiles(dlcodeCfg,...
    inputSizes,...
    tensorrtQuantSpecMatFile,...
    calibrationBatchFilePath,...
    isYoloV2Network);

    srcs{end+1}=[tgtName,tgtExt];

end


function[srcnames,headernames]=copyInterfaceCode(hN,codegendir,codetarget,dlcodeCfg)






    target=dlcodeCfg.DeepLearningConfig.TargetLibrary;

    sharedLibDir=fullfile(matlabroot,'toolbox','shared_dl_targets_src','api');


    rtwtypesfile=fullfile(sharedLibDir,'rtwtypes.h');
    copyfile(rtwtypesfile,codegendir,'f');
    if(strcmp(codetarget,'mex'))
        copyfile(fullfile(sharedLibDir,'cnnMain.hpp'),codegendir,'f');
    end

    tmwtypesdir=fullfile(matlabroot,'extern','include');
    copyfile([tmwtypesdir,filesep,'tmwtypes.h'],codegendir,'f');

    [csrcs,headers]=dltargets.internal.getLayerFiles(hN);

    [implsrc,implheader]=dltargets.internal.getImplFiles(hN,'arm_mali');

    csrcs=[csrcs,implsrc];
    headers=[headers,implheader];

    srcnames=cellfun(@removeFilePath,csrcs,'UniformOutput',false);
    headernames=cellfun(@removeFilePath,headers,'UniformOutput',false);


    moveFilesToCodeGenDir(csrcs,codegendir);
    moveFilesToCodeGenDir(headers,codegendir);

    dltargets.internal.layerImplFactoryEmitter.updateLayerImplFactoryHeader(hN,target,codegendir);
    dltargets.internal.layerImplFactoryEmitter.updateLayerImplFactoryFile(hN,target,codegendir);
end

function moveFilesToCodeGenDir(filesrcs,codegendir)
    for k=1:numel(filesrcs)
        copyfile(filesrcs{k},codegendir,'f');
    end
end

function fname=removeFilePath(ffile)
    [~,srcname,ext]=fileparts(ffile);
    fname=[srcname,ext];
end



