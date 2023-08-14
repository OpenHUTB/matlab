function[outData]=transformTorsionalSpringDamperR2019b(inData)







    outData.NewBlockPath='';
    outData.NewInstanceData=[];


    instanceData=inData.InstanceData;
    [parameterNames{1:length(instanceData)}]=instanceData.Name;



    Backlash_index=strcmp('Backlash',parameterNames);
    Backlash=instanceData(Backlash_index).Value;

    Stiffness_index=strcmp('k',parameterNames);

    Damping_index=strcmp('c',parameterNames);

    initial_offset_rad_index=strcmp('x0',parameterNames);
    initial_offset_rad=instanceData(initial_offset_rad_index).Value;


    Backlash_value=str2num(Backlash);%#ok<*ST2NM>
    if isempty(Backlash_value)
        use_hardstops=1;
    else
        if Backlash_value==0
            use_hardstops=0;
        else
            use_hardstops=1;
        end
    end


    instanceData(end+1).Name='model_hardstop';
    if use_hardstops
        instanceData(end).Value='1';
    else
        instanceData(end).Value='0';
    end


    if use_hardstops


        instanceData(end+1).Name='hardstop_model';
        instanceData(end).Value='3';

        instanceData(Backlash_index).Name='lower_bound';
        lower_bound_index=Backlash_index;
        instanceData(end+1).Name='lower_bound_unit';
        instanceData(end).Value='rad';
        instanceData(end+1).Name='upper_bound';
        upper_bound_index=length(instanceData);
        instanceData(end+1).Name='upper_bound_unit';
        instanceData(end).Value='rad';

        if isempty(Backlash_value)

            instanceData(lower_bound_index).Value=['-',Backlash];
            instanceData(upper_bound_index).Value=[Backlash,' + eps(',Backlash,')'];
        else

            instanceData(lower_bound_index).Value=['-',Backlash];
            instanceData(upper_bound_index).Value=Backlash;
        end


        instanceData(Stiffness_index).Name='k_endstop';
        instanceData(Damping_index).Name='D_endstop';



        instanceData(end+1).Name='k';
        instanceData(end).Value='0';


        instanceData(end+1).Name='mu_visc';
        instanceData(end).Value='0';


    else



        instanceData(Stiffness_index).Name='k';


        instanceData(Damping_index).Name='mu_visc';

    end



    instanceData(end+1).Name='x0_unit';
    instanceData(end).Value='rad';



    initial_offset_rad_value=str2num(initial_offset_rad);%#ok<*ST2NM>
    if isempty(initial_offset_rad_value)
        instanceData(initial_offset_rad_index).Value=['-',initial_offset_rad];
    else
        if initial_offset_rad_value==0

        else
            instanceData(initial_offset_rad_index).Value=['-',initial_offset_rad];
        end
    end




    instanceData(end+1).Name='ComponentPath';
    instanceData(end).Value='sdl.couplings.torsional_damper';
    instanceData(end+1).Name='SourceFile';
    instanceData(end).Value='sdl.couplings.torsional_damper';

    outData.NewInstanceData=instanceData;

end
