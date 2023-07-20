function out=transformR2021aDisplacementPumpsMotors(in)





    out=in;


    blk=string(getClass(out));


    torque_pressure_coeff=stripComments(getValue(out,'torque_pressure_coeff'));
    torque_pressure_coeff_unit=getUnit(out,'torque_pressure_coeff');
    no_load_torque=stripComments(getValue(out,'no_load_torque'));
    no_load_torque_unit=getUnit(out,'no_load_torque');
    if contains(blk,'fixed_')
        displacement=stripComments(getValue(out,'displacement'));
        displacement_unit=getUnit(out,'displacement');
    else
        displacement=stripComments(getValue(out,'displacement_nominal'));
        displacement_unit=getUnit(out,'displacement_nominal');
    end
    p_nominal=stripComments(getValue(out,'p_nominal'));
    p_nominal_unit=getUnit(out,'p_nominal');



    if~isempty(torque_pressure_coeff)&&~isempty(no_load_torque)...
        &&~isempty(displacement)&&~isempty(p_nominal)

        if isempty(torque_pressure_coeff_unit)
            torque_pressure_coeff_unit='N*m/MPa';
        end
        if isempty(no_load_torque_unit)
            no_load_torque_unit='N*m';
        end
        if isempty(displacement_unit)
            displacement_unit='cm^3/rev';
        end
        if isempty(p_nominal_unit)
            p_nominal_unit='MPa';
        end


        torque_pressure_coeff_conf=getRTConfig(out,'torque_pressure_coeff');


        term1=['(',torque_pressure_coeff,')/(',displacement,')'];
        term2=['(',no_load_torque,')/(',displacement,')/(',p_nominal,')'];


        factor1=value(simscape.Value(1,torque_pressure_coeff_unit)/simscape.Value(1,displacement_unit),'1');
        factor2=value(simscape.Value(1,no_load_torque_unit)/simscape.Value(1,displacement_unit)/simscape.Value(1,p_nominal_unit),'1');


        eval1=protectedNumericConversion(term1);
        eval2=protectedNumericConversion(term2);



        if~isempty(eval1)&&isfinite(eval1)
            term1=num2str(double(eval1)*factor1,16);
        else
            term1=[term1,'*',num2str(factor1,16)];
        end

        if~isempty(eval2)&&isfinite(eval2)
            term2=num2str(double(eval2)*factor2,16);
        else
            term2=[term2,'*',num2str(factor2,16)];
        end


        if contains(blk,'_pump')
            term3=['1/(1 + ',term1,' + ',term2,')'];
        else
            term3=['1 - ',term1,' - ',term2];
        end


        eval3=protectedNumericConversion(term3);

        if~isempty(eval3)&&isfinite(eval3)
            mech_eff_nominal=num2str(double(eval3),16);
        else
            mech_eff_nominal=term3;
        end


        out=setValue(out,'mech_eff_nominal',mech_eff_nominal);
        out=setUnit(out,'mech_eff_nominal','1');
        out=setRTConfig(out,'mech_eff_nominal',torque_pressure_coeff_conf);
    end

end