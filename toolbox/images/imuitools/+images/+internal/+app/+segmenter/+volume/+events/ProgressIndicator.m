classdef ProgressIndicator<handle




    events
ProgressUpdated
    end

    methods
        function send(self,data)
            notify(self,'ProgressUpdated',images.internal.app.segmenter.volume.events.AutomationProgressEventData(data));
        end
    end
end

