classdef pilot_pressure_control_spec<int32





    enumeration
        pX_pA(1)
        pX_patm(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('pX_pA')='Pressure at port X relative to port A';
            map('pX_patm')='Pressure at port X relative to atmospheric pressure';
        end
    end
end