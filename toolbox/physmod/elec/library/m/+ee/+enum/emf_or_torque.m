classdef emf_or_torque<int32



    enumeration
        kv(1)
        ki(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('kv')='physmod:ee:library:comments:enum:emf_or_torque:kv';
            map('ki')='physmod:ee:library:comments:enum:emf_or_torque:ki';
        end
    end
end

