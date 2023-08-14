classdef ChangeTrajectory<fusion.internal.scenarioApp.undoredo.Edit&...
    matlabshared.application.undoredo.SetProperty

    properties
CurrentPlatform
NewWaypoint
OldWaypoint
    end

    methods
        function this=ChangeTrajectory(hDataModel,currentPlatform,newIdx,newTraj,oldIdx,oldTraj)
            this@fusion.internal.scenarioApp.undoredo.Edit(hDataModel);
            this@matlabshared.application.undoredo.SetProperty(...
            currentPlatform,'TrajectorySpecification',newTraj,oldTraj);
            this.CurrentPlatform=currentPlatform;
            this.NewWaypoint=newIdx;
            this.OldWaypoint=oldIdx;
        end

        function execute(this)
            execute@matlabshared.application.undoredo.SetProperty(this);
            if this.DataModel.CurrentPlatform~=this.CurrentPlatform
                this.DataModel.CurrentPlatform=this.CurrentPlatform;
            end


            this.DataModel.CurrentWaypoint=this.NewWaypoint;

            notify(this.DataModel,'TrajectoryChanged');
        end

        function undo(this)
            undo@matlabshared.application.undoredo.SetProperty(this)
            if this.CurrentPlatform~=this.DataModel.CurrentPlatform
                this.DataModel.CurrentPlatform=this.CurrentPlatform;
            end

            this.DataModel.CurrentWaypoint=this.OldWaypoint;

            notify(this.DataModel,'TrajectoryChanged');
        end
    end
end
