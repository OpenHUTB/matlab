classdef CutSensor<driving.internal.scenarioApp.undoredo.DeleteSensor

    methods
        function this=CutSensor(hApp,hSensor)
            index=find(hApp.SensorSpecifications==hSensor);
            this@driving.internal.scenarioApp.undoredo.DeleteSensor(hApp,index);
        end

        function str=getDescription(this)
            str=getString(message('Spcuilib:application:CutObject',this.Specification.Name));
        end
    end
end
