function outData=sl_postprocess(inData)


    outData.NewBlockPath='';
    outData.NewInstanceData=inData.InstanceData;

    [ParameterNames{1:length(inData.InstanceData)}]=inData.InstanceData.Name;

    fileType=pm_message('mech2:messages:parameters:geometry:fileGeometry:extGeomFileType:ParamName');

    fti=strncmp(fileType,ParameterNames,length(fileType));

    if~any(fti)
        gsp=pm_message('mech2:messages:parameters:geometry:geometryShape:ParamName');
        gsi=strncmp(gsp,ParameterNames,length(gsp));

        gshape=inData.InstanceData(gsi).Value;
        fileGeom=pm_message('mech2:messages:parameters:geometry:fileGeometry:VisibleId');
        if strcmp(gshape,fileGeom)

            outData.NewInstanceData(end+1).Name=fileType;
            outData.NewInstanceData(end).Value=...
            pm_message('mech2:messages:parameters:geometry:fileGeometry:extGeomFileType:paramValue:Stl');
        end
    end



    outData=simmechanics.library.sl_postprocess(outData);
