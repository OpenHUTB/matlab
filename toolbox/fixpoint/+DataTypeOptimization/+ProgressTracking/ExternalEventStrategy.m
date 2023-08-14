classdef ExternalEventStrategy<DataTypeOptimization.ProgressTracking.TrackingStrategy






    properties(SetAccess=private)
eventState
ID
    end

    methods
        function this=ExternalEventStrategy(ID)

            validateattributes(ID,{'char','string'},{'scalartext'})
            this.ID=ID;

            this.eventState=true;
        end

        function initialize(~)

        end

        function reset(this)
            this.eventState=true;
        end

        function diagnostic=check(this)

            diagnostic=MSLDiagnostic.empty();
            if~this.eventState
                diagnostic=MSLDiagnostic(message('SimulinkFixedPoint:dataTypeOptimization:externalEvent'));
            end
        end

        function diagnostic=advance(this)





            matlab.internal.yield();
            diagnostic=this.check();
        end
    end

    methods(Hidden)
        function toggleEvent(this)
            this.eventState=~this.eventState;
        end
    end
end

