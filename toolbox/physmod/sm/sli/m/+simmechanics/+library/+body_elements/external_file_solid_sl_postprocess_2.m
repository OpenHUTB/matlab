function outData=external_file_solid_sl_postprocess_2(inData)












    outData.NewBlockPath='';
    outData.NewInstanceData=[];

    instanceData=inData.InstanceData;


    [parameterNames{1:length(instanceData)}]=instanceData.Name;
    [parameterVals{1:length(instanceData)}]=instanceData.Value;























    filenameParam=...
    pm_message('mech2:externalFileSolid:parameters:geometry:fileName:ParamName');
    filenameParamIdx=contains(parameterNames,filenameParam);
    hasFilenameParam=any(filenameParamIdx);
    if hasFilenameParam
        filenameParamVal=parameterVals{filenameParamIdx};
    else
        filenameParamVal='';
    end

    isSTEP=contains(filenameParamVal,'STEP','IgnoreCase',true)||...
    contains(filenameParamVal,'STP','IgnoreCase',true);






    serializedFramesParam=...
    pm_message('mech2:messages:parameters:solid:frames:ParamName');
    serializedFramesParamIdx=contains(parameterNames,serializedFramesParam);
    hasSerializedFramesParam=any(serializedFramesParamIdx);
    if hasSerializedFramesParam
        serializedFramesParamVal=parameterVals{serializedFramesParamIdx};
    else
        serializedFramesParamVal='';
    end

    hasGeomBasedFrames=contains(serializedFramesParamVal,'GeometricFeature');






    stepReaderTypeParam=...
    pm_message('mech2:externalFileSolid:parameters:stepReaderType:ParamName');
    stepReaderTypeParamIdx=contains(parameterNames,stepReaderTypeParam);

    hasStepReaderTypeParam=any(stepReaderTypeParamIdx);



    isOCC=hasStepReaderTypeParam&&...
    contains(parameterVals{stepReaderTypeParamIdx},'OCC');


    if isSTEP&&hasGeomBasedFrames&&isOCC
        instanceData(stepReaderTypeParamIdx).Value='OCC_DEPRECATED';
    elseif hasStepReaderTypeParam
        instanceData(stepReaderTypeParamIdx).Value='HEX';
    else
        instanceData(end+1).Name=stepReaderTypeParam;
        instanceData(end).Value='HEX';
    end


    outData.NewInstanceData=instanceData;

end


