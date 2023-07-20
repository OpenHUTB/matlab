classdef ScenarioViewModel<handle
    properties(Dependent)
EnableGround
EnableTrajectories
EnableWaypoints
EnableCoverage
EnableDetections
EnableIndicator
    end

    properties(SetAccess=private,Hidden)
        pEnableGround logical=true
        pEnableTrajectories logical=true
        pEnableWaypoints logical=true
        pEnableCoverage logical=true
        pEnableDetections logical=false
        pEnableIndicator logical=true
    end

    events
ViewOptionsChanged
ViewIndicatorChanged
    end

    methods
        function value=get.EnableGround(this)
            value=this.pEnableGround;
        end

        function set.EnableGround(this,value)
            this.pEnableGround=value;
            notify(this,'ViewOptionsChanged');
        end

        function value=get.EnableTrajectories(this)
            value=this.pEnableTrajectories;
        end

        function set.EnableTrajectories(this,value)
            this.pEnableTrajectories=value;
            notify(this,'ViewOptionsChanged');
        end

        function value=get.EnableWaypoints(this)
            value=this.pEnableWaypoints;
        end

        function set.EnableWaypoints(this,value)
            this.pEnableWaypoints=value;
            notify(this,'ViewOptionsChanged');
        end

        function disableWaypoints(this)
            this.pEnableWaypoints=false;
        end

        function enableWaypoints(this)
            this.pEnableWaypoints=true;
        end

        function value=get.EnableCoverage(this)
            value=this.pEnableCoverage;
        end

        function set.EnableCoverage(this,value)
            this.pEnableCoverage=value;
            notify(this,'ViewOptionsChanged');
        end

        function value=get.EnableDetections(this)
            value=this.pEnableDetections;
        end

        function set.EnableDetections(this,value)
            this.pEnableDetections=value;
            notify(this,'ViewOptionsChanged');
        end

        function value=get.EnableIndicator(this)
            value=this.pEnableIndicator;
        end

        function set.EnableIndicator(this,value)
            this.pEnableIndicator=value;
            notify(this,'ViewIndicatorChanged');
        end
    end

end

