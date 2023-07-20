function doUpdate(hObj,~)









    if strcmp(hObj.CurrentTip,'on')&&strcmp(hObj.Visible,'on')




        hFP=hObj.FigurePanelInterface;
        if isempty(hFP)

            hFP=localGetFigurePanel(hObj);
            hObj.FigurePanelInterface=hFP;

        elseif~hFP.isValid(hObj)

            hFP.removeData(hObj);


            hFP=localGetFigurePanel(hObj);
            hObj.FigurePanelInterface=hFP;
        end

        if~isempty(hFP)

            hFP.setData(hObj,hObj.String,hObj.TargetType);


            if~isempty(hObj.GraphicsTipHandle)
                delete(hObj.GraphicsTipHandle);
                hObj.GraphicsTipHandle=matlab.graphics.shape.internal.GraphicsTip.empty;
            end

        else

            localUseGraphicsTip(hObj);
        end

    else

        hFP=hObj.FigurePanelInterface;
        if~isempty(hFP)&&hFP.isValid()
            hFP.removeData(hObj);
        else

            localUseGraphicsTip(hObj);
        end
    end


    function localUseGraphicsTip(hObj)


        tip=hObj.GraphicsTipHandle;
        if isempty(tip)
            tip=matlab.graphics.shape.internal.GraphicsTip();
            hObj.addNode(tip);
            hObj.GraphicsTipHandle=tip;
        end


        tip.Position=hObj.Position;
        tip.String=hObj.String;
        tip.TargetType=hObj.TargetType;
        tip.Visible=hObj.Visible;


        function hFP=localGetFigurePanel(hObj)
            hFP=[];
            hFig=ancestor(hObj,'figure');
            if~isempty(hFig)
                hFP=matlab.graphics.shape.internal.DataCursorManager.getModePanelInterface(hFig);
            end
