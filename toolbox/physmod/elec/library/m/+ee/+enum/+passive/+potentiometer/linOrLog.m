classdef linOrLog<int32



    enumeration
        lin(1)
        log(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('lin')='physmod:ee:library:comments:enum:passive:potentiometer:linOrLog:Linear';
            map('log')='physmod:ee:library:comments:enum:passive:potentiometer:linOrLog:Logarithmic';
        end
    end
end
