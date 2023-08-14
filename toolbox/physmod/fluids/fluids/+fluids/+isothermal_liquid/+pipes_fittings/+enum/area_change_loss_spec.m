classdef area_change_loss_spec<int32




    enumeration
        empirical_sudden(1)
        empirical_gradual(2)
        table1D_Re(3)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('empirical_sudden')='Semi-empirical correlation - sudden area change';
            map('empirical_gradual')='Semi-empirical correlation - gradual area change';
            map('table1D_Re')='Tabulated data - loss coefficient vs. Reynolds number';
        end
    end
end