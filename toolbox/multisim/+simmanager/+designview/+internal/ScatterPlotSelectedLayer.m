classdef ScatterPlotSelectedLayer<simmanager.designview.internal.ScatterPlotOverlayLayer
    events
RunDeselected
    end

    methods
        function obj=ScatterPlotSelectedLayer(fullXData,fullYData,runIds,figureAxes,scatterObject)
            obj@simmanager.designview.internal.ScatterPlotOverlayLayer(...
            fullXData,fullYData,runIds,figureAxes,scatterObject);
            obj.ScatterObject.MarkerFaceAlpha=0;
            obj.ScatterObject.MarkerEdgeColor='b';
            obj.ScatterObject.LineWidth=1.5;
        end





        function replaceScatterData(obj,fullXData,fullYData)
            runIds=cell2mat(keys(obj.RunIdMap));

            [xData,yData]=createFormattedData(fullXData,fullYData,runIds);

            obj.ScatterObject.XData=xData;
            obj.ScatterObject.YData=yData;
            obj.ScatterObject.UserData=runIds;
        end
    end

    methods(Access=protected)




        function scatterClick(obj,scatterPlot,evt)
            xVals=scatterPlot.XData;
            yVals=scatterPlot.YData;
            runIds=scatterPlot.UserData;
            [~,index]=min((evt.IntersectionPoint(1)-xVals).^2+(evt.IntersectionPoint(2)-yVals).^2);
            runId=runIds(index);
            if evt.Button==0
                evtData=simmanager.designview.EventData(...
                struct('XVal',xVals(index),'YVal',yVals(index),'RunId',runId));
                notify(obj,'DatatipRequest',evtData);
            else
                evtData=simmanager.designview.EventData(runId);
                notify(obj,'RunDeselected',evtData);
            end
        end
    end
end



function[xData,yData]=createFormattedData(mainXData,mainYData,runIds)
    xData=mainXData(runIds);
    yData=mainYData(runIds);
end
