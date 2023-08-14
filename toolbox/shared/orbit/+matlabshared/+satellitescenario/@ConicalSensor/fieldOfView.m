function fov=fieldOfView(sensors,varargin)






















































































    validateattributes(sensors,{'matlabshared.satellitescenario.ConicalSensor'},...
    {'nonempty','vector'},...
    'fieldOfView','SENSOR',1);
    if sum(~isvalid(sensors))>0
        msg=message(...
        'shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject',...
        'SENSOR');
        error(msg);
    end


    scenario=sensors(1).Scenario;

    if~isa(scenario,'satelliteScenario')
        msg=message(...
        'shared_orbit:orbitPropagator:ScenarioGraphicVisualizeOrphan');
        error(msg);
    end


    coder.internal.errorIf(sensors(1).Simulator.SimulationMode==1&&sensors(1).Simulator.SimulationStatus~=0,...
    'shared_orbit:orbitPropagator:UnableAddAssetOrAnalysisIncorrectSimStatus',...
    'field of view analysis');


    numSensors=numel(sensors);
    sensors=sensors.Handles;

    for idx=1:numSensors
        if~isa(scenario,'satelliteScenario')||~isa(sensors{idx}.Scenario,'satelliteScenario')||scenario~=sensors{idx}.Scenario
            msg=message(...
            'shared_orbit:orbitPropagator:SatelliteFieldOfViewDifferentScenario');
            error(msg);
        end
    end


    try
        [viewer,args]=matlabshared.satellitescenario.ScenarioGraphic.parseViewerInput(scenario.Viewers,scenario,varargin{:});
    catch e
        throwAsCaller(e);
    end

    fov=matlabshared.satellitescenario.FieldOfView.empty;

    simulator=sensors{1}.Simulator;
    if simulator.NumFieldsOfView==0
        simulator.FieldsOfView=repmat(simulator.FieldOfViewStruct,1,numSensors);
    else
        newFovStruct=repmat(simulator.FieldOfViewStruct,1,numSensors);
        simulator.FieldsOfView=[simulator.FieldsOfView,newFovStruct];
    end
    for idx=1:numSensors

        sensor=sensors{idx};

        if isempty(sensor.FieldOfView)


            sensor.FieldOfView=matlabshared.satellitescenario.FieldOfView(sensor,scenario,args{:});


            if coder.target('MATLAB')
                scenario.addToScenarioGraphics(sensor.FieldOfView);
            end
        else

            sensor.FieldOfView.parseShowInputs(args{:});
        end

        fov(idx)=sensor.FieldOfView;
        fov(idx).Parent=sensor;
    end


    advance(sensor.Simulator,sensor.Simulator.Time);



    sensor.Simulator.NeedToSimulate=true;
    if coder.target('MATLAB')
        scenario.NeedToSimulate=true;
    end


    showIfAutoShow(fov,scenario,viewer);
end


