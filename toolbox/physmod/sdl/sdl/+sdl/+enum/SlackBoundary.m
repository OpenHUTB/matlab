classdef SlackBoundary<int32




    enumeration
        smooth(1)
        fullundamped(2)
        fulldamped(3)
    end
    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('smooth')='physmod:sdl:library:enum:SlackBoundarySmoothDampedRebound';
            map('fullundamped')='physmod:sdl:library:enum:SlackBoundaryFullUndampedRebound';
            map('fulldamped')='physmod:sdl:library:enum:SlackBoundaryFullDampedRebound';
        end
    end
end
