classdef capacitanceParam<int32



    enumeration
        fixedciss(1)
        fixedcgs(2)
        tabulatedciss(3)
        tabluatedcgs(4)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('fixedciss')='physmod:ee:library:comments:enum:mosfet:capacitanceParam:map_SpecifyFixedInputReverseTransferAndOutputCapacitance';
            map('fixedcgs')='physmod:ee:library:comments:enum:mosfet:capacitanceParam:map_SpecifyFixedGateSourceGateDrainAndDrainSourceCapacitance';
            map('tabulatedciss')='physmod:ee:library:comments:enum:mosfet:capacitanceParam:map_SpecifyTabulatedInputReverseTransferAndOutputCapacitance';
            map('tabluatedcgs')='physmod:ee:library:comments:enum:mosfet:capacitanceParam:map_SpecifyTabulatedGateSourceGateDrainAndDrainSourceCapacitance';
        end
    end
end