function configureSequenceNetworkPredict(...
    block,...
    system,...
    networkSelect,...
    networkFilePath,...
    networkFunction,...
    inputFormats,...
    forceInterpretedSim,...
    dlnetworkEnabled)





    simTargetLang=get_param(system,'SimTargetLang');
    simTargetLib=get_param(system,'SimDLTargetLibrary');
    gpuAcceleration=get_param(system,'GPUAcceleration')=="on";

    networkToLoad=deep.blocks.internal.getSelectedNetwork(...
    block,networkSelect,networkFilePath,networkFunction);

    inputFormats=inputFormats(:,2);


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

        assert(networkInfo.IsSequenceNetwork,...
        message('deep_blocks:stateful:NetworkNotSequence'));

        assert(~networkInfo.IsObjectDetector,...
        message('deep_blocks:common:ObjectDetectorNotSupported'));

        simSupported=networkInfo.isSimSupported(simTargetLib,simTargetLang,UpdateState=true);
        isDlNetwork=networkInfo.IsDlNetwork;

        if isModelUpdate
            deep.blocks.internal.checkSupportPackage(simTargetLib,simTargetLang,gpuAcceleration);
            deep.blocks.internal.validateInputDataFormats(inputFormats,isDlNetwork);
        end

        inputNames=networkInfo.InputLayerNames;
        outputNames=networkInfo.OutputLayerNames;
        numInputLayers=networkInfo.NumInputs;
        numOutputLayers=networkInfo.NumOutputs;
    else
        simSupported=false;
        isDlNetwork=false;
        inputNames={'input'};
        outputNames={'output'};
        numInputLayers=numel(inputNames);
        numOutputLayers=numel(outputNames);
    end



    functionText=deep.blocks.internal.generateSequenceNetworkPredictFunction(...
    block,...
    networkToLoad,...
    numInputLayers,...
    numOutputLayers,...
    (simSupported||isAccel)&&~forceInterpretedSim,...
    isDlNetwork,...
    inputFormats);

    deep.blocks.internal.generateSubsystemInternals(...
    block,functionText,inputNames,outputNames,{},true);

end
