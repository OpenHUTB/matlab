function out=transformR2021b2PControlledReservoir(in)




    out=in;

    energy_spec=getValue(out,'energy_spec');
    if~isempty(energy_spec)
        if strcmp(energy_spec,'foundation.enum.enthalpy_internal_energy_spec.enthalpy')||strcmp(energy_spec,'1')
            energy_spec='foundation.enum.ControlledReservoirEnergySpec2P.Enthalpy';
        elseif strcmp(energy_spec,'foundation.enum.enthalpy_internal_energy_spec.internal_energy')||strcmp(energy_spec,'2')
            energy_spec='foundation.enum.ControlledReservoirEnergySpec2P.InternalEnergy';
        end
        out=setValue(out,'energy_spec',energy_spec);
    end

end