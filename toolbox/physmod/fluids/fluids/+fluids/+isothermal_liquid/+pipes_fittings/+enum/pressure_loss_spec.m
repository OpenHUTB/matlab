classdef pressure_loss_spec<int32




    enumeration
        nominal(1)
        haaland(2)
        table1D_Darcy_Re(3)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('nominal')='Nominal pressure drop vs. nominal mass flow rate';
            map('haaland')='Haaland correlation';
            map('table1D_Darcy_Re')='Tabulated data - Darcy friction factor vs. Reynolds number';
        end
    end
end