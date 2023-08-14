classdef AddPlatform<matlabshared.application.undoredo.Edit&fusion.internal.scenarioApp.undoredo.Edit

    properties(SetAccess=protected)
        Inputs={};
    end

    properties(Access=protected)
Specification
    end

    methods

        function this=AddPlatform(hDataModel,varargin)
            this@fusion.internal.scenarioApp.undoredo.Edit(hDataModel);
            this.Inputs=varargin;
        end

        function execute(this)
            addPlatform(this.DataModel,this.Inputs{:});
        end

        function undo(this)
            this.Specification=deletePlatform(this.DataModel,numel(this.DataModel.PlatformSpecifications));
        end

        function redo(this)
            addPlatformSpecification(this.DataModel,this.Specification);
        end
    end
end
