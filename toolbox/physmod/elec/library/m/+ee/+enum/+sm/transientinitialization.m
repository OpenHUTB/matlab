classdef transientinitialization<int32



    enumeration
        mechanical(1)
        electrical(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('mechanical')='physmod:ee:library:comments:enum:sm:transientinitialization:map_MechanicalAndMagneticStates';
            map('electrical')='physmod:ee:library:comments:enum:sm:transientinitialization:map_ElectricalPowerAndVoltageOutput';
        end
    end
end

