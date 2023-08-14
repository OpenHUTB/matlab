function gs=groundStation(scenario,varargin)%#codegen

























































































































    coder.allowpcode('plain');


    validateattributes(scenario,{'satelliteScenario'},{'scalar'},...
    'groundStation','SCENARIO',1);
    if isempty(coder.target)&&~isvalid(scenario)
        msgID='shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject';
        msgArg='SCENARIO';
        msg=message(msgID,msgArg);
        error(msg);
    end


    simulator=scenario.Simulator;


    coder.internal.errorIf(simulator.SimulationMode==1&&simulator.SimulationStatus~=0,...
    'shared_orbit:orbitPropagator:UnableAddAssetOrAnalysisIncorrectSimStatus',...
    'ground station');


    if isempty(coder.target)
        scenarioHandle=scenario;
    else
        scenarioHandle=0;
    end


    if nargin>1&&isnumeric(varargin{1})


        defaultLatitude=varargin{1};
        defaultLongitude=varargin{2};
        paramArgs={varargin{3:end}};
    else
        defaultLatitude=42.3001;
        defaultLongitude=-71.3504;
        paramArgs=varargin;
    end
    if isempty(coder.target)
        paramNames={'Name','Latitude','Longitude','Altitude','MinElevationAngle','Viewer'};
    else
        paramNames={'Name','Latitude','Longitude','Altitude','MinElevationAngle'};
    end
    pstruct=coder.internal.parseParameterInputs(paramNames,satelliteScenario.InputParserOptions,paramArgs{:});
    name=coder.internal.getParameterValue(pstruct.Name,'',paramArgs{:});
    latitude=coder.internal.getParameterValue(pstruct.Latitude,defaultLatitude,paramArgs{:});
    longitude=coder.internal.getParameterValue(pstruct.Longitude,defaultLongitude,paramArgs{:});
    altitude=coder.internal.getParameterValue(pstruct.Altitude,0,paramArgs{:});
    minElevationAngle=coder.internal.getParameterValue(pstruct.MinElevationAngle,0,paramArgs{:});

    if isempty(coder.target)
        viewer=coder.internal.getParameterValue(pstruct.Viewer,scenario.Viewers,paramArgs{:});

        matlabshared.satellitescenario.ScenarioGraphic.validateViewerScenario(viewer,scenario);
    else
        viewer=0;
    end


    validateattributes(latitude,{'double'},...
    {'nonempty','real','finite','vector','>=',-90,...
    '<=',90},'groundStation','latitude');


    numGs=numel(latitude);


    validateattributes(longitude,{'double'},...
    {'nonempty','real','finite','vector','numel',numGs},...
    'groundStation','longitude');


    longitude(or(longitude>180,longitude<=-180))=...
    mod(longitude(or(longitude>180,longitude<=-180)),360);
    longitude(longitude>180)=longitude(longitude>180)-360;


    validateattributes(altitude,{'numeric'},...
    {'nonempty','real','finite','vector'},...
    'groundStation','Altitude');





    if~isscalar(altitude)
        validateattributes(altitude,{'numeric'},...
        {'numel',numGs},'groundStation','Altitude');
        altitudes=altitude;
    else
        altitudes=altitude*ones(1,numGs);
    end


    validateattributes(minElevationAngle,{'double'},...
    {'nonempty','real','finite','vector','>=',-90,...
    '<=',90},'groundStation','MinElevationAngle');






    if~isscalar(minElevationAngle)
        validateattributes(minElevationAngle,{'numeric'},...
        {'numel',numGs},'groundStation','MinElevationAngle');
        minElevationAngles=minElevationAngle;
    else
        minElevationAngles=minElevationAngle*ones(1,numGs);
    end




    if isempty(coder.target)
        validateattributes(name,{'string','char','cell'},{},...
        'groundStation','Name');
    else
        validateattributes(name,{'char','cell'},{},...
        'groundStation','Name');
    end


    if~isempty(name)
        if isstring(name)


            validateattributes(name,{'string'},...
            {'vector'},'groundStation','Name');

            if~isscalar(name)
                validateattributes(name,{'string'},...
                {'numel',numGs'},'groundStation','Name');
            end


            formattedNames=cell(1,numGs);
            for idx=1:numGs


                if isscalar(name)
                    validateattributes(char(name),{'char'},...
                    {'nonempty'},'groundStation','Name');


                    formattedNames{idx}=name;
                else
                    validateattributes(char(name(idx)),{'char'},...
                    {'nonempty'},'groundStation','Name');


                    formattedNames{idx}=name(idx);
                end
            end
        elseif iscell(name)




            validateattributes(name,{'cell'},...
            {'vector','nonempty'},'groundStation','Name');
            if~isscalar(name)
                validateattributes(name,{'cell'},...
                {'numel',numGs},'groundStation','Name');
            end

            formattedNames=cell(1,numGs);
            for idx=1:numGs

                if isscalar(name)
                    extractedName=name{1};
                else
                    extractedName=name{idx};
                end


                validateattributes(extractedName,...
                {'char'},{'scalartext'},'groundStation','Name');


                formattedNames{idx}=string(extractedName);


                validateattributes(char(formattedNames{idx}),{'char'},...
                {'nonempty'},'groundStation','Name');
            end
        elseif ischar(name)



            validateattributes(name,{'char'},...
            {'nonempty'},'groundStation','Name');


            convertedNames=string(name);


            formattedNames=cell(1,numGs);


            for idx=1:numGs
                formattedNames{idx}=convertedNames;
            end
        end
    else
        formattedNames={''};
    end


    existingGs=scenario.GroundStations;


    gs=matlabshared.satellitescenario.GroundStation(formattedNames,latitude,...
    longitude,altitudes,minElevationAngles,simulator,scenarioHandle);


    if isempty(existingGs)||~scenario.pGroundStationsAddedBefore
        scenario.GroundStations=gs;
        scenario.pGroundStationsAddedBefore=true;
    else
        scenario.GroundStations=[existingGs,gs];
    end



    simulator.NeedToSimulate=true;

    if coder.target('MATLAB')
        scenario.NeedToSimulate=true;

        scenario.addToScenarioGraphics(gs);



        for k=1:numel(viewer)
            if~viewer(k).ShowDetails
                gsHandles=gs.Handles;
                for k2=1:numGs
                    gsHandles{k2}.pShowLabel=false;
                end
            end
        end

        showIfAutoShow(gs,scenario,viewer);
    end
end


