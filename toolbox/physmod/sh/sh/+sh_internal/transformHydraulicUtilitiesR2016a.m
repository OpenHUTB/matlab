function outData=transformHydraulicUtilitiesR2016a(inData)


    outData.NewBlockPath='';
    outData.NewInstanceData=[];

    instanceData=inData.InstanceData;



    parameterNames={instanceData.Name};

    SysTemp_unit_index=strcmp('SysTemp_unit',parameterNames);
    instanceData(SysTemp_unit_index).Value='1';

    outData.NewInstanceData=instanceData;

end
