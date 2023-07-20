classdef PointDataTipController<matlab.graphics.shape.internal.DataTipController







    methods
        function data=install(~,tip)



            data=[event.listener(tip,'TipHit',@tipHitCallback),...
            event.listener(tip,'LocatorHit',@locatorHitCallback)];
        end

        function uninstall(~,~,data)

            delete(data);
        end
    end

    methods(Static)
        function hObj=getInstance()
            persistent theInstance
            if isempty(theInstance)||~isvalid(theInstance)
                theInstance=matlab.graphics.shape.internal.PointDataTipController;
            end

            hObj=theInstance;
        end

        dragOrientation(hTip);
        dragPosition(hTip);
        togglePinning(hTip);
        editLabel(hTip);

        function localTextMotion(~,evd,hGraphicsTip)
            hFig=evd.Source;

            if~matlab.ui.internal.isUIFigure(hFig)
                matlab.graphics.interaction.internal.setPointer(hFig,'fleur');
            end



            eventPos=evd.Point;


            eventPos=hgconvertunits(hFig,[eventPos,0,0],get(hFig,'units'),'pixels',hFig);

            eventPos=brushing.select.translateToContainer(hGraphicsTip,eventPos(1:2));


            markerPos=matlab.graphics.chart.internal.convertDataSpaceCoordsToViewerCoords(hGraphicsTip,hGraphicsTip.Position.');


            xm=markerPos(1);
            ym=markerPos(2);
            xd=eventPos(1);
            yd=eventPos(2);
            if xm>=xd&&ym>=yd
                new_Orientation='bottomleft';
            elseif xm>=xd&&ym<yd
                new_Orientation='topleft';
            elseif xm<xd&&ym>=yd
                new_Orientation='bottomright';
            else
                new_Orientation='topright';
            end
            if~strcmp(new_Orientation,hGraphicsTip.Orientation)
                hGraphicsTip.Orientation=new_Orientation;
            end
        end
    end
end

function tipHitCallback(hTip,evd)

    if matlab.graphics.shape.internal.DataTipController.isTipInteractionEnabled(hTip)
        hFig=ancestor(hTip,'figure');
        isPlotEditModeActive=~isempty(hFig)&&isactiveuimode(hFig,'Standard.EditPlot');
        if evd.isContextMenuEvent()

            matlab.graphics.shape.internal.DataTipController.showContextMenu(hTip.UIContextMenu);
        elseif evd.Button==1&&evd.isTipEditEvent(hTip)

            matlab.graphics.shape.internal.PointDataTipController.editLabel(hTip);
        end
        if~isPlotEditModeActive&&evd.Button==1


            matlab.graphics.shape.internal.PointDataTipController.dragOrientation(hTip);
        end
        matlab.graphics.shape.internal.DataTipController.setCurrentCursor(hTip);
    end
end

function locatorHitCallback(hTip,evd)

    if matlab.graphics.shape.internal.DataTipController.isTipInteractionEnabled(hTip)
        HasButtonDownFcn=~isempty(hTip.ButtonDownFcn);
        hFig=ancestor(hTip,'figure');
        isPlotEditModeActive=~isempty(hFig)&&isactiveuimode(hFig,'Standard.EditPlot');
        if~isPlotEditModeActive
            if HasButtonDownFcn


                hgfeval(hTip.ButtonDownFcn,hTip,evd);
            elseif evd.Button==1&&strcmp(hTip.Draggable,'on')











                matlab.graphics.shape.internal.PointDataTipController.dragPosition(hTip);
            end
        end

        if evd.isContextMenuEvent()

            matlab.graphics.shape.internal.DataTipController.showContextMenu(hTip.UIContextMenu);
        end
        matlab.graphics.shape.internal.DataTipController.setCurrentCursor(hTip);
    end
end