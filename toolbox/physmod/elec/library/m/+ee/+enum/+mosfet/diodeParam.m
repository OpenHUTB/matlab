classdef diodeParam<int32



    enumeration
        no(0)
        exponential(1)
        tabulated(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('no')='physmod:ee:library:comments:enum:mosfet:diodeParam:map_No';
            map('exponential')='physmod:ee:library:comments:enum:mosfet:diodeParam:map_Exponential';
            map('tabulated')='physmod:ee:library:comments:enum:mosfet:diodeParam:map_TabulatedIVCurve';
        end
    end
end