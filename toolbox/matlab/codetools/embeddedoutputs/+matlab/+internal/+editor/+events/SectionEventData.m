classdef SectionEventData<event.EventData




    properties
SectionNumber
    end

    methods
        function data=SectionEventData(sectionNumber)
            data.SectionNumber=sectionNumber;
        end
    end
end