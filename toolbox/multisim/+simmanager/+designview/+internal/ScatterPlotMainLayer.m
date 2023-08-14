





classdef ScatterPlotMainLayer<simmanager.designview.internal.ScatterPlotLayer
    events
RunSelected
    end

    methods


        function obj=ScatterPlotMainLayer(xData,yData,cData,figureAxes,scatterObject)
            hold(figureAxes,'on');

            if isempty(scatterObject)
                obj.ScatterObject=scatter(figureAxes,xData,yData,obj.SizeData,cData,'filled');
            else
                obj.ScatterObject=scatterObject;
            end
            addlistener(obj.ScatterObject,'Hit',@obj.scatterClick);
        end



        function updateXData(obj,data,runId)
            obj.ScatterObject.XData(runId)=data;
        end



        function updateYData(obj,data,runId)
            obj.ScatterObject.YData(runId)=data;
        end



        function updateCData(obj,data,runId)
            obj.ScatterObject.CData(runId,:)=data;
        end



        function updateScatterData(obj,xData,yData,cData,runId)
            obj.updateXData(xData,runId);
            obj.updateYData(yData,runId);
            obj.updateCData(cData,runId);
        end


        function replaceXData(obj,data)
            obj.ScatterObject.XData=data;
        end


        function replaceYData(obj,data)
            obj.ScatterObject.YData=data;
        end


        function replaceCData(obj,data)
            obj.ScatterObject.CData=data;
            obj.updateDatatipRows();
        end



        function replaceScatterData(obj,xData,yData,cData)
            obj.ScatterObject.XData=xData;
            obj.ScatterObject.YData=yData;
            obj.ScatterObject.CData=cData;
        end
    end

    methods(Hidden)

        function testClick(obj,source,data)
            obj.scatterClick(source,data);
        end
    end

    methods(Access=protected)

        function scatterClick(obj,~,evt)
            scatterPlot=obj.ScatterObject;
            if~strcmp(scatterPlot.Parent.InteractionContainer.CurrentMode,'none')
                return;
            end

            xVals=scatterPlot.XData;
            yVals=scatterPlot.YData;
            [~,runId]=min((evt.IntersectionPoint(1)-xVals).^2+...
            (evt.IntersectionPoint(2)-yVals).^2);

            obj.scatterInteract(xVals(runId),yVals(runId),runId,evt);
        end

        function updateDatatipRows(obj)
            scatterObj=obj.ScatterObject;
            if isvector(scatterObj.CData)
                zDataTip=dataTipTextRow('Z','CData');
                scatterObj.DataTipTemplate.DataTipRows(3)=zDataTip;
            else
                scatterObj.DataTipTemplate.DataTipRows=scatterObj.DataTipTemplate.DataTipRows(1:2);
            end
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