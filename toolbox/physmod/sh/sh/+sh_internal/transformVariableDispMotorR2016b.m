function[outData]=transformVariableDispMotorR2016b(inData)






    outData.NewBlockPath='';
    outData.NewInstanceData=[];


    instanceData=inData.InstanceData;
    [parameterNames{1:length(instanceData)}]=instanceData.Name;



    if(ismember('efficiency_tot',parameterNames))...
        &&(~ismember('torque_pressure_coeff',parameterNames))

        volume_efficiency_index=strcmp('efficiency_vol',parameterNames);
        volume_efficiency=instanceData(volume_efficiency_index).Value;

        total_efficiency_index=strcmp('efficiency_tot',parameterNames);
        total_efficiency=instanceData(total_efficiency_index).Value;

        displacement_index=strcmp('D_max',parameterNames);
        displacement=instanceData(displacement_index).Value;
        displacement_unit_index=strcmp('D_max_unit',parameterNames);
        displacement_unit=instanceData(displacement_unit_index).Value;

        interp_method_index=strcmp('interp_method',parameterNames);
        interp_method=instanceData(interp_method_index).Value;


        if(interp_method=='3')
            instanceData(interp_method_index).Value='3';
        end


        instanceData(end+1).Name='torque_pressure_coeff';
        instanceData(end).Value=[num2str(value(simscape.Value(1,displacement_unit),'m^3/rad')),'*(',displacement,')*( 1-(',total_efficiency,')/(',volume_efficiency,'))'];
        instanceData(end+1).Name='torque_pressure_coeff_unit';
        instanceData(end).Value='N*m/Pa';


        instanceData(end+1).Name='no_load_torque';
        instanceData(end).Value='0';
        instanceData(end+1).Name='no_load_torque_unit';
        instanceData(end).Value='N*m';
    end

    outData.NewInstanceData=instanceData;

end

