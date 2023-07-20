function gt=groundTrack(sats,varargin)




























































































    validateattributes(sats,{'matlabshared.satellitescenario.Satellite'},{'vector'},...
    'groundTrack','SAT',1);
    if sum(~isvalid(sats))>0
        msg=message(...
        'shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject',...
        'SAT');
        error(msg);
    end


    scenario=sats(1).Scenario;
    if~isa(scenario,'satelliteScenario')
        msg=message(...
        'shared_orbit:orbitPropagator:ScenarioGraphicVisualizeOrphan');
        error(msg);
    end


    numSats=numel(sats);


    for idx=1:numSats
        if~isequal(scenario,sats.Handles{idx}.Scenario)
            msg=message(...
            'shared_orbit:orbitPropagator:SatelliteGroundTrackDifferentScenario');
            error(msg);
        end
    end


    try
        [viewer,args]=matlabshared.satellitescenario.ScenarioGraphic.parseViewerInput(scenario.Viewers,scenario,varargin{:});
    catch e
        throwAsCaller(e);
    end

    gt=matlabshared.satellitescenario.GroundTrack.empty;
    for idx=1:numSats
        sat=sats(idx);
        if isempty(sat.GroundTrack)

            sat.GroundTrack=matlabshared.satellitescenario.GroundTrack(sat,scenario,args{:});

            if coder.target('MATLAB')
                scenario.addToScenarioGraphics(sat.GroundTrack);
            end
            scenario.NeedToSimulate=true;
        else

            sat.GroundTrack.parseShowInputs(args{:});


            if(strcmp(sat.GroundTrack.VisibilityMode,'auto'))
                sat.GroundTrack.VisibilityMode='inherit';
            end
        end
        gt(idx)=sat.GroundTrack;
    end



    showIfAutoShow(gt,scenario,viewer);
end


