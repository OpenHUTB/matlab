classdef ground_port<int32



    enumeration
        hideground(1)
        showground(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('hideground')='physmod:ee:library:comments:enum:ground_port:map_InternallyGrounded';
            map('showground')='physmod:ee:library:comments:enum:ground_port:map_AccessibleGroundNodes';
        end
    end
end

