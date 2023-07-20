classdef rotationalDetentParameterization<int32

    enumeration
        torque(1)
        tlu(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('torque')='physmod:sdl:library:enum:TorqueWidth';
            map('tlu')='physmod:sdl:library:enum:TableLookup';
        end
    end
end