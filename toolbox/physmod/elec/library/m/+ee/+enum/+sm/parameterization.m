classdef parameterization<int32



    enumeration
        fundamental(1)
        standard(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('fundamental')='physmod:ee:library:comments:enum:sm:parameterization:map_FundamentalParameters';
            map('standard')='physmod:ee:library:comments:enum:sm:parameterization:map_StandardParameters';
        end
    end
end

