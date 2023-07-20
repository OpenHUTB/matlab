function outData=transformFrictionR2017a(inData)


    outData.NewBlockPath='';
    outData.NewInstanceData=[];

    instanceData=inData.InstanceData;



    [parameterNames{1:length(instanceData)}]=instanceData.Name;


    if~ismember('brkwy_vel',parameterNames)


        if ismember('brkwy_frc',parameterNames)
            displacement_unit='m';
        else
            displacement_unit='rad';
        end

        trans_coef_index=strcmp('trans_coef',parameterNames);
        trans_coef=instanceData(trans_coef_index).Value;
        trans_coef_unit_index=strcmp('trans_coef_unit',parameterNames);
        trans_coef_unit=instanceData(trans_coef_unit_index).Value;
        trans_coef_unit_conversion=num2str(value(simscape.Value(1,trans_coef_unit),['s/',displacement_unit]));


        if contains(trans_coef,'%')
            trans_coef=strip(extractBefore(trans_coef,'%'));
        end

        vel_thr_index=strcmp('vel_thr',parameterNames);
        vel_thr=instanceData(vel_thr_index).Value;
        vel_thr_unit_index=strcmp('vel_thr_unit',parameterNames);
        vel_thr_unit=instanceData(vel_thr_unit_index).Value;
        vel_thr_unit_conversion=num2str(value(simscape.Value(1,vel_thr_unit),[displacement_unit,'/s']));


        if contains(vel_thr,'%')
            vel_thr=strip(extractBefore(vel_thr,'%'));
        end

        trans_coef_value=str2num(trans_coef);%#ok<*ST2NM>
        if~isempty(trans_coef_value)
            trans_coef_converted_value=trans_coef_value*str2num(trans_coef_unit_conversion);
            coefficients_computed=1;
        else
            coefficients_computed=0;
        end

        vel_thr_value=str2num(vel_thr);
        if~isempty(vel_thr_value)
            vel_thr_converted_value=vel_thr_value*str2num(vel_thr_unit_conversion);
        else
            coefficients_computed=0;
        end


        if coefficients_computed
            brkwy_vel=num2str(max(exp(-(trans_coef_converted_value*vel_thr_converted_value+0.5))*(vel_thr_converted_value/2+1/trans_coef_converted_value),1e-9));
        else
            brkwy_vel=['exp(-( (',vel_thr,') * ',vel_thr_unit_conversion,' * (',trans_coef,') * ',trans_coef_unit_conversion...
            ,' + 1/2) ) * ( (',vel_thr,') * ',vel_thr_unit_conversion,' / 2 + 1 / ( (',trans_coef,') * ',trans_coef_unit_conversion,') )'];
        end



        instanceData(end+1).Name='brkwy_vel';
        instanceData(end).Value=brkwy_vel;
        instanceData(end+1).Name='brkwy_vel_unit';
        instanceData(end).Value=[displacement_unit,'/s'];
    end

    outData.NewInstanceData=instanceData;

end
