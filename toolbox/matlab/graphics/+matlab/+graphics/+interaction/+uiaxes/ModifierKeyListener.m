classdef ModifierKeyListener


    properties(Access=private)
keylist
isuifig
    end

    properties(SetAccess=private)
mod
    end

    methods
        function hObj=ModifierKeyListener(obj,mod)
            fig=ancestor(obj,'Figure');
            hObj.isuifig=matlab.ui.internal.isUIFigure(fig);
            hObj.mod=mod;
            if~hObj.isuifig
                hObj.keylist=matlab.graphics.interaction.uiaxes.KeyListener(fig,mod);
            end
        end

        function enable(hObj)
            if~isempty(hObj.keylist)
                hObj.keylist.enable();
            end
        end

        function disable(hObj)
            if~isempty(hObj.keylist)
                hObj.keylist.disable();
            end
        end

        function ret=iskeypressed(hObj,e)
            ret=[];
            if nargin>1&&hObj.isuifig
                ret=e.(hObj.mod);
            elseif~isempty(hObj.keylist)
                ret=hObj.keylist.iskeypressed;
            end
        end
    end
end

