classdef capacitanceParam<int32



    enumeration
        fixedciss(1)
        fixedcge(2)
        tabulatedciss(3)
        tabluatedcge(4)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('fixedciss')='physmod:ee:library:comments:enum:igbt:capacitanceParam:map_SpecifyFixedInputReverseTransferAndOutputCapacitance';
            map('fixedcge')='physmod:ee:library:comments:enum:igbt:capacitanceParam:map_SpecifyFixedGateEmitterGateCollectorAndCollectorEmitterCa';
            map('tabulatedciss')='physmod:ee:library:comments:enum:igbt:capacitanceParam:map_SpecifyTabulatedInputReverseTransferAndOutputCapacitance';
            map('tabluatedcge')='physmod:ee:library:comments:enum:igbt:capacitanceParam:map_SpecifyTabulatedGateEmitterGateCollectorAndCollectorEmitt';
        end
    end
end