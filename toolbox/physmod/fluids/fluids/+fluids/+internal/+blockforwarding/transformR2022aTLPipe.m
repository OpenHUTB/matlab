function out=transformR2022aTLPipe(in)







    out=in;

    Dh_rigid_val=getValue(out,'Dh_rigid');
    Dh_rigid_conf_val=getValue(out,'Dh_rigid_conf');
    Dh_rigid_unit_val=getValue(out,'Dh_rigid_unit');
    comp_parameterization=getValue(out,'dynamic_compressibility');
    wall_parameterization=getValue(out,'wall_spec');

    if(~isempty(comp_parameterization)&&~isempty(wall_parameterization))
        if eval(comp_parameterization)==1
            if eval(wall_parameterization)==1
                out=setValue(out,'Dh',Dh_rigid_val);
                out=setValue(out,'Dh_conf',Dh_rigid_conf_val);
                out=setValue(out,'Dh_unit',Dh_rigid_unit_val);
            end
        end
    end

end