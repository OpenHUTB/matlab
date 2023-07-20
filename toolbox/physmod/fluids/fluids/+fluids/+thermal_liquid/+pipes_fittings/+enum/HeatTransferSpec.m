classdef HeatTransferSpec<int32




    enumeration
        Nominal(5)
        Gnielinski(1)
        DittusBoelter(4)
        TabulatedColburn(2)
        TabulatedNusselt(3)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Nominal')='Nominal temperature differential vs. nominal mass flow rate';
            map('Gnielinski')='Gnielinski correlation';
            map('DittusBoelter')='Dittus-Boelter correlation - Nusselt = a * Re^b * Pr^c';
            map('TabulatedColburn')='Tabulated data - Colburn factor vs. Reynolds number';
            map('TabulatedNusselt')='Tabulated data - Nusselt number vs. Reynolds number & Prandtl number';
        end
    end
end