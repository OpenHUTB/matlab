classdef TurbineParameterization<int32





    enumeration
        Analytical(1)
        Tabulated1D(2)
        Tabulated2D(3)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Analytical')='Analytical - nominal pressure ratio and corrected mass flow rate';
            map('Tabulated1D')='Tabulated data - flow rate and efficiency vs. pressure ratio';
            map('Tabulated2D')='Tabulated data - flow rate and efficiency vs. corrected speed and pressure ratio';
        end
    end
end