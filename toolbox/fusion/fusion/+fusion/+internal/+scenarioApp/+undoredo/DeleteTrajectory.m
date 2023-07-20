classdef DeleteTrajectory<...
    matlabshared.application.undoredo.Edit&...
    fusion.internal.scenarioApp.undoredo.Edit

    properties(SetAccess=protected)
        CurrentPlatform;
        TrajectorySpecification;
        CurrentWaypoint;
    end

    methods

        function this=DeleteTrajectory(hDataModel)
            this@matlabshared.application.undoredo.Edit();
            this@fusion.internal.scenarioApp.undoredo.Edit(hDataModel);



            this.CurrentPlatform=hDataModel.CurrentPlatform;
            this.TrajectorySpecification=...
            copy(hDataModel.CurrentPlatform.TrajectorySpecification);
            this.CurrentWaypoint=hDataModel.CurrentWaypoint;
        end

        function execute(this)

            deleteCurrentTrajectory(this.DataModel);
        end

        function redo(this)
            if this.CurrentPlatform~=this.DataModel.CurrentPlatform
                this.DataModel.CurrentPlatform=this.CurrentPlatform;
            end


            deleteCurrentTrajectory(this.DataModel);
        end

        function undo(this)
            if this.CurrentPlatform~=this.DataModel.CurrentPlatform
                this.DataModel.CurrentPlatform=this.CurrentPlatform;
            end

            this.DataModel.CurrentPlatform.TrajectorySpecification=...
            copy(this.TrajectorySpecification);

            this.DataModel.CurrentWaypoint=this.CurrentWaypoint;

            notify(this.DataModel,'TrajectoryChanged');
        end
    end

end