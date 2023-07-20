classdef(Sealed)FakePin<matlab.graphics.primitive.world.Group






    methods(Access=public)
        function hObj=FakePin(varargin)

        end

    end

    methods(Access=public,Static=true)
        function hObj=doloadobj(hObj)

            delete(hObj);
            hObj=matlab.graphics.primitive.world.Group.empty;
        end
    end
end
