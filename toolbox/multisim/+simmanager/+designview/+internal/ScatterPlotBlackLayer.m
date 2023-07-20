










classdef ScatterPlotBlackLayer<simmanager.designview.internal.ScatterPlotOverlayLayer

    events
RunSelected
    end

    methods
        function obj=ScatterPlotBlackLayer(fullXData,fullYData,runIds,figure,scatterObject)
            obj@simmanager.designview.internal.ScatterPlotOverlayLayer(...
            fullXData,fullYData,runIds,figure,scatterObject);
            obj.ScatterObject.CData=[0.85,0.85,0.85];
        end





        function replaceScatterData(obj,fullXData,fullYData,runIds)
            [xData,yData]=createFormattedData(fullXData,fullYData,runIds);

            if~isempty(runIds)
                mapLocs=1:numel(runIds);
                obj.RunIdMap=containers.Map(runIds,mapLocs);
            else
                obj.RunIdMap=containers.Map('KeyType','double','ValueType','any');
            end

            obj.ScatterObject.XData=xData;
            obj.ScatterObject.YData=yData;
            obj.ScatterObject.UserData=runIds;
        end
    end

    methods(Access=protected)

        function scatterClick(obj,scatterPlot,evt)
            xVals=scatterPlot.XData;
            yVals=scatterPlot.YData;
            [~,index]=min((evt.IntersectionPoint(1)-xVals).^2+(evt.IntersectionPoint(2)-yVals).^2);
            runId=scatterPlot.UserData(index);

            obj.scatterInteract(xVals(index),yVals(index),runId,evt);
        end
    end

    methods(Access=private)




        function scatterInteract(obj,xVal,yVal,runId,evt)
            if evt.Button==0
                evtData=simmanager.designview.EventData(...
                struct('XVal',xVal,'YVal',yVal,'RunId',runId));
                notify(obj,'DatatipRequest',evtData);
            else
                evtData=simmanager.designview.EventData(runId);
                notify(obj,'RunSelected',evtData);
            end
        end
    end
end



function[xData,yData]=createFormattedData(mainXData,mainYData,runIds)
    xData=mainXData(runIds);
    yData=mainYData(runIds);
end
