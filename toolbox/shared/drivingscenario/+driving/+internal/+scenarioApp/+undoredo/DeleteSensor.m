classdef DeleteSensor<driving.internal.scenarioApp.undoredo.Delete

    methods
        function this=DeleteSensor(varargin)
            this@driving.internal.scenarioApp.undoredo.Delete(varargin{:});
        end

        function execute(this)
            this.Specification=deleteSensor(this.Application,this.Index);
        end

        function undo(this)
            addSensorSpecification(this.Application,this.Specification,this.Index);
            updateForSensors(this.Application);
        end

        function str=getDescription(~)
            str=getString(message('driving:scenarioApp:DeleteSensorText'));
        end
    end
end


