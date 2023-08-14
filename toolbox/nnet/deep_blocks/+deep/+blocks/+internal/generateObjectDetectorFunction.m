function functionText=generateObjectDetectorFunction(...
    detectorToLoad,...
    simSupported,...
    detectArgs,...
    ssbmArgs,...
    maxDetections,...
    bboxesEnabled,...
    labelsEnabled,...
    scoresEnabled,...
    enumTypeName)





    possibleOutputs=["bboxes","labels","scores"];
    possibleTempOutputs=["bboxes","labels_idxs","scores"];
    outputDependencies=[bboxesEnabled,labelsEnabled,scoresEnabled];

    possibleConversion="labels = "+enumTypeName+"(labels_idxs);";
    conversionDependency=labelsEnabled;


    outputs=possibleOutputs(outputDependencies);
    tempOutputs=possibleTempOutputs(outputDependencies);
    conversions=possibleConversion(conversionDependency);


    outputsString=join(outputs,", ");
    if isempty(outputsString)
        outputsString="";
    end
    outputsString="["+outputsString+"]";

    tempOutputsString=join(tempOutputs,", ");
    if isempty(tempOutputsString)
        tempOutputsString="";
    end
    tempOutputsString="["+tempOutputsString+"]";


    numOutputs=length(outputs);
    if numOutputs>0
        signature="function "+outputsString+" = objectDetector(image)";
    else
        signature="function objectDetector(image)";
    end


    detectArgsStr=deep.blocks.internal.cell2str(detectArgs);
    ssbmArgsStr=deep.blocks.internal.cell2str(ssbmArgs);


    [useExtrinsicLines,extrinsicVar]=deep.blocks.internal.generateUseExtrinsicCode(simSupported);

    tempInputsString=join([...
    "image",...
    "'"+detectorToLoad+"'",...
    extrinsicVar,...
    detectArgsStr,...
    ssbmArgsStr,...
    string(maxDetections),...
    string(bboxesEnabled),...
    string(labelsEnabled),...
    string(scoresEnabled)],", ");
    if numOutputs>0
        call=tempOutputsString+" = deep.blocks.internal.objectDetector("+tempInputsString+");";
    else
        call="deep.blocks.internal.objectDetector("+tempInputsString+");";
    end


    functionText=join([...
    signature,...
    useExtrinsicLines,...
    call,...
    conversions{:},...
    "end"],newline);

end
