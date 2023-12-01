classdef(Abstract)ScatterPlotOverlayLayer<simmanager.designview.internal.ScatterPlotLayer
    properties(Access=protected)
RunIdMap
    end

    methods
        function obj=ScatterPlotOverlayLayer(fullXData,fullYData,runIds,figureAxes,scatterObject)
            if~isempty(runIds)
                mapLocs=1:numel(runIds);
                obj.RunIdMap=containers.Map(runIds,mapLocs);
            else
                obj.RunIdMap=containers.Map('KeyType','double','ValueType','any');
            end

            [xData,yData]=createFormattedData(fullXData,fullYData,runIds);


            hold(figureAxes,'on');

            if isempty(scatterObject)
                obj.ScatterObject=scatter(figureAxes,xData,yData,36,'filled','UserData',runIds);
            else
                obj.ScatterObject=scatterObject;
            end
            addlistener(obj.ScatterObject,'Hit',@obj.scatterClick);
        end



        function updateXData(obj,data,runId)
            if isKey(obj.RunIdMap,runId)
                curLoc=obj.RunIdMap(runId);
                obj.ScatterObject.XData(curLoc)=data;
            end
        end



        function updateYData(obj,data,runId)
            if isKey(obj.RunIdMap,runId)
                curLoc=obj.RunIdMap(runId);
                obj.ScatterObject.YData(curLoc)=data;
            end
        end



        function updateScatterData(obj,xData,yData,runId)
            obj.updateXData(xData,runId);
            obj.updateYData(yData,runId);
        end


        function replaceXData(obj,data)
            obj.removeOutOfRangeUserData(numel(data));
            newXData=data(obj.ScatterObject.UserData);
            obj.ScatterObject.XData=newXData;
        end


        function replaceYData(obj,data)
            obj.removeOutOfRangeUserData(numel(data));
            newYData=data(obj.ScatterObject.UserData);
            obj.ScatterObject.YData=newYData;
        end



        function removeScatterPoint(obj,runId)
            if~isKey(obj.RunIdMap,runId)
                return
            end

            index=obj.RunIdMap(runId);
            obj.ScatterObject.XData(index)=[];
            obj.ScatterObject.YData(index)=[];
            obj.ScatterObject.UserData(index)=[];

            remove(obj.RunIdMap,runId);
            runIds=obj.ScatterObject.UserData;
            for idIndex=index:numel(runIds)
                curId=runIds(idIndex);
                curLoc=obj.RunIdMap(curId);
                obj.RunIdMap(curId)=curLoc-1;
            end
        end



        function clearScatter(obj)
            obj.ScatterObject.XData=[];
            obj.ScatterObject.YData=[];
            obj.ScatterObject.UserData=[];
            obj.RunIdMap=containers.Map('KeyType','double','ValueType','any');
        end



        function addScatterPoint(obj,newX,newY,runId)

            if isKey(obj.RunIdMap,runId)
                curLoc=obj.RunIdMap(runId);
                obj.ScatterObject.XData(curLoc)=newX;
                obj.ScatterObject.YData(curLoc)=newY;
                return;
            end

            obj.ScatterObject.XData(end+1)=newX;
            obj.ScatterObject.YData(end+1)=newY;
            obj.ScatterObject.UserData(end+1)=runId;
            valLoc=numel(obj.ScatterObject.UserData);
            obj.RunIdMap(runId)=valLoc;
        end
    end

    methods(Access=private)
        function removeOutOfRangeUserData(obj,maxRange)
            validUserData=(obj.ScatterObject.UserData<=maxRange);
            obj.ScatterObject.UserData=obj.ScatterObject.UserData(validUserData);
        end
    end
end



function[xData,yData]=createFormattedData(mainXData,mainYData,runIds)
    xData=mainXData(runIds);
    yData=mainYData(runIds);
end
