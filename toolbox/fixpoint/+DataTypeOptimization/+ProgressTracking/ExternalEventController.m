classdef(Sealed)ExternalEventController<handle



    properties(SetAccess=protected)
EventCatalog
    end

    methods(Access=private)

        function this=ExternalEventController()
        end
    end

    methods(Static)

        function singleObject=getEventController()
            persistent localObject;


            if isempty(localObject)||~isvalid(localObject)
                localObject=DataTypeOptimization.ProgressTracking.ExternalEventController;
                localObject.initialize();
            end


            singleObject=localObject;
        end

    end

    methods(Access=public)
        function eventStrategy=requestEvent(this,ID)
            if this.EventCatalog.isKey(ID)
                eventStrategy=this.EventCatalog(ID);
            else
                eventStrategy=DataTypeOptimization.ProgressTracking.ExternalEventStrategy(ID);
                this.EventCatalog(ID)=eventStrategy;
            end

        end

        function toggleEvent(this,ID)
            eventStrategy=this.requestEvent(ID);
            eventStrategy.toggleEvent();

        end

        function delete(this)
            this.clearMaps();

        end
    end

    methods(Hidden)
        function initialize(this)
            this.EventCatalog=containers.Map();

        end

        function clearMaps(this)
            this.initialize();

        end
    end
end