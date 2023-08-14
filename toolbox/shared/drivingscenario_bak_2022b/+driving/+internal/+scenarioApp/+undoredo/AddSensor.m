classdef AddSensor<driving.internal.scenarioApp.undoredo.Add

    methods
        function this=AddSensor(varargin)
            this@driving.internal.scenarioApp.undoredo.Add(varargin{:});
        end

        function execute(this)
            addSensor(this.Application,this.Inputs{:});
        end

        function undo(this)

            this.Specification=deleteSensor(this.Application,numel(this.Application.SensorSpecifications));
        end




        function redo(this)
            addSensorSpecification(this.Application,this.Specification);
            updateForSensors(this.Application);
        end

        function str=getDescription(~)
            str=getString(message('driving:scenarioApp:AddSensorText'));
        end
    end
end


