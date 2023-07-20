classdef SetMultipleSensorProperties<driving.internal.scenarioApp.undoredo.SetSensorProperty

    methods
        function this=SetMultipleSensorProperties(hApp,spec,propNames,newValues)




            oldValues=cell(1,numel(propNames));
            for indx=1:numel(propNames)
                oldValues{indx}=spec.(propNames{indx});
            end
            this@driving.internal.scenarioApp.undoredo.SetSensorProperty(...
            hApp,spec,propNames,newValues,oldValues);
        end

        function execute(this)
            propNames=this.Property;
            newValues=this.NewValue;
            actorSpec=this.Object;




            sensor=this.Object.Sensor;
            if isLocked(sensor)
                release(sensor);
            end


            for indx=1:numel(propNames)
                actorSpec.(propNames{indx})=newValues{indx};
            end
            try
                updateScenario(this);
            catch ME



                oldValues=this.OldValue;
                for indx=1:numel(propNames)
                    actorSpec.(propNames{indx})=oldValues{indx};
                end
                rethrow(ME);
            end
        end

        function undo(this)
            propNames=this.Property;
            oldValues=this.OldValue;
            actorSpec=this.Object;




            sensor=this.Object.Sensor;
            if isLocked(sensor)
                release(sensor);
            end


            for indx=1:numel(propNames)
                actorSpec.(propNames{indx})=oldValues{indx};
            end
            updateScenario(this);
        end

        function str=getDescription(~)
            str=getString(message('driving:scenarioApp:SetMultiplePropertiesText'));
        end
    end
end


