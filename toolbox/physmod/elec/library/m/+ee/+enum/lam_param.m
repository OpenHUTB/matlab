classdef lam_param<int32



    enumeration
        damping(1)
        current(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('damping')='physmod:ee:library:comments:enum:lam_param:damping';
            map('current')='physmod:ee:library:comments:enum:lam_param:current';
        end
    end
end

