classdef repeatability<int32




    enumeration
        NotRepeatable(1)
        Repeatable(2)
        SpecifySeed(3)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('NotRepeatable')='physmod:ee:library:comments:sources:repeatability:NotRepeatable';
            map('Repeatable')='physmod:ee:library:comments:sources:repeatability:Repeatable';
            map('SpecifySeed')='physmod:ee:library:comments:sources:repeatability:SpecifySeed';
        end
    end
end