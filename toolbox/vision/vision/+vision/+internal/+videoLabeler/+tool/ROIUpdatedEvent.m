classdef ROIUpdatedEvent<event.EventData
    properties
ROIData
    end

    methods
        function this=ROIUpdatedEvent(data)








            this.ROIData=repmat(struct(),length(data),1);
            for idx=1:length(data)
                this.ROIData(idx).Name=data(idx).Label;
                this.ROIData(idx).Type=data(idx).Shape;
                this.ROIData(idx).Position=data(idx).Position;
                this.ROIData(idx).UID=data(idx).ID;
            end
        end
    end
end