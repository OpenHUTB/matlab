classdef OutputEventPreprocessor<handle

    properties(Access=private)
EventCollector
PreviousEvent
    end

    methods
        function obj=OutputEventPreprocessor(eventCollector)
            obj.EventCollector=eventCollector;
        end

        function outputEvents=flushEvents(obj,editorId)
            import matlab.internal.editor.OutputEventPreprocessor;

            builtin('_setTextOutputListeners','flush');
            events=obj.EventCollector.Events;
            obj.EventCollector.clear();

            if isempty(events)
                outputEvents=[];
                return;
            end



            estimatedNumberOfOutputs=numel(events);
            currentIndex=1;

            outputEvents=struct('type',cell(1,estimatedNumberOfOutputs),...
            'payload',cell(1,estimatedNumberOfOutputs),...
            'stack',cell(1,estimatedNumberOfOutputs));

            for i=1:numel(events)
                event=events(i);

                nextPreviousEvent=event;
                event=OutputEventPreprocessor.process(event,editorId,obj.PreviousEvent);
                obj.PreviousEvent=nextPreviousEvent;

                if~isempty(event)
                    outputEvents(currentIndex)=event;
                    currentIndex=currentIndex+1;
                end
            end


            outputEvents=outputEvents(1:currentIndex-1);
        end

        function clearEvents(obj)
            obj.EventCollector.clear();
        end

        function delete(obj)
            obj.EventCollector=[];
        end
    end

    methods(Access=private,Static)
        function outputEvent=process(event,editorId,previousEvent)
            import matlab.internal.editor.FigureManager;

            switch event.type
            case 'figure'
                outputEvent=FigureManager.preprocessEvent(editorId,event,previousEvent);
            otherwise
                outputEvent=event;
            end
        end
    end
end

