classdef pressure_loss_spec<int32





    enumeration
        constant(1)
        tube_correlation(2)
        table1D_Darcy_Re(3)
        table1D_Eu_Re(4)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('constant')='Constant loss coefficient';
            map('tube_correlation')='Correlations for tubes';
            map('table1D_Darcy_Re')='Tabulated data - Darcy friction factor vs. Reynolds number';
            map('table1D_Eu_Re')='Tabulated data - Euler number vs. Reynolds number';
        end
    end
end