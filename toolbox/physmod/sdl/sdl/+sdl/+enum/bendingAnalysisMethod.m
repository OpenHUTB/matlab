classdef bendingAnalysisMethod<int32

    enumeration
        LumpedMass(1)
        Eigenmodes(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('LumpedMass')='physmod:sdl:library:enum:LumpedMass';
            map('Eigenmodes')='physmod:sdl:library:enum:Eigenmodes';
        end
    end
end



