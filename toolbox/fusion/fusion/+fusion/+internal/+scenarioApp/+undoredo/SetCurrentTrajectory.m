classdef SetCurrentTrajectory<fusion.internal.scenarioApp.undoredo.Edit&...
    matlabshared.application.undoredo.SetProperty

    properties
CurrentPlatform
    end

    methods
        function this=SetCurrentTrajectory(hDataModel,currentPlatform,varargin)
            this@fusion.internal.scenarioApp.undoredo.Edit(hDataModel);
            this@matlabshared.application.undoredo.SetProperty(...
            currentPlatform,'TrajectorySpecification',varargin{:});
            this.CurrentPlatform=currentPlatform;
        end

        function execute(this)
            execute@matlabshared.application.undoredo.SetProperty(this);
            if this.CurrentPlatform~=this.DataModel.CurrentPlatform
                this.DataModel.CurrentPlatform=this.CurrentPlatform;
            end
            notify(this.DataModel,'TrajectoryChanged');
        end

        function undo(this)
            undo@matlabshared.application.undoredo.SetProperty(this)
            if this.CurrentPlatform~=this.DataModel.CurrentPlatform
                this.DataModel.CurrentPlatform=this.CurrentPlatform;
            end
            notify(this.DataModel,'TrajectoryChanged');
        end
    end
end
