classdef heat_transfer_spec<int32





    enumeration
        constant(1)
        tube_correlation(2)
        table1D_Colburn_Re(3)
        table2D_Nu_Re_Pr(4)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('constant')='Constant heat transfer coefficient';
            map('tube_correlation')='Correlation for tubes';
            map('table1D_Colburn_Re')='Tabulated data - Colburn factor vs. Reynolds number';
            map('table2D_Nu_Re_Pr')='Tabulated data - Nusselt number vs. Reynolds number & Prandtl number';
        end
    end
end