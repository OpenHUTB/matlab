classdef HeatCoeffSpec<int32




    enumeration
        Colburn(1)
        GnielinskiCavalliniZecchin(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Colburn')='Colburn equation';
            map('GnielinskiCavalliniZecchin')='Correlation for flow inside tubes';
        end
    end
end
