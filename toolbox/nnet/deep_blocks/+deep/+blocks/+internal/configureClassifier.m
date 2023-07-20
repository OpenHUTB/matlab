function configureClassifier(...
    block,...
    system,...
    networkSelect,...
    networkFilePath,...
    networkFunction,...
    miniBatchSize,...
    resizeInput,...
    classifyEnabled,...
    predictEnabled,...
    predictMode,...
    kValue,...
    forceInterpretedSim)





    simTargetLang=get_param(system,'SimTargetLang');
    simTargetLib=get_param(system,'SimDLTargetLibrary');
    gpuAcceleration=get_param(system,'GPUAcceleration')=="on";

    networkToLoad=deep.blocks.internal.getSelectedNetwork(...
    block,networkSelect,networkFilePath,networkFunction);

    topkEnabled=predictMode==2;


    networkSelected=~isempty(networkToLoad);
    isInLibrary=isempty(libinfo(block));

    simStatus=get_param(bdroot,'SimulationStatus');
    isModelUpdate=any(strcmp({'updating','initializing'},simStatus));

    systemTargetFile=get_param(bdroot,'SystemTargetFile');
    isAccel=ismember(systemTargetFile,{'modelrefsim.tlc','raccel.tlc'});

    if isInLibrary




        return
    end

    if isModelUpdate
        assert(networkSelected,message('deep_blocks:common:NoNetworkSelected'));

        networkInfo=deep.blocks.internal.getNetworkInfo(block,networkToLoad);


        assert(~networkInfo.IsDlNetwork,...
        message('deep_blocks:common:DlNetworkNotSupported'));


        assert(networkInfo.NumInputs==1&&networkInfo.NumOutputs==1,...
        message('deep_blocks:classifier:MimoNotSupported'))


        assert(~isempty(networkInfo.Classes)&&~networkInfo.IsSequenceNetwork,...
        message('deep_blocks:classifier:NetworkNotImageClassifier'))


        assert(~topkEnabled||kValue<=numel(networkInfo.Classes),...
        message('deep_blocks:classifier:KValueOutOfRange'));

        assert(~networkInfo.IsObjectDetector,...
        message('deep_blocks:common:ObjectDetectorNotSupported'));

        simSupported=networkInfo.isSimSupported(simTargetLib,simTargetLang);
        deep.blocks.internal.checkSupportPackage(simTargetLib,simTargetLang,gpuAcceleration);

        suffix='_label';
        classes=categories(networkInfo.Classes);
        classes=matlab.lang.makeValidName(classes);
        classes=matlab.lang.makeUniqueStrings(classes,{},namelengthmax-length(suffix));
        classes=strcat(classes,suffix);

        enumTypeName=deep.blocks.internal.getClassifierEnumName(bdroot,block);
        Simulink.defineIntEnumType(enumTypeName,classes,1:numel(classes));

        inputLayerSize=networkInfo.InputLayerSizes{1};
    else
        simSupported=false;
        enumTypeName='';
        inputLayerSize=[];
    end


    functionText=deep.blocks.internal.generateClassifierFunction(...
    block,...
    networkToLoad,...
    (simSupported||isAccel)&&~forceInterpretedSim,...
    inputLayerSize,...
    resizeInput,...
    miniBatchSize,...
    classifyEnabled,...
    predictEnabled,...
    topkEnabled,...
    kValue,...
    enumTypeName);

    inputNames={'image'};
    possibleOutputNames={'ypred','scores','labels'};
    outputDependencies=[classifyEnabled,predictEnabled,predictEnabled];
    outputNames=possibleOutputNames(outputDependencies);

    deep.blocks.internal.generateSubsystemInternals(...
    block,functionText,inputNames,{},outputNames,false);

end
