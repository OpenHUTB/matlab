classdef receiver_accumulator_energy_spec<int32





    enumeration
        temperature(1)
        mass_fraction(2)
        volume_fraction(3)
        enthalpy(4)
        internal_energy(5)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('temperature')='Temperature';
            map('mass_fraction')='Liquid mass fraction';
            map('volume_fraction')='Liquid volume fraction';
            map('enthalpy')='Specific enthalpy';
            map('internal_energy')='Specific internal energy';
        end
    end
end