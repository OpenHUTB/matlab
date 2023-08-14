classdef PressureLossSpec<int32




    enumeration
        Nominal(3)
        Haaland(1)
        Tabulated(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Nominal')='Nominal pressure drop vs. nominal mass flow rate';
            map('Haaland')='Haaland correlation';
            map('Tabulated')='Tabulated data - Darcy friction factor vs. Reynolds number';
        end
    end
end