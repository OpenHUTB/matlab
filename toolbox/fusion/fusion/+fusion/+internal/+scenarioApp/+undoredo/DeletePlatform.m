classdef DeletePlatform<matlabshared.application.undoredo.Edit&fusion.internal.scenarioApp.undoredo.Edit

    properties(SetAccess=protected)
Specification
SensorSpecifications
    end

    methods

        function this=DeletePlatform(hDataModel,hSpec)
            this@matlabshared.application.undoredo.Edit();
            this@fusion.internal.scenarioApp.undoredo.Edit(hDataModel);
            if nargin<2
                hSpec=hDataModel.CurrentPlatform;
            end
            this.Specification=hSpec;
            this.SensorSpecifications=hDataModel.getSensorsByPlatform(hSpec.ID);
        end

        function execute(this)
            deletePlatform(this.DataModel,this.Specification);
        end

        function undo(this)
            addPlatformSpecification(this.DataModel,this.Specification);
            for i=1:numel(this.SensorSpecifications)
                sensorSpec=this.SensorSpecifications(i);

                sensorSpec.PlatformID=this.Specification.ID;
                addSensorSpecification(this.DataModel,sensorSpec);
            end
        end
    end

end