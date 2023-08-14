
classdef(ConstructOnLoad)SliderLineMovedEvent<event.EventData
    properties

        Data;
SliderButtonUpStatus
    end

    methods
        function this=SliderLineMovedEvent(data,sliderButtonUpStatus)
            this.Data=data;
            this.SliderButtonUpStatus=sliderButtonUpStatus;
        end
    end
end