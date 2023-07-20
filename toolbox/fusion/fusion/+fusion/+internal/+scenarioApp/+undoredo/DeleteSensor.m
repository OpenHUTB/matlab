classdef DeleteSensor<matlabshared.application.undoredo.Edit&fusion.internal.scenarioApp.undoredo.Edit

    properties(SetAccess=protected)
Specification
    end

    methods

        function this=DeleteSensor(hDataModel,hSpec)
            this@matlabshared.application.undoredo.Edit();
            this@fusion.internal.scenarioApp.undoredo.Edit(hDataModel);
            if nargin<2
                hSpec=hDataModel.CurrentSensor;
            end
            this.Specification=hSpec;
        end

        function execute(this)
            deleteSensor(this.DataModel,this.Specification);
        end

        function undo(this)
            addSensorSpecification(this.DataModel,this.Specification);
        end
    end
end