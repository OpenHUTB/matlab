classdef Designer<matlabshared.application.CommandLineInterface

    methods
        function this=Designer(varargin)
            parseInputs(this,varargin{:});
        end



        function close(this)
            close(this.Application);
        end
    end

    methods(Hidden)

        function addRoad(this,roadCenters,varargin)
            narginchk(2,inf)
            if rem(numel(varargin),2)==1
                error(message('driving:scenarioApp:InvalidPVPairs'));
            end
            designer=this.Application;
            edit=driving.internal.scenarioApp.undoredo.AddRoad(designer,roadCenters,varargin{:});
            try
                applyEdit(designer,edit);
            catch me
                throwAsCaller(me)
            end
        end

        function addSensor(this,type,varargin)
            narginchk(2,inf)
            if rem(numel(varargin),2)==1
                error(message('driving:scenarioApp:InvalidPVPairs'));
            end
            designer=this.Application;
            edit=driving.internal.scenarioApp.undoredo.AddSensor(designer,type,varargin{:});
            try
                applyEdit(designer,edit);
            catch me
                throwAsCaller(me)
            end
        end

        function addActor(this,classId,varargin)
            narginchk(2,inf)
            if rem(numel(varargin),2)==1
                error(message('driving:scenarioApp:InvalidPVPairs'));
            end


            designer=this.Application;
            edit=driving.internal.scenarioApp.undoredo.AddActor(designer,'ClassID',classId,varargin{:});
            try
                applyEdit(designer,edit);
            catch me
                throwAsCaller(me)
            end
        end

        function addBarrier(this,barrierCenters,classId,varargin)
            narginchk(2,inf)
            if rem(numel(varargin),2)==1
                error(message('driving:scenarioApp:InvalidPVPairs'));
            end


            designer=this.Application;

            classSpecs=designer.ClassSpecifications;
            classSpec=getSpecification(classSpecs,classId);
            spec=driving.internal.scenarioApp.BarrierSpecification(barrierCenters);
            spec.initializePropertiesFromClassSpecification(classSpec);

            spec.Name=getUniqueName(getBarrierAdder(this.Application),spec.Name);

            for indx=1:2:numel(varargin)
                spec.(varargin{indx})=varargin{indx+1};
            end
            edit=driving.internal.scenarioApp.undoredo.AddBarrier(designer,spec);
            try
                applyEdit(designer,edit);
            catch me
                throwAsCaller(me)
            end
        end


        function deleteRoad(this,index)
            narginchk(2,2);

            designer=this.Application;
            edit=driving.internal.scenarioApp.undoredo.DeleteRoad(designer,index);
            try
                applyEdit(designer,edit);
            catch me
                throwAsCaller(me)
            end
        end

        function deleteActor(this,index)
            narginchk(2,2);

            designer=this.Application;
            edit=driving.internal.scenarioApp.undoredo.DeleteActor(designer,index);
            try
                applyEdit(designer,edit);
            catch me
                throwAsCaller(me)
            end
        end

        function deleteBarrier(this,index)
            narginchk(2,2);

            designer=this.Application;
            edit=driving.internal.scenarioApp.undoredo.DeleteBarrier(designer,index);
            try
                applyEdit(designer,edit);
            catch me
                throwAsCaller(me)
            end
        end

        function deleteSensor(this,index)
            narginchk(2,2);
            designer=this.Application;
            edit=driving.internal.scenarioApp.undoredo.DeleteSensor(designer,index);
            try
                applyEdit(designer,edit);
            catch me
                throwAsCaller(me)
            end
        end


        function setRoadProperty(this,index,varargin)
            narginchk(2,inf);
            if rem(numel(varargin),2)==1
                error(message('driving:scenarioApp:InvalidPVPairs'));
            end
            designer=this.Application;
            allRoads=designer.RoadSpecifications;
            if index>numel(allRoads)||index<1
                error(message('driving:scenarioApp:InvalidRoadIndex'));
            end
            spec=allRoads(index);
            if numel(varargin)==2
                edit=driving.internal.scenarioApp.undoredo.SetRoadProperty(designer,spec,varargin{:});
            else
                edit=driving.internal.scenarioApp.undoredo.SetMultipleRoadProperties(designer,spec,varargin{:});
            end
            try
                applyEdit(designer,edit);
            catch me
                throwAsCaller(me)
            end
        end

        function setActorProperty(this,index,varargin)
            narginchk(2,inf);

            if rem(numel(varargin),2)==1
                error(message('driving:scenarioApp:InvalidPVPairs'));
            end
            designer=this.Application;
            allActors=designer.ActorSpecifications;
            if index>numel(allActors)||index<1
                error(message('driving:scenarioApp:InvalidActorIndex'));
            end
            spec=allActors(index);
            if numel(varargin)==2
                edit=driving.internal.scenarioApp.undoredo.SetActorProperty(designer,spec,varargin{:});
            else
                edit=driving.internal.scenarioApp.undoredo.SetMultipleActorProperties(designer,spec,varargin{:});
            end
            try
                applyEdit(designer,edit);
            catch me
                throwAsCaller(me)
            end
        end

        function setBarrierProperty(this,index,varargin)
            narginchk(2,inf);

            if rem(numel(varargin),2)==1
                error(message('driving:scenarioApp:InvalidPVPairs'));
            end
            designer=this.Application;
            allBarriers=designer.BarrierSpecifications;
            if index>numel(allBarriers)||index<1
                error(message('driving:scenarioApp:InvalidBarrierIndex'));
            end
            spec=allBarriers(index);
            if numel(varargin)==2
                edit=driving.internal.scenarioApp.undoredo.SetBarrierProperty(designer,spec,varargin{:});
            else
                edit=driving.internal.scenarioApp.undoredo.SetMultipleBarrierProperties(designer,spec,varargin{:});
            end
            try
                applyEdit(designer,edit);
            catch me
                throwAsCaller(me)
            end
        end

        function setSensorProperty(this,index,varargin)
            narginchk(2,inf);
            if rem(numel(varargin),2)==1
                error(message('driving:scenarioApp:InvalidPVPairs'));
            end
            designer=this.Application;
            allSensors=designer.SensorSpecifications;
            if index>numel(allSensors)||index<1
                error(message('driving:scenarioApp:InvalidSensorIndex'));
            end
            spec=allSensors(index);
            if numel(varargin)==2
                edit=driving.internal.scenarioApp.undoredo.SetSensorProperty(designer,spec,varargin{:});
            else
                edit=driving.internal.scenarioApp.undoredo.SetMultipleSensorProperties(designer,spec,varargin{:});
            end
            try
                applyEdit(designer,edit);
            catch me
                throwAsCaller(me)
            end
        end


        function value=getRoadProperty(this,index,propertyName)
            narginchk(3,3);
            value=this.Application.RoadSpecifications(index).(propertyName);
        end

        function value=getActorProperty(this,index,propertyName)
            narginchk(3,3);
            value=this.Application.ActorSpecifications(index).(propertyName);
        end

        function value=getBarrierProperty(this,index,propertyName)
            narginchk(3,3);
            value=this.Application.BarrierSpecifications(index).(propertyName);
        end

        function value=getSensorProperty(this,index,propertyName)
            narginchk(3,3);
            value=this.Application.SensorSpecifications(index).(propertyName);
        end


        function new(this,tag)
            new(this.Application,tag);
        end

        function openFile(this,varargin)
            openFile(this.Application,varargin{:});
        end

        function saveFile(this,varargin)
            saveFile(this.Application,varargin{:});
        end

        function saveFileAs(this,varargin)
            saveFileAs(this.Application,varargin{:});
        end


        function play(this)
            play(this.Application.Player);
        end

        function stepForward(this)
            stepForward(this.Application.Player);
        end

        function stepBackward(this)
            stepBackward(this.Application.Player);
        end

        function pause(this)
            pause(this.Application.Player);
        end

        function stop(this)
            stop(this.Application.Player);
        end

        function goToStart(this)
            setCurrentSample(this.Application.Player,1);
        end


        function generateMatlabCode(this)
        end

        function generateSimulinkModel(this)
        end

        function d=getSensorData(this)
        end

        function s=getScenario(this)
            s=generateNewScenarioFromSpecifications(this.Application);
        end

        function s=getSensors(this)
            ss=this.Application.SensorSpecifications;
            s=cell(1,numel(ss));
            for indx=1:numel(ss)
                s{indx}=clone(getSensor(ss(indx)));
            end
        end

        function undo(this)
            undo(this.Application.UndoRedo);
        end

        function redo(this)
            redo(this.Application.UndoRedo);
        end
    end

    methods(Access=protected)
        function name=getApplicationClassName(~)
            name='driving.internal.scenarioApp.Designer';
        end

        function id=getInvalidApplicationErrorID(~)
            id='driving:scenarioApp:InvalidDesignerConstructor';
        end
    end
end
