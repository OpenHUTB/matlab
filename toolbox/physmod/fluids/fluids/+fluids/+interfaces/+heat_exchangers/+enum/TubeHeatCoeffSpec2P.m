classdef TubeHeatCoeffSpec2P<int32





    enumeration
        Colburn(1)
        GneilinskiCavalliniZecchin(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Colburn')='Colburn equation';
            map('GneilinskiCavalliniZecchin')='Correlation for flow inside tubes';
        end
    end
end