classdef RPMTracker<handle

    properties

Model
View
Controller
    end

    properties


        IsExportButtonPushed=false
EstimatedRPMToWS
OutputTimeVectorToWS
    end

    methods
        function this=RPMTracker(Sx,Fx,Tx,Px,rpm,tout,opts)

            this.View=signal.internal.rpmtrack.RPMTrackerView(Fx,Tx,Px,rpm,tout,opts);

            this.Model=signal.internal.rpmtrack.RPMTrackerModel(Sx,Fx,Tx,Px,rpm,tout,opts);

            this.Controller=signal.internal.rpmtrack.RPMTrackerController(this,opts);

            this.View.Controller=this.Controller;



            addlistener(this.View,'AppClosed',@(src,evt)closeCallback(this));
        end

        function closeCallback(this)
            delete(this);
        end
    end
end