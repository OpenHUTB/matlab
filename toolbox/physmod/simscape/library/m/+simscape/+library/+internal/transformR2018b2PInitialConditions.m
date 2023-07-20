function out=transformR2018b2PInitialConditions(in)






    out=in;



    fluid_spec=getValue(out,'fluid_spec');
    energy_spec=getValue(out,'energy_spec');
    if~isempty(fluid_spec)&&isempty(energy_spec)
        if strcmp(fluid_spec,'1')||strcmp(fluid_spec,'3')
            energy_spec='foundation.enum.energy_spec.temperature';
        elseif strcmp(fluid_spec,'2')
            energy_spec='foundation.enum.energy_spec.quality';
        end
        out=setValue(out,'energy_spec',energy_spec);
    end

end