classdef SetSensorProperty<driving.internal.scenarioApp.undoredo.SetProperty

    methods
        function this=SetSensorProperty(varargin)
            this@driving.internal.scenarioApp.undoredo.SetProperty(varargin{:});
        end

        function execute(this)
            if~strcmp(this.Property,'Name')




                unlockSensor(this);
            end

            w=matlabshared.application.IgnoreWarnings('MATLAB:system:nonRelevantProperty');%#ok
            execute@driving.internal.scenarioApp.undoredo.SetProperty(this);
        end

        function undo(this)
            if~strcmp(this.Property,'Name')




                unlockSensor(this);
            end

            w=matlabshared.application.IgnoreWarnings('MATLAB:system:nonRelevantProperty');%#ok
            undo@driving.internal.scenarioApp.undoredo.SetProperty(this);
        end

        function updateScenario(this)
            app=this.Application;
            try
                updateForSensors(app);
            catch ME


                if~strcmp(ME.identifier,'MATLAB:class:InvalidHandle')
                    rethrow(ME);
                end
            end
        end
    end

    methods(Access=protected)
        function unlockSensor(this)
            sensor=this.Object.Sensor;
            if isLocked(sensor)
                release(sensor);
            end
        end
    end
end


