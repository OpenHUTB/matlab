classdef(ConstructOnLoad)PlotEventData<event.EventData



    properties
wavProperties
compProperties
graphtype
Index
    end

    methods
        function data=PlotEventData(wavproperties,compproperties,graphtype,index)
            data.wavProperties=wavproperties;
            data.compProperties=compproperties;
            data.graphtype=graphtype;
            data.Index=index;
        end
    end
end
