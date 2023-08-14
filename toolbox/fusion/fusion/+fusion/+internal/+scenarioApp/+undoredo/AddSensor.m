classdef AddSensor<matlabshared.application.undoredo.Edit&fusion.internal.scenarioApp.undoredo.Edit

    properties(SetAccess=protected)
        Inputs={};
    end

    properties(Access=protected)
Specification
    end

    methods

        function this=AddSensor(hDataModel,varargin)
            this@fusion.internal.scenarioApp.undoredo.Edit(hDataModel);
            this.Inputs=varargin;
        end

        function execute(this)
            addSensor(this.DataModel,this.Inputs{:});
        end

        function undo(this)
            this.Specification=deleteSensor(this.DataModel,numel(this.DataModel.SensorSpecifications));
        end

        function redo(this)
            addSensorSpecification(this.DataModel,this.Specification);
        end
    end
end
