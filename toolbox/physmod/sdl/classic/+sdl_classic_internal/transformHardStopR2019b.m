function[outData]=transformHardStopR2019b(inData)





    outData.NewBlockPath='';
    outData.NewInstanceData=[];


    instanceData=inData.InstanceData;
    [parameterNames{1:length(instanceData)}]=instanceData.Name;


    Limit_upper_index=strcmp('Limit_upper',parameterNames);
    Limit_upper=instanceData(Limit_upper_index).Value;
    Limit_lower_index=strcmp('Limit_lower',parameterNames);
    Limit_lower=instanceData(Limit_lower_index).Value;

    Limit_upper_value=str2num(Limit_upper);%#ok<*ST2NM>
    Limit_lower_value=str2num(Limit_lower);%#ok<*ST2NM>


    if isempty(Limit_upper_value)
        Limit_lower_value_computed=['-',Limit_upper];
    else
        Limit_lower_value_computed=num2str(-Limit_upper_value);
    end


    if isempty(Limit_lower_value)
        Limit_upper_value_computed=['-',Limit_lower];
    else
        Limit_upper_value_computed=num2str(-Limit_lower_value);
    end


    instanceData(Limit_lower_index).Name='lower_bnd';
    instanceData(Limit_lower_index).Value=Limit_lower_value_computed;


    instanceData(Limit_upper_index).Name='upper_bnd';
    instanceData(Limit_upper_index).Value=Limit_upper_value_computed;


    Stiffness_index=strcmp('Stiffness',parameterNames);
    instanceData(Stiffness_index).Name='stiff_up';

    Stiffness_value=instanceData(Stiffness_index).Value;
    instanceData(end+1).Name='stiff_low';
    instanceData(end).Value=num2str(Stiffness_value);


    Damping_index=strcmp('Damping',parameterNames);
    instanceData(Damping_index).Name='D_up';

    Damping_value=instanceData(Damping_index).Value;
    instanceData(end+1).Name='D_low';
    instanceData(end).Value=num2str(Damping_value);







    instanceData(end+1).Name='model';
    instanceData(end).Value='3';


    instanceData(end+1).Name='ComponentPath';
    instanceData(end).Value='foundation.mechanical.rotational.hardstop';
    instanceData(end+1).Name='SourceFile';
    instanceData(end).Value='foundation.mechanical.rotational.hardstop';

    outData.NewInstanceData=instanceData;

end
