classdef ModeDataTipController<matlab.graphics.shape.internal.DataTipController







    methods
        function data=install(~,tip)

            data=[event.listener(tip,'TipHit',@hitCallback),...
            event.listener(tip,'LocatorHit',@hitCallback)];
        end

        function uninstall(~,~,data)

            delete(data);
        end
    end

    methods(Static)
        function hObj=getInstance()
            persistent theInstance
            if isempty(theInstance)||~isvalid(theInstance)
                theInstance=matlab.graphics.shape.internal.ModeDataTipController;
            end

            hObj=theInstance;
        end
    end
end


function hitCallback(hTip,evd)
    dcm=localGetMode(hTip);
    if~isempty(dcm)

        dcm.CurrentCursor=hTip.Cursor;

        if evd.isContextMenuEvent()&&isempty(hTip.UIContextMenu)

            hMenu=dcm.UIContextMenu;
            matlab.graphics.shape.internal.DataTipController.showContextMenu(hMenu);
        end
    end
end


function dcm=localGetMode(hTip)
    hFig=ancestor(hTip,'figure');
    if~isempty(hFig)
        dcm=datacursormode(hFig);
    else
        dcm=[];
    end
end
