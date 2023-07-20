classdef MechOrientationTranslational<int32





    enumeration
        Positive(1)
        Negative(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Positive')='physmod:simscape:library:enum:MechOrientationTranslationalPositive';
            map('Negative')='physmod:simscape:library:enum:MechOrientationTranslationalNegative';
        end
    end
end