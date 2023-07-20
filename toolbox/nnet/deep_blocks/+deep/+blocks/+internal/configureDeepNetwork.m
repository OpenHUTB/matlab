function configureDeepNetwork(...
    block,...
    system,...
    networkSelect,...
    networkFilePath,...
    networkFunction,...
    miniBatchSize,...
    predictEnabled,...
    inputFormats,...
    activationLayers,...
    forceInterpretedSim,...
    dlnetworkEnabled)





    simTargetLang=get_param(system,'SimTargetLang');
    simTargetLib=get_param(system,'SimDLTargetLibrary');
    gpuAcceleration=get_param(system,'GPUAcceleration')=="on";

    networkToLoad=deep.blocks.internal.getSelectedNetwork(...
    block,networkSelect,networkFilePath,networkFunction);

    inputFormats=inputFormats(:,2);
    try
        activationLayers=eval(activationLayers);
    catch
        error(message('deep_blocks:predict:ActivationsNotCell'));
    end

    networkSelected=~isempty(networkToLoad);
    isInLibrary=isempty(libinfo(block));

    simStatus=get_param(bdroot,'SimulationStatus');
    isModelUpdate=any(strcmp({'updating','initializing'},simStatus));

    systemTargetFile=get_param(bdroot,'SystemTargetFile');
    isAccel=ismember(systemTargetFile,{'modelrefsim.tlc','raccel.tlc'});

    if isInLibrary




        return
    end

    assert(networkSelected,message('deep_blocks:common:NoNetworkSelected'));

    try
        networkInfo=deep.blocks.internal.getNetworkInfo(block,networkToLoad);
    catch e
        networkInfo=[];
        if isModelUpdate
            rethrow(e);
        end
    end

    validNetwork=~isempty(networkInfo);
    if validNetwork

        assert(~networkInfo.IsDlNetwork||dlnetworkEnabled,...
        message('deep_blocks:predict:DlNetworkNotSupported'));

        assert(~networkInfo.IsObjectDetector,...
        message('deep_blocks:common:ObjectDetectorNotSupported'));

        simSupported=networkInfo.isSimSupported(simTargetLib,simTargetLang);
        isDlNetwork=networkInfo.IsDlNetwork;

        if isModelUpdate
            deep.blocks.internal.checkSupportPackage(simTargetLib,simTargetLang,gpuAcceleration);
            deep.blocks.internal.validateInputDataFormats(inputFormats,isDlNetwork);
        end


        assert(iscell(activationLayers),message('deep_blocks:predict:ActivationsNotCell'));
        for i=1:numel(activationLayers)
            layer=activationLayers{i};
            assert(any(strcmp(layer,networkInfo.ActivationNames)),message('deep_blocks:predict:InvalidActivationLayer',layer));
        end

        inputNames=networkInfo.InputLayerNames;
        numInputLayers=networkInfo.NumInputs;

        outputNames=cellfun(...
        @(layer)[layer,'_activations'],...
        activationLayers,...
        'UniformOutput',false);

        activationNames=outputNames;

        predictOutputNames={};
        if predictEnabled
            predictOutputNames=networkInfo.OutputLayerNames';
        end
    else
        simSupported=false;
        isDlNetwork=false;
        inputNames={'input'};
        activationNames={};
        predictOutputNames={};
        if predictEnabled
            predictOutputNames={'output'};
        end

        numInputLayers=numel(inputNames);
    end


    functionText=deep.blocks.internal.generateDeepNetworkFunction(...
    block,...
    networkToLoad,...
    numInputLayers,...
    numel(predictOutputNames),...
    numel(activationNames),...
    (simSupported||isAccel)&&~forceInterpretedSim,...
    isDlNetwork,...
    miniBatchSize,...
    predictEnabled,...
    inputFormats,...
    activationLayers);

    deep.blocks.internal.generateSubsystemInternals(...
    block,functionText,inputNames,predictOutputNames,activationNames,false);

end
