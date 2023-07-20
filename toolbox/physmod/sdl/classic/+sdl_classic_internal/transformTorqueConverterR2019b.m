function[outData]=transformTorqueConverterR2019b(inData)





    outData.NewBlockPath='';
    outData.NewInstanceData=[];


    instanceData=inData.InstanceData;
    [parameterNames{1:length(instanceData)}]=instanceData.Name;


    SpeedRatio_index=strcmp('SpeedRatio',parameterNames);
    instanceData(SpeedRatio_index).Name='n_vector';


    TorqueRatio_index=strcmp('TorqueRatio',parameterNames);
    instanceData(TorqueRatio_index).Name='trq_vector';


    CapacityFactor_index=strcmp('CapacityFactor',parameterNames);
    instanceData(CapacityFactor_index).Name='cf_vector';


    instanceData(end+1).Name='model_lag';
    instanceData(end).Value='0';


    instanceData(end+1).Name='SourceFile';
    instanceData(end).Value='sdl.couplings.torque_converter';

    outData.NewInstanceData=instanceData;

end
