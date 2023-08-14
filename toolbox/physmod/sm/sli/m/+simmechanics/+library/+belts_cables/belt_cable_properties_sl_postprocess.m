function outData=belt_cable_properties_sl_postprocess(inData)











    outData.NewBlockPath='';
    outData.NewInstanceData=[];

    instanceData=inData.InstanceData;


    [ParameterNames{1:length(instanceData)}]=instanceData.Name;




    drumBeltCableAlignParam=...
    pm_message(['mech2:messages:parameters:beltCable:beltCableProperties:'...
    ,'drumBeltCableAlignment:ParamName']);

    if~ismember(drumBeltCableAlignParam,ParameterNames)


        instanceData(end+1).Name=drumBeltCableAlignParam;
        instanceData(end).Value='MonitoredPlanar';
    end


    outData.NewInstanceData=instanceData;

end

