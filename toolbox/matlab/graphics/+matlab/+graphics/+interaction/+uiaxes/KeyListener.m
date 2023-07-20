classdef KeyListener<handle


    properties
key
    end

    properties(Access=private)
keypress_listener
keyrelease_listener
    end

    properties(SetAccess=private)
        iskeypressed=false;
source
    end

    methods
        function hObj=KeyListener(fig,key)
            hObj.source=fig;
            hObj.key=key;
        end

        function enable(hObj)
            hObj.keypress_listener=event.listener(hObj.source,'WindowKeyPress',@(o,e)hObj.keypresscallback(o,e));
            hObj.keyrelease_listener=event.listener(hObj.source,'WindowKeyRelease',@(o,e)hObj.keyreleasecallback(o,e));
        end

        function hObj=disable(hObj)
            delete(hObj.keypress_listener);
            delete(hObj.keyrelease_listener);
        end

        function delete(hObj)
            hObj.disable();
        end
    end

    methods(Access=private)
        function keypresscallback(hObj,~,e)
            if strcmp(e.Key,hObj.key)
                hObj.iskeypressed=true;
            end
        end

        function keyreleasecallback(hObj,~,e)
            if strcmp(e.Key,hObj.key)
                hObj.iskeypressed=false;
            end
        end
    end
end