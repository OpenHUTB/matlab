function dragOrientation(hTip)








    hFig=ancestor(hTip,'figure');



    if matlab.ui.internal.isUIFigure(hFig)
        return;
    end

    if~isempty(hFig)
        hGraphicsTip=hTip.TipHandle;
        figOrigCursor=hFig.Pointer;
        if isa(hGraphicsTip,'matlab.graphics.shape.internal.GraphicsTip')



            hMotionListener=addlistener(hFig,'WindowMouseMotion',...
            @(e,d)matlab.graphics.shape.internal.PointDataTipController.localTextMotion(e,d,hGraphicsTip));
            hUpListener=addlistener(hFig,'WindowMouseRelease',@localUp);
        end
    end

    function localUp(~,~)

        delete(hMotionListener);
        delete(hUpListener);

        matlab.graphics.interaction.internal.setPointer(hFig,figOrigCursor);
    end
end