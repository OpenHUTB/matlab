function setOrigLimits(ax,limits)




    setappdata(ax,'zoom_zoomOrigAxesLimits',limits);



    l=addlistener(ax,'Reset',@localNoOp);
    l.Callback=@(o,~)localDeleteZoomAppdata(o,l);

    function localNoOp

        function localDeleteZoomAppdata(ax,l)
            if isappdata(ax,'zoom_zoomOrigAxesLimits')
                rmappdata(ax,'zoom_zoomOrigAxesLimits');
            end

            if isvalid(l)
                delete(l);
            end