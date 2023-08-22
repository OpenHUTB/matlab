function configureObjectDetector(...
    block,...
    system,...
    detectorSelect,...
    detectorFilePath,...
    detectorFunction,...
    useROI,...
    roi,...
    threshold,...
    numStrongestRegions,...
    useMinSize,...
    minSize,...
    useMaxSize,...
    maxSize,...
    maxDetections,...
    bboxesEnabled,...
    labelsEnabled,...
    scoresEnabled,...
    forceInterpretedSim)
    simTargetLang=get_param(system,'SimTargetLang');
    simTargetLib=get_param(system,'SimDLTargetLibrary');
    gpuAcceleration=get_param(system,'GPUAcceleration')=="on";
    detectorToLoad=deep.blocks.internal.getSelectedNetwork(...
    block,detectorSelect,detectorFilePath,detectorFunction);
    detectorSelected=~isempty(detectorToLoad);
    isInLibrary=isempty(libinfo(block));
    simStatus=get_param(system,'SimulationStatus');
    isModelUpdate=any(strcmp({'updating','initializing'},simStatus));
    systemTargetFile=get_param(system,'SystemTargetFile');
    isAccel=ismember(systemTargetFile,{'modelrefsim.tlc','raccel.tlc'});

    if isInLibrary
        return
    end

    if isModelUpdate
        assert(detectorSelected,message('vision:ObjectDetectorBlock:NoDetectorSelected'));
        detectorInfo=deep.blocks.internal.getDetectorInfo(block,detectorToLoad);
        simSupported=detectorInfo.isSimSupported(simTargetLib,simTargetLang);
        deep.blocks.internal.checkSupportPackage(simTargetLib,simTargetLang,gpuAcceleration);

        suffix='_label';
        classes=categories(detectorInfo.Classes);
        classes=matlab.lang.makeValidName(classes);
        classes=matlab.lang.makeUniqueStrings(classes,{},namelengthmax-length(suffix));
        classes=strcat(classes,suffix);
        enumTypeName=deep.blocks.internal.getClassifierEnumName(system,block);
        Simulink.defineIntEnumType(enumTypeName,classes,1:numel(classes));
        detectArgs=generateDetectArgs(detectorInfo,useROI,roi,threshold,numStrongestRegions,useMinSize,minSize,useMaxSize,maxSize);
        ssbmArgs=generateSSBMArgs(detectorInfo,maxDetections,threshold);
    else
        simSupported=false;
        enumTypeName='';
        detectArgs={};
        ssbmArgs={};
    end

    functionText=deep.blocks.internal.generateObjectDetectorFunction(...
    detectorToLoad,...
    (simSupported||isAccel)&&~forceInterpretedSim,...
    detectArgs,...
    ssbmArgs,...
    maxDetections,...
    bboxesEnabled,...
    labelsEnabled,...
    scoresEnabled,...
    enumTypeName);

    inputNames={'Image'};
    possibleOutputNames={'Bboxes','Labels','Scores'};
    outputDependencies=[bboxesEnabled,labelsEnabled,scoresEnabled];
    outputNames=possibleOutputNames(outputDependencies);
    mlfbPortInfo=generateMLFBPortInfo(bboxesEnabled,labelsEnabled,scoresEnabled,maxDetections);
    deep.blocks.internal.generateSubsystemInternals(...
    block,functionText,inputNames,{},outputNames,false,mlfbPortInfo);

    Simulink.suppressDiagnostic([block,'/MLFB'],'Stateflow:Runtime:DataSaturateError');

end


function detectArgs=generateDetectArgs(detectorInfo,useROI,roi,threshold,numStrongestRegions,useMinSize,minSize,useMaxSize,maxSize)
    index=1;

    if useROI
        detectArgs{index}=roi;
        index=index+1;
    end

    if detectorInfo.ThresholdSupported
        detectArgs{index}='Threshold';
        detectArgs{index+1}=threshold;
        index=index+2;
    end

    if detectorInfo.NumStrongestRegionsSupported
        detectArgs{index}='NumStrongestRegions';
        detectArgs{index+1}=numStrongestRegions;
        index=index+2;
    end

    if detectorInfo.MinSizeSupported&&useMinSize
        detectArgs{index}='MinSize';
        detectArgs{index+1}=minSize;
        index=index+2;
    end

    if detectorInfo.MaxSizeSupported&&useMaxSize
        detectArgs{index}='MaxSize';
        detectArgs{index+1}=maxSize;
        index=index+2;
    end

    detectArgs{index}='SelectStrongest';
    detectArgs{index+1}=false;
end


function ssbmArgs=generateSSBMArgs(detectorInfo,maxDetections,threshold)
    ssbmArgs{1}='NumStrongest';
    ssbmArgs{2}=maxDetections;

    ssbmArgs{3}='RatioType';
    ssbmArgs{4}=detectorInfo.RatioTypeDefault;

    if detectorInfo.UseThresholdAsOverlap
        ssbmArgs{5}='OverlapThreshold';
        ssbmArgs{6}=threshold;
    end

end


function mlfbPortInfo=generateMLFBPortInfo(bboxesEnabled,labelsEnabled,scoresEnabled,maxDetections)
    index=1;
    mlfbPortInfo=[];

    if bboxesEnabled
        mlfbPortInfo(index).Name='bboxes';
        mlfbPortInfo(index).Scope='Output';
        mlfbPortInfo(index).VariableSize=true;
        mlfbPortInfo(index).Size=['[',num2str(maxDetections),' 4]'];
        index=index+1;
    end

    if labelsEnabled
        mlfbPortInfo(index).Name='labels';
        mlfbPortInfo(index).Scope='Output';
        mlfbPortInfo(index).VariableSize=true;
        mlfbPortInfo(index).Size=['[',num2str(maxDetections),' 1]'];
        index=index+1;
    end

    if scoresEnabled
        mlfbPortInfo(index).Name='scores';
        mlfbPortInfo(index).Scope='Output';
        mlfbPortInfo(index).VariableSize=true;
        mlfbPortInfo(index).Size=['[',num2str(maxDetections),' 1]'];
    end

end
