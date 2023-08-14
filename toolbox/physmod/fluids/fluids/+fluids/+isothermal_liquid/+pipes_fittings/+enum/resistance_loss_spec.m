classdef resistance_loss_spec<int32




    enumeration
        constant(1)
        table1D_Re(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('constant')='Constant';
            map('table1D_Re')='Tabulated data - loss coefficient vs. Reynolds number';
        end
    end
end