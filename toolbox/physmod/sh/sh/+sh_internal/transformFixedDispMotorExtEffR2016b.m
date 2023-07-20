function[outData]=transformFixedDispMotorExtEffR2016b(inData)




    outData.NewBlockPath='';
    outData.NewInstanceData=[];


    instanceData=inData.InstanceData;
    [parameterNames{1:length(instanceData)}]=instanceData.Name;



    if(ismember('w_th',parameterNames))...
        &&(~ismember('pressure_threshold',parameterNames))

        w_threshold_index=strcmp('w_th',parameterNames);
        w_threshold=instanceData(w_threshold_index).Value;
        w_threshold_unit_index=strcmp('w_th_unit',parameterNames);
        w_threshold_unit=instanceData(w_threshold_unit_index).Value;


        instanceData(end+1).Name='omega_threshold';
        instanceData(end).Value=['(',w_threshold,')'];
        instanceData(end+1).Name='omega_threshold_unit';
        instanceData(end).Value=['(',w_threshold_unit,')'];
    end

    outData.NewInstanceData=instanceData;

end

