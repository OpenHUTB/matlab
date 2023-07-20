classdef load_flow_source_impedance<int32




    enumeration
        None(0)
        XRratio(1)
        R(2)
        L(3)
        RL(4)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('None')='physmod:ee:library:comments:enum:sources:load_flow_source_impedance:map_None';
            map('XRratio')='physmod:ee:library:comments:enum:sources:load_flow_source_impedance:map_XRratio';
            map('R')='physmod:ee:library:comments:enum:sources:load_flow_source_impedance:map_R';
            map('L')='physmod:ee:library:comments:enum:sources:load_flow_source_impedance:map_L';
            map('RL')='physmod:ee:library:comments:enum:sources:load_flow_source_impedance:map_RL';
        end
    end
end