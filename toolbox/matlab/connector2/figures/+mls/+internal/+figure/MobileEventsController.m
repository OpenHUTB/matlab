
classdef MobileEventsController
    methods(Static,Hidden)
        function reset
            import mls.internal.figure.MobileEventsController
            builtin('_StructuredFiguresResetAll');
            eventsCollector=MobileEventsController.getEventsCollector();
            eventsCollector.clear();
        end

        function events=getEvents
            import mls.internal.figure.MobileEventsController
            eventsCollector=MobileEventsController.getEventsCollector();
            events=eventsCollector.Events;
        end
    end

    methods(Static,Access=private)
        function eventsCollector=getEventsCollector
            mlock;
            persistent mobileEventsCollector;
            if isempty(mobileEventsCollector)
                mobileEventsCollector=matlab.internal.language.EventsCollector;
                mobileEventsCollector.setCheckRelevant(false);
            end
            eventsCollector=mobileEventsCollector;
        end
    end
end
