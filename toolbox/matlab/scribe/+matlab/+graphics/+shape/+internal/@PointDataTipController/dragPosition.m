function dragPosition(hTip)








    hFig=ancestor(hTip,'figure');

    if~isempty(hFig)
        LastHandledPosition=hgconvertunits(hFig,[hFig.CurrentPoint,0,0],get(hFig,'units'),'pixels',hFig);
        MouseDownPosition=LastHandledPosition;


        hTip.Listeners.hMotionListener=event.listener(hFig,'WindowMouseMotion',@localMarkerMotion);
        hTip.Listeners.hUpListener=event.listener(hFig,'WindowMouseRelease',@localMarkerUp);
    end

    function localMarkerMotion(~,evd)

        LastHandledPosition=moveTip(hTip,evd.Point,hFig,LastHandledPosition);
    end

    function localMarkerUp(~,evd)

        delete(hTip.Listeners.hMotionListener);
        delete(hTip.Listeners.hUpListener);

        LastHandledPosition=moveTip(hTip,evd.Point,hFig,LastHandledPosition);


        if strcmp(hTip.PinnableStyle,'Pinnable')&&...
            isequal(MouseDownPosition,LastHandledPosition)
            matlab.graphics.shape.internal.PointDataTipController.togglePinning(hTip);
        else
            evd=matlab.graphics.shape.internal.DataTipValueChangedEvent(MouseDownPosition,LastHandledPosition);
            hTip.notify('ValueChanged',evd);
        end
    end
end


function LastHandledPosition=moveTip(hTip,Point,hFig,LastHandledPosition)


    if isvalid(hTip)&&~isempty(hTip.Cursor)
        figPoint=hgconvertunits(hFig,[Point,0,0],get(hFig,'units'),'pixels',hFig);
        if~isequal(figPoint,LastHandledPosition)
            if~matlab.ui.internal.isUIFigure(hFig)
                hTip.Cursor.moveTo(figPoint(1:2));
            end
            LastHandledPosition=figPoint;
        end
    end
end
