function outData=reduced_order_flexible_solid_sl_postprocess(inData)











    outData.NewBlockPath='';
    outData.NewInstanceData=[];

    instanceData=inData.InstanceData;


    [parameterNames{1:length(instanceData)}]=instanceData.Name;
    [parameterVals{1:length(instanceData)}]=instanceData.Value;














    numFramesParam=pm_message('mech2:reducedOrderFlexibleSolid:parameters:interfaceFrames:numberOfInterfaceFrames:ParamName');
    numFramesParamIdx=contains(parameterNames,numFramesParam);
    numFramesValue=parameterVals{numFramesParamIdx};


    orientationsParam=pm_message('mech2:reducedOrderFlexibleSolid:parameters:interfaceFrames:frameOrientations:ParamName');
    if~ismember(orientationsParam,parameterNames)
        instanceData(end+1).Name=orientationsParam;
        instanceData(end).Value=['repmat([1 0 0 0],',numFramesValue,',1)'];
    end













    geomFileNameParam=pm_message('mech2:rofsGraphic:parameters:graphic:graphicType:values:partitionedGeometry:fileName:ParamName');
    [hasGeomFileNameParam,geomFileNameIdx]=ismember(geomFileNameParam,parameterNames);
    if hasGeomFileNameParam
        geomFileNameValue=parameterVals{geomFileNameIdx};
    else
        geomFileNameValue='';
    end
    if isempty(geomFileNameValue)
        graphicTypeParam=pm_message('mech2:rofsGraphic:parameters:graphic:graphicType:ParamName');
        graphicTypeIdx=strncmp(graphicTypeParam,parameterNames,length(graphicTypeParam));
        instanceData(graphicTypeIdx).Value=pm_message('mech2:rofsGraphic:parameters:graphic:graphicType:values:none:Param');
    end


    outData.NewInstanceData=instanceData;

end
