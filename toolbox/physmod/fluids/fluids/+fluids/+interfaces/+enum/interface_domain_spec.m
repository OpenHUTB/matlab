classdef interface_domain_spec<int32





    enumeration
        TL_IL(1)
        TL_H(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('TL_IL')='Thermal Liquid (TL) - Isothermal Liquid (IL)';
            map('TL_H')='Thermal Liquid (TL) - Hydraulic (H)';
        end
    end
end