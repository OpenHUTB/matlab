classdef(Abstract)FigureObjectDataFormatter<handle
    properties(Access=protected)
FigureData
    end

    properties(Access=protected,Transient=true)
DataListeners
    end

    events
SimStatusUpdated
AllDataUpdated
    end

    methods




        function obj=FigureObjectDataFormatter(figureData)
            obj.FigureData=figureData;
            obj.setupDataListeners();
        end

        function simStatusChanged(obj,eventData)
            evtData=simmanager.designview.EventData([eventData.Data]);
            notify(obj,'SimStatusUpdated',evtData);
        end

        function dataStoreChanged(obj,eventData)
            evtData=simmanager.designview.EventData([eventData.Data]);
            notify(obj,'AllDataUpdated',evtData);
        end

        function delete(obj)
            delete(obj.DataListeners);
        end
    end

    methods(Access=private)
        function setupDataListeners(obj)
            obj.DataListeners=addlistener(obj.FigureData,"SimStatusUpdated",...
            @(~,evtData)obj.simStatusChanged(evtData));

            obj.DataListeners(2)=addlistener(obj.FigureData,"FigureDataUpdated",...
            @(~,evtData)obj.dataStoreChanged(evtData));
        end
    end
end