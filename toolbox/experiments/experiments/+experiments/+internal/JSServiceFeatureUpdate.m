classdef(Sealed,ConstructOnLoad)JSServiceFeatureUpdate<event.EventData




    properties(SetAccess=immutable)
Update
Previous
    end

    methods
        function self=JSServiceFeatureUpdate(update,previous)
            self.Update=update;
            self.Previous=previous;
        end
    end
end
