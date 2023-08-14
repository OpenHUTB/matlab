classdef frequency<int32



    enumeration
        variable(1)
        constant(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('variable')='physmod:ee:library:comments:enum:converters:frequency:Variable';
            map('constant')='physmod:ee:library:comments:enum:converters:frequency:Constant';
        end
    end
end
