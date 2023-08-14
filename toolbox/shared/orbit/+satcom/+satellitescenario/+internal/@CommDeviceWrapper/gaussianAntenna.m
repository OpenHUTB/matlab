function an=gaussianAntenna(trx,varargin)%#codegen
















































































































































    coder.allowpcode('plain');


    if coder.target('MATLAB')
        scalarOrVector='vector';
    else
        scalarOrVector='scalar';
    end
    validateattributes(trx,...
    {'satcom.satellitescenario.Transmitter','satcom.satellitescenario.Receiver'},...
    {'nonempty',scalarOrVector},'link','SOURCE',1);


    numAssets=numel(trx);

    if coder.target('MATLAB')

        for idx=1:numAssets
            if~isvalid(trx(idx))
                msg=message(...
                'shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject',...
                'SOURCE');
                error(msg);
            end
        end
    end


    simulator=trx(1).Simulator;


    coder.internal.errorIf(simulator.SimulationMode==1&&simulator.SimulationStatus~=0,...
    'shared_orbit:orbitPropagator:UnableAddAssetOrAnalysisIncorrectSimStatus',...
    'Gaussian antenna');

    if coder.target('MATLAB')

        for idx=1:numAssets
            if~isequal(trx(idx).Simulator,simulator)
                msg=message(...
                'shared_orbit:orbitPropagator:InputsDifferentSatelliteScenario');
                error(msg);
            end
        end
    end


    paramNames={'DishDiameter','ApertureEfficiency'};
    pstruct=coder.internal.parseParameterInputs(paramNames,satelliteScenario.InputParserOptions,varargin{:});
    dishDiameter=coder.internal.getParameterValue(pstruct.DishDiameter,1,varargin{:});
    apertureEfficiency=coder.internal.getParameterValue(pstruct.ApertureEfficiency,0.65,varargin{:});


    validateattributes(dishDiameter,...
    {'double'},...
    {'nonempty','finite','real',scalarOrVector,'positive'},...
    'gaussianAntenna','DishDiameter');


    validateattributes(apertureEfficiency,...
    {'double'},...
    {'nonempty','finite','real',scalarOrVector,'positive','<=',1},...
    'gaussianAntenna','ApertureEfficiency');


    numDishDiameter=numel(dishDiameter);


    numApertureEfficiency=numel(apertureEfficiency);


    if coder.target('MATLAB')
        numAntennas=numAssets;
    else
        numAntennas=1;
    end



    if numDishDiameter~=1
        validateattributes(dishDiameter,...
        {'double'},...
        {'numel',numAntennas},...
        'gaussianAntenna','DishDiameter');
    end




    if numApertureEfficiency~=1
        validateattributes(apertureEfficiency,...
        {'double'},...
        {'numel',numAntennas},...
        'gaussianAntenna','ApertureEfficiency');
    end


    an=satcom.satellitescenario.GaussianAntenna;




    for idx=numAntennas:-1:1

        if numDishDiameter==1
            ddia=dishDiameter;
        else
            ddia=dishDiameter(idx);
        end


        if numApertureEfficiency==1
            ae=apertureEfficiency;
        else
            ae=apertureEfficiency(idx);
        end


        an(idx)=satcom.satellitescenario.GaussianAntenna(ddia,ae);



        trx(idx).Antenna=an(idx);


        assetIdx=getIdxInSimulatorStruct(trx(idx));
        switch trx(idx).Type
        case 5
            simulator.Transmitters(assetIdx).Antenna=an(idx);
            if coder.target('MATLAB')
                simulator.Transmitters(assetIdx).AntennaType=0;
                simulator.Transmitters(assetIdx).DishDiameter=ddia;
                simulator.Transmitters(assetIdx).ApertureEfficiency=ae;
            end
        otherwise
            simulator.Receivers(assetIdx).Antenna=an(idx);
            if coder.target('MATLAB')
                simulator.Receivers(assetIdx).AntennaType=0;
                simulator.Receivers(assetIdx).DishDiameter=ddia;
                simulator.Receivers(assetIdx).ApertureEfficiency=ae;
            end
        end
    end


    advance(simulator,simulator.Time);


    simulator.NeedToSimulate=true;

    if(coder.target('MATLAB'))

        if isa(trx(1).Scenario,'satelliteScenario')
            trx(1).Scenario.NeedToSimulate=true;
            updateViewers(trx,trx(1).Scenario.Viewers,false,true);
        end
    end
end