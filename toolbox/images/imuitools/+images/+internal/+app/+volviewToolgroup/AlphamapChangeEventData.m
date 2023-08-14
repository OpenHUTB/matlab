

classdef(ConstructOnLoad)AlphamapChangeEventData<event.EventData
    properties
Alphamap
AlphaControlPoints
    end

    methods
        function data=AlphamapChangeEventData(alphamapNew,alphaCP)
            data.Alphamap=alphamapNew;
            data.AlphaControlPoints=alphaCP;
        end
    end
end