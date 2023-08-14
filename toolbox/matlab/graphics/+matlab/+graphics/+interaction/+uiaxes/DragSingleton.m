classdef(Sealed)DragSingleton<handle


    properties
        MidDrag=false;
    end

    methods(Access=private)
        function newObj=DragSingleton()
        end
    end

    methods(Static)
        function singleObj=getInstance()
            persistent localObj
            if isempty(localObj)||~isvalid(localObj)
                localObj=matlab.graphics.interaction.uiaxes.DragSingleton();
            end
            singleObj=localObj;
        end
    end

    events
DragComplete
    end
end