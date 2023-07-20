classdef area_change_loss_spec<int32




    enumeration
        empirical(1)
        table1D_Re(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('empirical')='Semi-empirical correlation';
            map('table1D_Re')='Tabulated data - loss coefficient vs. Reynolds number';
        end
    end
end