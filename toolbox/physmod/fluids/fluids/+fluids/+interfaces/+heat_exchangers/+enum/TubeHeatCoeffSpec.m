classdef TubeHeatCoeffSpec<int32





    enumeration
        Colburn(1)
        Gneilinski(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Colburn')='Colburn equation';
            map('Gneilinski')='Correlation for flow inside tubes';
        end
    end
end