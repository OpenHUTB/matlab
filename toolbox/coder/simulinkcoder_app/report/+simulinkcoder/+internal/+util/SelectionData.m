classdef SelectionData<event.EventData
    properties
Document
SelectedElements
    end

    methods
        function data=SelectionData(Document,elements)
            data.Document=Document;
            data.SelectedElements=elements;
        end
    end
end