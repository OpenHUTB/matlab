function outData=sl_postprocess3(inData)





    outData=simmechanics.library.body_elements.sl_postprocess(inData);


    gsParam=pm_message('mech2:messages:parameters:geometry:geometryShape:ParamName');
    geomShape=inData.InstanceData(strcmp({inData.InstanceData.Name},gsParam));
    switch(geomShape.Value)
    case{'Brick'}
        outData.NewBlockPath='sm_lib/Body Elements/Brick Solid';
    case{'Cylinder'}
        outData.NewBlockPath='sm_lib/Body Elements/Cylindrical Solid';
    case{'Sphere'}
        outData.NewBlockPath='sm_lib/Body Elements/Spherical Solid';
    case{'Ellipsoid'}
        outData.NewBlockPath='sm_lib/Body Elements/Ellipsoidal Solid';
    case{'RegularExtrusion'}
        outData.NewBlockPath='sm_lib/Body Elements/Extruded Solid';
        outData.NewInstanceData(end+1).Name=...
        pm_message('sm:extrudedSolid:parameters:geometry:extrusionType:ParamName');
        outData.NewInstanceData(end).Value='Regular';
    case{'GeneralExtrusion'}
        outData.NewBlockPath='sm_lib/Body Elements/Extruded Solid';
        outData.NewInstanceData(end+1).Name=...
        pm_message('sm:extrudedSolid:parameters:geometry:extrusionType:ParamName');
        outData.NewInstanceData(end).Value='General';
    case{'GeneralSolidOfRevolution'}
        outData.NewBlockPath='sm_lib/Body Elements/Revolved Solid';
    case{'FromFile'}
        outData.NewBlockPath='sm_lib/Body Elements/File Solid';
        eftParam=pm_message('mech2:messages:parameters:geometry:fileGeometry:extGeomFileType:ParamName');
        fileType=inData.InstanceData(strcmp({inData.InstanceData.Name},eftParam));

        if~isempty(fileType)
            if strcmpi(fileType.Value,'STL')
                outData.NewInstanceData(end+1).Name=...
                pm_message('mech2:messages:parameters:geometry:fileGeometry:unitType:ParamName');
                outData.NewInstanceData(end).Value='Custom';
            end

            if any(strcmpi(fileType.Value,{'STEP','STP'}))
                sfParam=pm_message('mech2:messages:parameters:solid:frames:ParamName');
                frames=inData.InstanceData(strcmp({inData.InstanceData.Name},sfParam));

                if~isempty(frames)&&any(strfind(frames.Value,'GeometricFeature'))
                    outData.NewInstanceData(end+1).Name=...
                    pm_message('mech2:externalFileSolid:parameters:stepReaderType:ParamName');
                    outData.NewInstanceData(end).Value='OCC_DEPRECATED';
                end
            end
        end
    end


