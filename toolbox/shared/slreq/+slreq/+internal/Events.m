classdef Events<handle


    events
LinkSetDirtied
LinkSetUnDirtied
LinkSetDiscarded
LinkSetCreated
LinkSetLoaded
    end

    methods(Access=private)
        function this=Events
        end

    end

    methods(Static)
        function this=getInstance()
            persistent eventObj
            if isempty(eventObj)||~isvalid(eventObj)
                eventObj=slreq.internal.Events;
            end
            this=eventObj;
        end
    end

end
