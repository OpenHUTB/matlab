classdef rotorangle<int32
    enumeration
        qaxis(1)
        daxis(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('qaxis')='physmod:ee:library:comments:enum:rotorangle:map_AngleBetweenTheAphaseMagneticAxisAndTheQaxis';
            map('daxis')='physmod:ee:library:comments:enum:rotorangle:map_AngleBetweenTheAphaseMagneticAxisAndTheDaxis';
        end
    end
end
