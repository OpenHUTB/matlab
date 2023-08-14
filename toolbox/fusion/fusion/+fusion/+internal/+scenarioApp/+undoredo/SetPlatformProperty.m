classdef SetPlatformProperty<fusion.internal.scenarioApp.undoredo.Edit&...
    matlabshared.application.undoredo.SetProperty

    methods
        function this=SetPlatformProperty(hDataModel,varargin)
            this@fusion.internal.scenarioApp.undoredo.Edit(hDataModel);
            this@matlabshared.application.undoredo.SetProperty(varargin{:});
        end

        function execute(this)
            execute@matlabshared.application.undoredo.SetProperty(this);
            notify(this.DataModel,'PlatformsChanged');
        end

        function undo(this)
            undo@matlabshared.application.undoredo.SetProperty(this)
            notify(this.DataModel,'PlatformsChanged');
        end
    end
end
