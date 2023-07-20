function sats=satellite(scenario,varargin)%#codegen




































































































































































































































































































    coder.allowpcode('plain');
    coder.extrinsic('getGPSWeekRollOvers','matlabshared.internal.gnss.GPSTime.getLocalTime');


    validateattributes(scenario,{'satelliteScenario'},{'scalar'},...
    'satellite','SCENARIO',1);
    if isempty(coder.target)&&~isvalid(scenario)
        msg=message(...
        'shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject',...
        'SCENARIO');
        error(msg);
    end



    originalStartTime=scenario.StartTime;
    originalStopTime=scenario.StopTime;
    originalSampleTime=scenario.SampleTime;
    originalTime=scenario.Simulator.Time;
    originalUsingDefaultTimes=scenario.UsingDefaultTimes;
    originalEarliestProvidedEpoch=scenario.EarliestProvidedEpoch;


    simulator=scenario.Simulator;


    coder.internal.errorIf(simulator.SimulationMode==1&&simulator.SimulationStatus~=0,...
    'shared_orbit:orbitPropagator:UnableAddAssetOrAnalysisIncorrectSimStatus',...
    'satellite');


    if isa(varargin{1},"numeric")

        initMode="keplerian";
    elseif isa(varargin{1},"timetable")||isa(varargin{1},"table")

        initMode="timetable";
    elseif isa(varargin{1},"timeseries")||isa(varargin{1},"tscollection")

        initMode="timeseries";
    elseif isa(varargin{1},"struct")

        initMode="rinex";
    else

        initMode="file";
    end

    switch initMode
    case "keplerian"
        narginchk(7,inf)
        semiMajorAxis=varargin{1};
        eccentricity=varargin{2};
        inclination=varargin{3}*pi/180;
        rightAscensionOfAscendingNode=varargin{4}*pi/180;
        argumentOfPeriapsis=varargin{5}*pi/180;
        trueAnomaly=varargin{6}*pi/180;
        paramArgs={varargin{7:end}};


        validateattributes(semiMajorAxis,{'double'},...
        {'nonempty','real','finite','positive','vector'},...
        'satellite','SEMIMAJORAXIS');


        numSats=numel(semiMajorAxis);


        validateattributes(eccentricity,{'double'},...
        {'nonempty','real','finite','nonnegative','<',1,'vector',...
        'numel',numSats},'satellite','ECCENTRICITY');

        validateattributes(inclination,{'double'},...
        {'nonempty','real','finite','vector','numel',numSats},...
        'satellite','INCLINATION');

        validateattributes(rightAscensionOfAscendingNode,{'double'},...
        {'nonempty','real','finite','vector','numel',numSats},...
        'satellite','RIGHTASCENSIONOFASCENDINGNODE');

        validateattributes(argumentOfPeriapsis,{'double'},...
        {'nonempty','real','finite','vector','numel',numSats},...
        'satellite','ARGUMENTOFPERIAPSIS');

        validateattributes(trueAnomaly,{'double'},...
        {'nonempty','real','finite','vector','numel',numSats},...
        'satellite','TRUEANOMALY');

    case "timetable"
        if~isempty(coder.target)


            coder.internal.errorIf(true,'shared_orbit:orbitPropagator:EphemerisNotSupportedForCodegen');
        end
        narginchk(2,inf)
        positionTable=varargin{1};
        if(nargin>2)&&(isa(varargin{2},"timetable")||isa(varargin{2},"table"))

            velocityTable=varargin{2};
            paramArgs={varargin{3:end}};
        else
            velocityTable=timetable.empty;
            paramArgs={varargin{2:end}};
        end


        if istable(varargin{1})
            positionTable=table2timetable(positionTable);
            if~isempty(velocityTable)
                velocityTable=table2timetable(velocityTable);
            end
        end


        numSats=numel(positionTable.Properties.VariableNames);

    case "timeseries"
        if~isempty(coder.target)


            coder.internal.errorIf(true,'shared_orbit:orbitPropagator:EphemerisNotSupportedForCodegen');
        end
        narginchk(2,inf)
        positionSeries=varargin{1};
        if(nargin>2)&&(isa(varargin{2},"timeseries")||isa(varargin{2},"tscollection"))
            velocitySeries=varargin{2};
            paramArgs={varargin{3:end}};
        else
            velocitySeries=timeseries.empty;
            paramArgs={varargin{2:end}};
        end


        if isa(positionSeries,"timeseries")




            validateattributes(positionSeries.Data,{'numeric'},...
            {'nonempty','real','finite','3d'},...
            'satellite','positionSeries');


            [positionSeries,numSats]=matlabshared.orbit.internal.processMultiDimTSintoCellArrayOfTS(positionSeries,3);
            if~isempty(velocitySeries)
                velocitySeries=matlabshared.orbit.internal.processMultiDimTSintoCellArrayOfTS(velocitySeries,3);
            end

        else
            numSats=0;
            positionSeriesCells=cell.empty;
            velocitySeriesCells=cell.empty;



            for idx=1:numel(positionSeries.gettimeseriesnames)
                [posSeriesCurrent,currNumSats]=matlabshared.orbit.internal.processMultiDimTSintoCellArrayOfTS(...
                get(positionSeries,positionSeries.gettimeseriesnames{idx}),3);
                numSats=numSats+currNumSats;
                positionSeriesCells=[positionSeriesCells;posSeriesCurrent];%#ok<AGROW>

                if~isempty(velocitySeries)
                    velSeriesCurrent=matlabshared.orbit.internal.processMultiDimTSintoCellArrayOfTS(...
                    get(velocitySeries,velocitySeries.gettimeseriesnames{idx}),3);
                    velocitySeriesCells=[velocitySeriesCells;velSeriesCurrent];%#ok<AGROW>
                end
            end

            positionSeries=positionSeriesCells;
            velocitySeries=velocitySeriesCells;
        end
    case "rinex"
        narginchk(2,inf)
        rnx=varargin{1};
        paramArgs={varargin{2:end}};


        coder.internal.errorIf(~isfield(rnx,'GPS')&&~isfield(rnx,'Galileo'),...
        'shared_orbit:orbitPropagator:NoRINEXGPSOrGalileoNavigationMessage');

        [rnx,validGPSMessage,validGalileoMessage]=...
        mergeRINEXData(rnx,scenario.UsingDefaultTimes,scenario.StartTime);


        numGPSSats=0;
        numGalileoSats=0;
        if validGPSMessage
            numGPSSats=size(rnx.GPS,1);
        end
        if validGalileoMessage
            numGalileoSats=size(rnx.Galileo,1);
        end
        numSats=numGPSSats+numGalileoSats;
    otherwise
        narginchk(2,inf)
        file=varargin{1};
        paramArgs={varargin{2:end}};





        usingTLE=coder.const(feval('matlabshared.satellitescenario.internal.isUsingTLE',file));


        if usingTLE
            if isempty(coder.target)
                try
                    tleData=matlabshared.orbit.internal.tledata(file);
                catch ME
                    msg=message(...
                    'shared_orbit:orbitPropagator:SatelliteScenarioInvalidTLE');
                    baseException=MException(msg);
                    baseException=addCause(baseException,ME);
                    throw(baseException);
                end
            else
                tleData=coder.const(feval('matlabshared.orbit.internal.coder.tledata',file));
            end


            numSats=numel(tleData);
        else
            if isempty(coder.target)
                try
                    [~,gpsWeekNum,gpsTimeOfApplicability,gpsRecords]=matlabshared.internal.gnss.readSEMAlmanac(file);
                catch ME
                    msg=message(...
                    'shared_orbit:orbitPropagator:SatelliteScenarioInvalidSEM');
                    baseException=MException(msg);
                    baseException=addCause(baseException,ME);
                    throw(baseException);
                end
            else
                if~coder.target('MEX')




                    coder.internal.errorIf(true,'shared_orbit:orbitPropagator:UnsupportedCodegenTarget');
                end
                [~,gpsWeekNum,gpsTimeOfApplicability,gpsRecords]=coder.const(@feval,'matlabshared.internal.gnss.readSEMAlmanac',file);
            end


            numSats=numel(gpsRecords);
        end
    end


    if isempty(coder.target)
        paramNames={'Name','OrbitPropagator','Viewer','CoordinateFrame','GPSWeekEpoch'};
    else
        paramNames={'Name','OrbitPropagator','CoordinateFrame','GPSWeekEpoch'};
    end
    pstruct=coder.internal.parseParameterInputs(paramNames,satelliteScenario.InputParserOptions,paramArgs{:});
    name=coder.internal.getParameterValue(pstruct.Name,'',paramArgs{:});
    orbitPropagator=coder.internal.getParameterValue(pstruct.OrbitPropagator,'',paramArgs{:});
    coordFrame=coder.internal.getParameterValue(pstruct.CoordinateFrame,'inertial',paramArgs{:});
    gpsWeekEpoch=coder.internal.getParameterValue(pstruct.GPSWeekEpoch,'',paramArgs{:});
    if isempty(coder.target)
        viewer=coder.internal.getParameterValue(pstruct.Viewer,scenario.Viewers,paramArgs{:});

        matlabshared.satellitescenario.ScenarioGraphic.validateViewerScenario(viewer,scenario);
    else
        viewer=0;
    end


    if strcmp(initMode,"keplerian")||strcmp(initMode,"file")||strcmp(initMode,"rinex")

        if pstruct.CoordinateFrame>0
            msg='shared_orbit:orbitPropagator:SatelliteScenarioCoordFrameProvidedForNonEphem';
            if isempty(coder.target)
                warning(message(msg,coordFrame));
            else
                coder.internal.compileWarning(msg,coordFrame);
            end
        end
    elseif(pstruct.OrbitPropagator>0)||(lower(orbitPropagator)~=""&&lower(orbitPropagator)~="ephemeris")

        if strcmp(initMode,"timetable")
            warnid='shared_orbit:orbitPropagator:SatelliteScenarioPropProvidedForTimeTable';
        else
            warnid='shared_orbit:orbitPropagator:SatelliteScenarioPropProvidedForTimeseries';
        end

        if isempty(coder.target)
            warning(message(warnid,orbitPropagator));
        else
            coder.internal.compileWarning(warnid,orbitPropagator);
        end
    end




    if isempty(coder.target)
        validateattributes(name,{'string','char','cell'},{},...
        'satellite','Name');
    else
        validateattributes(name,{'char','cell'},{},...
        'satellite','Name');
    end


    if~isempty(name)
        if isstring(name)


            validateattributes(name,{'string'},...
            {'vector','nonempty'},'satellite','Name');
            if~isscalar(name)
                validateattributes(name,{'string'},...
                {'numel',numSats},'satellite','Name');
            end


            formattedNames=cell(1,numSats);

            for idx=1:numSats


                if isscalar(name)
                    validateattributes(char(name),{'char'},...
                    {'nonempty'},'satellite','Name');


                    formattedNames{idx}=name;
                else
                    validateattributes(char(name(idx)),{'char'},...
                    {'nonempty'},'satellite','Name');


                    formattedNames{idx}=name(idx);
                end
            end
        elseif iscell(name)




            validateattributes(name,{'cell'},...
            {'vector','nonempty'},'satellite','Name');

            if~isscalar(name)
                validateattributes(name,{'cell'},...
                {'numel',numSats},'satellite','Name');
            end


            formattedNames=cell(1,numSats);

            for idx=1:numSats

                if isscalar(name)
                    extractedName=name{1};
                else
                    extractedName=name{idx};
                end


                validateattributes(extractedName,...
                {'char'},{'scalartext'},'satellite','Name');


                formattedNames{idx}=string(extractedName);


                validateattributes(char(formattedNames{idx}),{'char'},...
                {'nonempty'},'satellite','Name');
            end
        elseif ischar(name)



            validateattributes(name,{'char'},...
            {'nonempty'},'satellite','Name');


            convertedNames=string(name);


            formattedNames=cell(1,numSats);


            for idx=1:numSats
                formattedNames{idx}=convertedNames;
            end
        end
    else





        switch initMode
        case "keplerian"

            formattedNames=cell(1,numSats);
            for idx=1:numSats
                formattedNames{idx}="";
            end
        case "timetable"



            formattedNames=cell(1,numel(positionTable.Properties.VariableNames));
            for idx=1:numel(formattedNames)
                formattedNames{idx}=string(positionTable.Properties.VariableNames{idx});
            end
        case "timeseries"
            names=cellfun(@(x)x.Name,positionSeries,'UniformOutput',false);
            names=string(fillmissing(names,'constant','Satellite'));
            formattedNames=cell(1,numel(names));
            for idx=1:numel(names)
                formattedNames{idx}=names(idx);
            end
        case "rinex"


            formattedNames=cell(1,numSats);
            if isfield(rnx,'GPS')
                for idx=1:numGPSSats
                    prn=rnx.GPS.SatelliteID(idx);
                    formattedNames{idx}=string(sprintf('PRN:%.0f',prn));
                end
            end
            if isfield(rnx,'Galileo')
                for idx=1:numGalileoSats
                    prn=rnx.Galileo.SatelliteID(idx);
                    formattedNames{idx+numGPSSats}=string(sprintf('GAL Sat ID:%.0f',prn));
                end
            end
        otherwise
            if usingTLE


                formattedNames=cell(1,numSats);
                for idx=1:numSats
                    if strcmp(tleData(idx).Name,"UNKNOWN")



                        formattedNames{idx}=string(sprintf('%.0f',tleData(idx).SatelliteCatalogNumber));
                    else


                        formattedNames{idx}=tleData(idx).Name;
                    end
                end
            else


                formattedNames=cell(1,numSats);
                for idx=1:numSats
                    prn=gpsRecords(idx).PRNNumber;
                    formattedNames{idx}=string(sprintf('PRN:%.0f',prn));
                end
            end
        end
    end


    if initMode=="file"&&~usingTLE
        if isempty(gpsWeekEpoch)
            validateattributes(gpsWeekEpoch,{'char','string'},...
            {},...
            'satellite','GPSWeekEpoch');
        else
            validateattributes(gpsWeekEpoch,{'char','string'},...
            {'scalartext'},...
            'satellite','GPSWeekEpoch');
        end


        numGPSWeekNumRollOvers=0;%#ok<NASGU> 
        numGPSWeekNumRollOvers=getGPSWeekRollOvers(gpsWeekEpoch,scenario.StartTime);
        gpsWeekNum=gpsWeekNum+(numGPSWeekNumRollOvers*1024);
    end


    orbitPropagator=validatestring(orbitPropagator,...
    {'two-body-keplerian','sgp4','sdp4','gps','galileo',''},...
    'satellite','OrbitPropagator');


    if~isempty(coder.target)&&isempty(orbitPropagator)
        coder.internal.errorIf(true,'shared_orbit:orbitPropagator:OrbitPropagatorNotSpecified');
    end



    coder.internal.errorIf(strcmp(orbitPropagator,'gps')&&...
    ((~strcmp(initMode,"file")&&~strcmp(initMode,"rinex"))||...
    (strcmp(initMode,"file")&&usingTLE)||...
    (strcmp(initMode,"rinex")&&~validGPSMessage)),...
    'shared_orbit:orbitPropagator:InvalidInitializationForGPSPropagator');



    coder.internal.errorIf(strcmp(orbitPropagator,'galileo')&&...
    (~strcmp(initMode,"rinex")||...
    (strcmp(initMode,"rinex")&&~validGalileoMessage)),...
    'shared_orbit:orbitPropagator:InvalidInitializationForGalileoPropagator');




    coder.internal.errorIf((strcmp(orbitPropagator,'gps')||strcmp(orbitPropagator,'galileo'))&&...
    strcmp(initMode,"rinex")&&validGPSMessage&&validGalileoMessage,...
    'shared_orbit:orbitPropagator:InvalidInitializationForGPSGalileoPropagator');



    if strcmpi(initMode,'keplerian')&&(strcmpi(orbitPropagator,'sgp4')||...
        strcmpi(orbitPropagator,'sdp4')||strcmpi(orbitPropagator,''))
        coder.internal.errorIf(any(mod(inclination,2*pi)==pi),...
        'shared_orbit:orbitPropagator:InclinationAngle180');
    end


    coordFrame=validatestring(coordFrame,...
    {'inertial','ecef','geographic'},...
    'satellite','CoordinateFrame');



    existingSats=scenario.Satellites;


    checkDefaultTimes=false;
    switch initMode
    case "keplerian"

    case "timetable"

        if isdatetime(positionTable.Properties.StartTime)
            ephemEpoch=positionTable.Properties.StartTime;
            if isempty(coder.target)&&isempty(ephemEpoch.TimeZone)
                ephemEpoch.TimeZone='UTC';
            end
        else
            ephemEpoch=NaT;
        end
        checkDefaultTimes=true;
    case "timeseries"

        if~isempty(positionSeries{1}.TimeInfo.StartDate)


            ephemEpoch=datetime(positionSeries{1}.TimeInfo.StartDate,'Locale','en');
            if isempty(coder.target)&&isempty(ephemEpoch.TimeZone)
                ephemEpoch.TimeZone='UTC';
            end
        else
            ephemEpoch=datetime.empty;
        end
        checkDefaultTimes=true;
    case "rinex"
        if isfield(rnx,'GPS')&&validGPSMessage
            [~,idx]=min(rnx.GPS.Time);
            if coder.target('MATLAB')
                ephemGPS=matlabshared.internal.gnss.GPSTime.getLocalTime(rnx.GPS.GPSWeek(idx),rnx.GPS.Toe(idx),'UTC');
            else
                ephemGPS=matlabshared.internal.gnss.GPSTime.getLocalTime(rnx.GPS.GPSWeek(idx),rnx.GPS.Toe(idx));
            end
        else
            ephemGPS=NaT;
            if coder.target('MATLAB')
                ephemGPS.TimeZone='UTC';
            end
        end
        if isfield(rnx,'Galileo')&&validGalileoMessage
            [~,idx]=min(rnx.Galileo.Time);
            if coder.target('MATLAB')
                ephemGalileo=matlabshared.internal.gnss.GPSTime.getLocalTime(rnx.Galileo.GALWeek(idx),rnx.Galileo.Toe(idx),'UTC');
            else
                ephemGalileo=matlabshared.internal.gnss.GPSTime.getLocalTime(rnx.Galileo.GALWeek(idx),rnx.Galileo.Toe(idx));
            end
        else
            ephemGalileo=NaT;
            if coder.target('MATLAB')
                ephemGalileo.TimeZone='UTC';
            end
        end
        ephemEpoch=min([ephemGPS,ephemGalileo]);
        checkDefaultTimes=true;
    otherwise
        if usingTLE

            if isempty(coder.target)
                ephemEpoch=min([tleData.Epoch]);
            else
                ephemEpoch=tleData(1).Epoch;
                if numel(tleData)>1
                    for idx=2:numel(tleData)
                        if tleData(idx).Epoch<ephemEpoch
                            ephemEpoch=tleData(idx).Epoch;
                        end
                    end
                end
            end
            checkDefaultTimes=true;
        else


            ephemEpoch=NaT;%#ok<NASGU> 
            if coder.target('MATLAB')
                ephemEpoch=matlabshared.internal.gnss.GPSTime.getLocalTime(gpsWeekNum,gpsTimeOfApplicability,'UTC');
            else
                ephemEpoch=matlabshared.internal.gnss.GPSTime.getLocalTime(gpsWeekNum,gpsTimeOfApplicability);
            end
            checkDefaultTimes=true;
        end
    end


    if checkDefaultTimes&&scenario.UsingDefaultTimes


        needToUpdateStartTime=false;





        if~isnat(ephemEpoch)
            if isnat(scenario.EarliestProvidedEpoch)



                scenario.EarliestProvidedEpoch=ephemEpoch;


                needToUpdateStartTime=true;
            elseif ephemEpoch<scenario.EarliestProvidedEpoch



                scenario.EarliestProvidedEpoch=ephemEpoch;


                needToUpdateStartTime=true;
            end
        end


        if needToUpdateStartTime




            deltaStartTime=seconds(ephemEpoch-simulator.StartTime);


            simulator.StartTime=ephemEpoch;
















            simulator.StopTime=simulator.StopTime+seconds(deltaStartTime);
        end
    end


    if isempty(coder.target)
        scenarioHandle=scenario;
    else
        scenarioHandle=0;
    end


    switch initMode
    case "keplerian"


        args={formattedNames,...
        orbitPropagator,...
        simulator,...
        semiMajorAxis,...
        eccentricity,...
        inclination,...
        rightAscensionOfAscendingNode,...
        argumentOfPeriapsis,...
        trueAnomaly,...
        scenarioHandle};
    case "timetable"


        args={formattedNames,...
        "ephemeris",...
        simulator,...
        positionTable,...
        velocityTable,...
        coordFrame,...
        scenarioHandle};
    case "timeseries"


        args={formattedNames,...
        "ephemeris",...
        simulator,...
        positionSeries,...
        velocitySeries,...
        coordFrame,...
        scenarioHandle};
    case "rinex"
        gnssSystem=cell(1,numSats);
        weekNumber=cell(1,numSats);
        timeOfApplicability=cell(1,numSats);
        prnNumber=cell(1,numSats);
        svn=cell(1,numSats);
        averageURANumber=cell(1,numSats);
        eccentricity=cell(1,numSats);
        inclinationOffset=cell(1,numSats);
        rateOfInclination=cell(1,numSats);
        inclinationSineHarmonicCorrectionAmplitude=cell(1,numSats);
        inclinationCosineHarmonicCorrectionAmplitude=cell(1,numSats);
        orbitRadiusSineHarmonicCorrectionAmplitude=cell(1,numSats);
        orbitRadiusCosineHarmonicCorrectionAmplitude=cell(1,numSats);
        argumentOfLatitudeSineHarmonicCorrectionAmplitude=cell(1,numSats);
        argumentOfLatitudeCosineHarmonicCorrectionAmplitude=cell(1,numSats);
        rateOfRightAscension=cell(1,numSats);
        rateOfRightAscensionDifference=cell(1,numSats);
        sqrtOfSemiMajorAxis=cell(1,numSats);
        semiMajorAxisDifference=cell(1,numSats);
        rateOfSemiMajorAxis=cell(1,numSats);
        meanMotionDifference=cell(1,numSats);
        rateOfMeanMotionDifference=cell(1,numSats);
        geographicLongitudeOfOrbitalPlane=cell(1,numSats);
        argumentOfPerigee=cell(1,numSats);
        meanAnomaly=cell(1,numSats);
        zerothOrderClockCorrection=cell(1,numSats);
        firstOrderClockCorrection=cell(1,numSats);
        satelliteHealth=cell(1,numSats);
        satelliteConfiguration=cell(1,numSats);

        for idx=1:numGPSSats
            gnssSystem{idx}=uint8(0);
            weekNumber{idx}=rnx.GPS.GPSWeek(idx);
            timeOfApplicability{idx}=rnx.GPS.Toe(idx);
            prnNumber{idx}=rnx.GPS.SatelliteID(idx);
            svn{idx}=NaN;
            averageURANumber{idx}=rnx.GPS.SVAccuracy(idx);
            eccentricity{idx}=rnx.GPS.Eccentricity(idx);
            inclinationOffset{idx}=(rnx.GPS.i0(idx)-deg2rad(54))/pi;
            rateOfInclination{idx}=rnx.GPS.IDOT(idx)/pi;
            inclinationSineHarmonicCorrectionAmplitude{idx}=rnx.GPS.Cis(idx)/pi;
            inclinationCosineHarmonicCorrectionAmplitude{idx}=rnx.GPS.Cic(idx)/pi;
            orbitRadiusSineHarmonicCorrectionAmplitude{idx}=rnx.GPS.Crs(idx);
            orbitRadiusCosineHarmonicCorrectionAmplitude{idx}=rnx.GPS.Crc(idx);
            argumentOfLatitudeSineHarmonicCorrectionAmplitude{idx}=rnx.GPS.Cus(idx)/pi;
            argumentOfLatitudeCosineHarmonicCorrectionAmplitude{idx}=rnx.GPS.Cuc(idx)/pi;
            rateOfRightAscension{idx}=rnx.GPS.OMEGA_DOT(idx)/pi;
            rateOfRightAscensionDifference{idx}=0;
            sqrtOfSemiMajorAxis{idx}=rnx.GPS.sqrtA(idx);
            semiMajorAxisDifference{idx}=0;
            rateOfSemiMajorAxis{idx}=0;
            meanMotionDifference{idx}=rnx.GPS.Delta_n(idx)/pi;
            rateOfMeanMotionDifference{idx}=0;
            geographicLongitudeOfOrbitalPlane{idx}=rnx.GPS.OMEGA0(idx)/pi;
            argumentOfPerigee{idx}=rnx.GPS.omega(idx)/pi;
            meanAnomaly{idx}=rnx.GPS.M0(idx)/pi;
            zerothOrderClockCorrection{idx}=rnx.GPS.SVClockBias(idx);
            firstOrderClockCorrection{idx}=rnx.GPS.SVClockDrift(idx);
            satelliteHealth{idx}=rnx.GPS.SVHealth(idx);
            satelliteConfiguration{idx}=rnx.GPS.L2ChannelCodes(idx);
        end

        for idx=1:numGalileoSats
            gnssSystem{numGPSSats+idx}=uint8(1);
            weekNumber{numGPSSats+idx}=rnx.Galileo.GALWeek(idx);
            timeOfApplicability{numGPSSats+idx}=rnx.Galileo.Toe(idx);
            prnNumber{numGPSSats+idx}=rnx.Galileo.SatelliteID(idx);
            svn{numGPSSats+idx}=NaN;
            averageURANumber{numGPSSats+idx}=rnx.Galileo.SISAccuracy(idx);
            eccentricity{numGPSSats+idx}=rnx.Galileo.Eccentricity(idx);
            inclinationOffset{numGPSSats+idx}=(rnx.Galileo.i0(idx)-deg2rad(54))/pi;
            rateOfInclination{numGPSSats+idx}=rnx.Galileo.IDOT(idx)/pi;
            inclinationSineHarmonicCorrectionAmplitude{numGPSSats+idx}=rnx.Galileo.Cis(idx)/pi;
            inclinationCosineHarmonicCorrectionAmplitude{numGPSSats+idx}=rnx.Galileo.Cic(idx)/pi;
            orbitRadiusSineHarmonicCorrectionAmplitude{numGPSSats+idx}=rnx.Galileo.Crs(idx);
            orbitRadiusCosineHarmonicCorrectionAmplitude{numGPSSats+idx}=rnx.Galileo.Crc(idx);
            argumentOfLatitudeSineHarmonicCorrectionAmplitude{numGPSSats+idx}=rnx.Galileo.Cus(idx)/pi;
            argumentOfLatitudeCosineHarmonicCorrectionAmplitude{numGPSSats+idx}=rnx.Galileo.Cuc(idx)/pi;
            rateOfRightAscension{numGPSSats+idx}=rnx.Galileo.OMEGA_DOT(idx)/pi;
            rateOfRightAscensionDifference{numGPSSats+idx}=0;
            sqrtOfSemiMajorAxis{numGPSSats+idx}=rnx.Galileo.sqrtA(idx);
            semiMajorAxisDifference{numGPSSats+idx}=0;
            rateOfSemiMajorAxis{numGPSSats+idx}=0;
            meanMotionDifference{numGPSSats+idx}=rnx.Galileo.Delta_n(idx)/pi;
            rateOfMeanMotionDifference{numGPSSats+idx}=0;
            geographicLongitudeOfOrbitalPlane{numGPSSats+idx}=rnx.Galileo.OMEGA0(idx)/pi;
            argumentOfPerigee{numGPSSats+idx}=rnx.Galileo.omega(idx)/pi;
            meanAnomaly{numGPSSats+idx}=rnx.Galileo.M0(idx)/pi;
            zerothOrderClockCorrection{numGPSSats+idx}=rnx.Galileo.SVClockBias(idx);
            firstOrderClockCorrection{numGPSSats+idx}=rnx.Galileo.SVClockDrift(idx);
            satelliteHealth{numGPSSats+idx}=rnx.Galileo.SVHealth(idx);
            satelliteConfiguration{numGPSSats+idx}=rnx.Galileo.DataSources(idx);
        end

        gnssParameters=struct('GPSWeekNumber',weekNumber,...
        'GPSTimeOfApplicability',timeOfApplicability,...
        'GNSSSystem',gnssSystem);
        gnssRecords=generateGNSSRecords(prnNumber,svn,averageURANumber,...
        eccentricity,inclinationOffset,rateOfInclination,...
        inclinationSineHarmonicCorrectionAmplitude,...
        inclinationCosineHarmonicCorrectionAmplitude,...
        orbitRadiusSineHarmonicCorrectionAmplitude,...
        orbitRadiusCosineHarmonicCorrectionAmplitude,...
        argumentOfLatitudeSineHarmonicCorrectionAmplitude,...
        argumentOfLatitudeCosineHarmonicCorrectionAmplitude,...
        rateOfRightAscension,rateOfRightAscensionDifference,sqrtOfSemiMajorAxis,...
        semiMajorAxisDifference,rateOfSemiMajorAxis,meanMotionDifference,...
        rateOfMeanMotionDifference,geographicLongitudeOfOrbitalPlane,argumentOfPerigee,...
        meanAnomaly,zerothOrderClockCorrection,firstOrderClockCorrection,...
        satelliteHealth,satelliteConfiguration);

        args={formattedNames,...
        orbitPropagator,...
        simulator,...
        gnssParameters,...
        gnssRecords,...
        scenarioHandle};
    otherwise
        if usingTLE


            tleDataConditioned=struct('Epoch',{tleData.Epoch},...
            'BStar',{tleData.BStar},...
            'RightAscensionOfAscendingNode',{tleData.RightAscensionOfAscendingNode},...
            'Eccentricity',{tleData.Eccentricity},...
            'Inclination',{tleData.Inclination},...
            'ArgumentOfPeriapsis',{tleData.ArgumentOfPeriapsis},...
            'MeanAnomaly',{tleData.MeanAnomaly},...
            'MeanMotion',{tleData.MeanMotion});
            args={formattedNames,...
            orbitPropagator,...
            simulator,...
            tleDataConditioned,...
            scenarioHandle};
        else


            semAlmanacParameters.GPSWeekNumber=gpsWeekNum;
            semAlmanacParameters.GPSTimeOfApplicability=gpsTimeOfApplicability;
            semAlmanacParameters.GNSSSystem=uint8(0);

            prnNumber=cell(1,numSats);
            svn=cell(1,numSats);
            averageURANumber=cell(1,numSats);
            eccentricity=cell(1,numSats);
            inclinationOffset=cell(1,numSats);
            rateOfInclination=cell(1,numSats);
            inclinationSineHarmonicCorrectionAmplitude=cell(1,numSats);
            inclinationCosineHarmonicCorrectionAmplitude=cell(1,numSats);
            orbitRadiusSineHarmonicCorrectionAmplitude=cell(1,numSats);
            orbitRadiusCosineHarmonicCorrectionAmplitude=cell(1,numSats);
            argumentOfLatitudeSineHarmonicCorrectionAmplitude=cell(1,numSats);
            argumentOfLatitudeCosineHarmonicCorrectionAmplitude=cell(1,numSats);
            rateOfRightAscension=cell(1,numSats);
            rateOfRightAscensionDifference=cell(1,numSats);
            sqrtOfSemiMajorAxis=cell(1,numSats);
            semiMajorAxisDifference=cell(1,numSats);
            rateOfSemiMajorAxis=cell(1,numSats);
            meanMotionDifference=cell(1,numSats);
            rateOfMeanMotionDifference=cell(1,numSats);
            geographicLongitudeOfOrbitalPlane=cell(1,numSats);
            argumentOfPerigee=cell(1,numSats);
            meanAnomaly=cell(1,numSats);
            zerothOrderClockCorrection=cell(1,numSats);
            firstOrderClockCorrection=cell(1,numSats);
            satelliteHealth=cell(1,numSats);
            satelliteConfiguration=cell(1,numSats);

            for idx=1:numSats
                prnNumber{idx}=gpsRecords(idx).PRNNumber;
                svn{idx}=gpsRecords(idx).SVN;
                averageURANumber{idx}=gpsRecords(idx).AverageURANumber;
                eccentricity{idx}=gpsRecords(idx).Eccentricity;
                inclinationOffset{idx}=gpsRecords(idx).InclinationOffset;
                rateOfInclination{idx}=0;
                inclinationSineHarmonicCorrectionAmplitude{idx}=0;
                inclinationCosineHarmonicCorrectionAmplitude{idx}=0;
                orbitRadiusSineHarmonicCorrectionAmplitude{idx}=0;
                orbitRadiusCosineHarmonicCorrectionAmplitude{idx}=0;
                argumentOfLatitudeSineHarmonicCorrectionAmplitude{idx}=0;
                argumentOfLatitudeCosineHarmonicCorrectionAmplitude{idx}=0;
                rateOfRightAscension{idx}=gpsRecords(idx).RateOfRightAscension;
                rateOfRightAscensionDifference{idx}=0;
                sqrtOfSemiMajorAxis{idx}=gpsRecords(idx).SqrtOfSemiMajorAxis;
                semiMajorAxisDifference{idx}=0;
                rateOfSemiMajorAxis{idx}=0;
                meanMotionDifference{idx}=0;
                rateOfMeanMotionDifference{idx}=0;
                geographicLongitudeOfOrbitalPlane{idx}=gpsRecords(idx).GeographicLongitudeOfOrbitalPlane;
                argumentOfPerigee{idx}=gpsRecords(idx).ArgumentOfPerigee;
                meanAnomaly{idx}=gpsRecords(idx).MeanAnomaly;
                zerothOrderClockCorrection{idx}=gpsRecords(idx).ZerothOrderClockCorrection;
                firstOrderClockCorrection{idx}=gpsRecords(idx).FirstOrderClockCorrection;
                satelliteHealth{idx}=gpsRecords(idx).SatelliteHealth;
                satelliteConfiguration{idx}=gpsRecords(idx).SatelliteConfiguration;
            end

            gnssRecords=generateGNSSRecords(prnNumber,svn,averageURANumber,...
            eccentricity,inclinationOffset,rateOfInclination,...
            inclinationSineHarmonicCorrectionAmplitude,...
            inclinationCosineHarmonicCorrectionAmplitude,...
            orbitRadiusSineHarmonicCorrectionAmplitude,...
            orbitRadiusCosineHarmonicCorrectionAmplitude,...
            argumentOfLatitudeSineHarmonicCorrectionAmplitude,...
            argumentOfLatitudeCosineHarmonicCorrectionAmplitude,...
            rateOfRightAscension,rateOfRightAscensionDifference,sqrtOfSemiMajorAxis,...
            semiMajorAxisDifference,rateOfSemiMajorAxis,meanMotionDifference,...
            rateOfMeanMotionDifference,geographicLongitudeOfOrbitalPlane,argumentOfPerigee,...
            meanAnomaly,zerothOrderClockCorrection,firstOrderClockCorrection,...
            satelliteHealth,satelliteConfiguration);

            args={formattedNames,...
            orbitPropagator,...
            simulator,...
            semAlmanacParameters,...
            gnssRecords,...
            scenarioHandle};
        end
    end


    if isempty(coder.target)
        try
            sats=matlabshared.satellitescenario.Satellite(args{:});
        catch ME



            restoreScenario(scenario,originalStartTime,originalStopTime,...
            originalSampleTime,originalTime,originalUsingDefaultTimes,...
            originalEarliestProvidedEpoch);


            throwExceptions(ME)
        end
    else
        sats=matlabshared.satellitescenario.Satellite(args{:});
    end



    if scenario.UsingDefaultTimes


        satHandles=sats.Handles;
        for idx=1:numSats
            switch satHandles{idx}.OrbitPropagator
            case "two-body-keplerian"
                standardGravitationalParameter=...
                matlabshared.orbit.internal.OrbitPropagationModel.StandardGravitationalParameter;
                elements=info(satHandles{idx}.PropagatorTBK);

                if isfield(elements,'SemiMajorAxis')
                    semiMajorAxis=elements.SemiMajorAxis;
                else
                    semiMajorAxis=10000000;
                end
                period=2*pi*sqrt((semiMajorAxis^3)/standardGravitationalParameter);

                if period>seconds(simulator.StopTime-simulator.StartTime)


                    simulator.StopTime=...
                    simulator.StartTime+seconds(period);



                    simulator.SampleTime=...
                    seconds(simulator.StopTime-simulator.StartTime)/...
                    (scenario.DefaultNumSamples-1);
                end
            case{"sgp4"}
                elements=info(satHandles{idx}.PropagatorSGP4);

                if isfield(elements,'Period')
                    period=elements.Period;
                else
                    period=7200;
                end

                if period>seconds(simulator.StopTime-simulator.StartTime)


                    simulator.StopTime=...
                    simulator.StartTime+seconds(period);



                    simulator.SampleTime=...
                    seconds(simulator.StopTime-simulator.StartTime)/...
                    (scenario.DefaultNumSamples-1);
                end
            case{"sdp4"}
                elements=info(satHandles{idx}.PropagatorSDP4);

                if isfield(elements,'Period')
                    period=elements.Period;
                else
                    period=7200;
                end

                if period>seconds(simulator.StopTime-simulator.StartTime)


                    simulator.StopTime=...
                    simulator.StartTime+seconds(period);



                    simulator.SampleTime=...
                    seconds(simulator.StopTime-simulator.StartTime)/...
                    (scenario.DefaultNumSamples-1);
                end
            case "ephemeris"
                elements=info(satHandles{idx}.PropagatorEphemeris);
                if isfield(elements,'StopTime')
                    ephemerisStopTime=elements.StopTime;
                else
                    ephemerisStopTime=simulator.StopTime;
                end
                if isempty(coder.target)&&ephemerisStopTime>simulator.StopTime


                    simulator.StopTime=ephemerisStopTime;







                    simulator.SampleTime=60;
                end

            otherwise
                elements=info(satHandles{idx}.PropagatorGPS);
                period=elements.Period;

                if period>seconds(simulator.StopTime-simulator.StartTime)


                    simulator.StopTime=...
                    simulator.StartTime+seconds(period);



                    simulator.SampleTime=...
                    seconds(simulator.StopTime-simulator.StartTime)/...
                    (scenario.DefaultNumSamples-1);
                end
            end

            if isempty(coder.target)


                satHandles{idx}.GroundTrack.initializeLeadTrailTime(satHandles{idx});
            end
        end
    end


    if isempty(coder.target)
        try
            advance(simulator,simulator.StartTime);
        catch ME



            scenario.Satellites=[existingSats,sats];
            delete(sats);




            restoreScenario(scenario,originalStartTime,originalStopTime,...
            originalSampleTime,originalTime,originalUsingDefaultTimes,...
            originalEarliestProvidedEpoch);


            throwExceptions(ME)
        end
    else
        advance(simulator,simulator.StartTime);
    end

    if scenario.UsingDefaultTimes&&isempty(coder.target)

        scenario.updateTimeline(simulator.StartTime,simulator.StopTime);
    end


    if isempty(existingSats)||~scenario.pSatellitesAddedBefore
        scenario.Satellites=sats;
        scenario.pSatellitesAddedBefore=true;
    else
        scenario.Satellites=[existingSats,sats];
    end



    simulator.NeedToSimulate=true;

    if coder.target('MATLAB')
        scenario.addToScenarioGraphics(sats);

        scenario.NeedToSimulate=true;



        for k=1:numel(viewer)
            if~viewer(k).ShowDetails
                satHandles=sats.Handles;
                for k2=1:numSats
                    satHandles{k2}.pShowLabel=false;
                end
            end
        end


        showIfAutoShow(sats,scenario,viewer);
    end
end

function restoreScenario(scenario,originalStartTime,originalStopTime,...
    originalSampleTime,originalTime,originalUsingDefaultTimes,...
    originalEarliestProvidedEpoch)



    scenario.StartTime=originalStartTime;
    scenario.StopTime=originalStopTime;
    scenario.SampleTime=originalSampleTime;
    scenario.Simulator.Time=originalTime;
    scenario.UsingDefaultTimes=originalUsingDefaultTimes;
    scenario.EarliestProvidedEpoch=originalEarliestProvidedEpoch;
end

function restoreSatsInSimulator(simulator,sats)



    for idx=1:numel(sats)
        simulator.NumSatellites=simulator.NumSatellites-1;
        if simulator.NumSatellites~=0
            simulator.Satellites([simulator.Satellites.ID]==sats(idx).SimulatorID)=[];
        end
    end
end

function throwExceptions(ME)



    switch ME.identifier
    case{'shared_orbit:orbitPropagator:TwoBodyKeplerianEarthCollisionTrajectory',...
        'shared_orbit:orbitPropagator:SGP4SDP4EarthCollisionTrajectory'}
        msg=message('shared_orbit:orbitPropagator:SatelliteScenarioEarthCollisionTrajectory');
        error(msg);
    case 'shared_orbit:orbitPropagator:TwoBodyKeplerianEscapeTrajectory'
        msg=message('shared_orbit:orbitPropagator:SatelliteScenarioEscapeTrajectory');
        error(msg);
    otherwise
        msg=message('shared_orbit:orbitPropagator:SatelliteScenarioUnableAddSatellite');
        baseException=MException(msg);
        baseException=addCause(baseException,ME);
        throw(baseException);
    end
end

function numGPSWeekNumRollOvers=getGPSWeekRollOvers(gpsWeekEpoch,scenarioStartTime)

    scenarioStartTime.TimeZone='UTC';
    gpsStartTime=matlabshared.internal.gnss.GPSTime.getLocalTime(0,0,'UTCLeapSeconds');

    if isempty(gpsWeekEpoch)
        gpsStartTime.TimeZone='UTC';
        numGPSWeekNumRollOvers=0;
        while(gpsStartTime<scenarioStartTime)
            numGPSWeekNumRollOvers=numGPSWeekNumRollOvers+1;
            gpsStartTime.TimeZone='UTCLeapSeconds';
            gpsStartTime=gpsStartTime+days(7*1024);
            gpsStartTime.TimeZone='UTC';
        end
        numGPSWeekNumRollOvers=numGPSWeekNumRollOvers-1;
    else
        gpsWeekNumEpoch=datetime(gpsWeekEpoch,'InputFormat','dd-MMM-yyyy','Locale','en_US');
        gpsWeekNumEpoch.TimeZone='UTCLeapSeconds';
        numWeeks=ceil(days(gpsWeekNumEpoch-gpsStartTime)/7);
        if mod(numWeeks,1024)~=0
            msg='shared_orbit:orbitPropagator:InvalidGPSWeekEpoch';
            if isempty(coder.target)
                error(message(msg));
            else
                coder.internal.error(msg);
            end
        end
        numGPSWeekNumRollOvers=numWeeks/1024;
    end
end

function[rnx,validGPSMessage,validGalileoMessage]=...
    mergeRINEXData(rnx,usingDefaultTimes,startTime)




    [validGPSMessage,validGalileoMessage]=validateRINEXData(rnx);


    if validGPSMessage
        gps=sortrows(rnx.GPS,{'SatelliteID','Time'});
        gps=mergeGNSSData(gps,usingDefaultTimes,startTime,true);
        rnx.GPS=gps;
    end


    if validGalileoMessage
        galileo=sortrows(rnx.Galileo,{'SatelliteID','Time'});
        galileo=mergeGNSSData(galileo,usingDefaultTimes,startTime,false);
        rnx.Galileo=galileo;
    end
end

function gnss=mergeGNSSData(gnss,usingDefaultTimes,startTime,isGPS)




    currentSatelliteID=nan;


    if coder.target('MATLAB')
        startTime.TimeZone='';
    end


    idToDelete=[];




    minDeltaToStartTime=inf;



    minDeltaToStartTimeID=0;


    if isGPS
        weekNum=gnss.GPSWeek;
    else
        weekNum=gnss.GALWeek;
    end
    toe=gnss.Toe;
    times=matlabshared.internal.gnss.GPSTime.getLocalTime(0,0,'UTCLeapSeconds')+...
    days(weekNum*7)+seconds(toe);
    times.TimeZone='';



    for idx=1:size(gnss,1)
        if gnss.SatelliteID(idx)==currentSatelliteID
            if usingDefaultTimes
                idToDelete=[idToDelete,idx];
            else
                deltaToStartTime=abs(seconds(times(idx)-startTime));
                if deltaToStartTime>=minDeltaToStartTime
                    idToDelete=[idToDelete,idx];
                else
                    if minDeltaToStartTimeID~=0
                        idToDelete=[idToDelete,minDeltaToStartTimeID];
                    end
                    minDeltaToStartTime=deltaToStartTime;
                    minDeltaToStartTimeID=idx;
                end
            end
        elseif~usingDefaultTimes
            minDeltaToStartTime=abs(seconds(times(idx)-startTime));
            minDeltaToStartTimeID=idx;
        end
        currentSatelliteID=gnss.SatelliteID(idx);
    end
    gnss(idToDelete,:)=[];
end

function[validGPSMessage,validGalileoMessage]=validateRINEXData(rnx)



    if isfield(rnx,'GPS')
        validGPSMessage=validateGPSMessage(rnx.GPS);
    else
        validGPSMessage=false;
    end


    if isfield(rnx,'Galileo')
        validGalileoMessage=validateGalileoMessage(rnx.Galileo);
    else
        validGalileoMessage=false;
    end



    coder.internal.errorIf(~validGPSMessage&&~validGalileoMessage,...
    'shared_orbit:orbitPropagator:NoRINEXGPSOrGalileoNavigationMessage');



    if coder.target('MATLAB')
        msgID='shared_orbit:orbitPropagator:InvalidRINEXGNSSMessage';
        if isfield(rnx,'GPS')&&~validGPSMessage
            msg=message(msgID,'GPS');
            warning(msg);
        elseif isfield(rnx,'Galileo')&&~validGalileoMessage
            msg=message(msgID,'Galileo');
            warning(msg);
        end
    end



    f=fields(rnx);
    otherGNSSSystemsPresent=~isempty(find(~(strcmp(f,'GPS')|strcmp(f,'Galileo')),1));
    if coder.target('MATLAB')&&otherGNSSSystemsPresent
        warning(message('shared_orbit:orbitPropagator:RINEXNonGPSGalileoSystem'));
    end
end

function validGPSMessage=validateGPSMessage(gpsData)



    validGPSMessage=false;


    if~isa(gpsData,'timetable')
        return
    end


    if isempty(find(strcmp(gpsData.Properties.VariableNames,'GPSWeek'),1))||...
        isempty(find(strcmp(gpsData.Properties.VariableNames,'Toe'),1))||...
        isempty(find(strcmp(gpsData.Properties.VariableNames,'SatelliteID'),1))||...
        isempty(find(strcmp(gpsData.Properties.VariableNames,'SVAccuracy'),1))||...
        isempty(find(strcmp(gpsData.Properties.VariableNames,'Eccentricity'),1))||...
        isempty(find(strcmp(gpsData.Properties.VariableNames,'i0'),1))||...
        isempty(find(strcmp(gpsData.Properties.VariableNames,'IDOT'),1))||...
        isempty(find(strcmp(gpsData.Properties.VariableNames,'Cis'),1))||...
        isempty(find(strcmp(gpsData.Properties.VariableNames,'Cic'),1))||...
        isempty(find(strcmp(gpsData.Properties.VariableNames,'Crs'),1))||...
        isempty(find(strcmp(gpsData.Properties.VariableNames,'Crc'),1))||...
        isempty(find(strcmp(gpsData.Properties.VariableNames,'Cus'),1))||...
        isempty(find(strcmp(gpsData.Properties.VariableNames,'Cuc'),1))||...
        isempty(find(strcmp(gpsData.Properties.VariableNames,'OMEGA_DOT'),1))||...
        isempty(find(strcmp(gpsData.Properties.VariableNames,'sqrtA'),1))||...
        isempty(find(strcmp(gpsData.Properties.VariableNames,'Delta_n'),1))||...
        isempty(find(strcmp(gpsData.Properties.VariableNames,'OMEGA0'),1))||...
        isempty(find(strcmp(gpsData.Properties.VariableNames,'omega'),1))||...
        isempty(find(strcmp(gpsData.Properties.VariableNames,'M0'),1))||...
        isempty(find(strcmp(gpsData.Properties.VariableNames,'SVClockBias'),1))||...
        isempty(find(strcmp(gpsData.Properties.VariableNames,'SVClockDrift'),1))||...
        isempty(find(strcmp(gpsData.Properties.VariableNames,'SVHealth'),1))||...
        isempty(find(strcmp(gpsData.Properties.VariableNames,'L2ChannelCodes'),1))
        return
    end


    if coder.target('MATLAB')
        try
            numTime=numel(gpsData.Time);
            validateattributes(gpsData.Time,...
            {'datetime'},{'nonempty','finite','ncols',1});
            validateattributes(gpsData.GPSWeek,...
            {'double'},{'nonempty','real','finite','ncols',1,'integer','nonnegative','numel',numTime});
            validateattributes(gpsData.Toe,...
            {'double'},{'nonempty','real','finite','ncols',1,'nonnegative','numel',numTime});
            validateattributes(gpsData.SatelliteID,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(gpsData.SVAccuracy,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(gpsData.Eccentricity,...
            {'double'},{'nonempty','real','finite','ncols',1,'nonnegative','<',1,'numel',numTime});
            validateattributes(gpsData.i0,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(gpsData.IDOT,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(gpsData.Cis,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(gpsData.Cic,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(gpsData.Crs,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(gpsData.Crc,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(gpsData.Cus,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(gpsData.Cuc,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(gpsData.OMEGA_DOT,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(gpsData.sqrtA,...
            {'double'},{'nonempty','real','finite','ncols',1,'positive','numel',numTime});
            validateattributes(gpsData.Delta_n,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(gpsData.OMEGA0,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(gpsData.omega,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(gpsData.M0,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(gpsData.SVClockBias,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(gpsData.SVClockDrift,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(gpsData.SVHealth,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(gpsData.L2ChannelCodes,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
        catch
            return
        end
    end



    validGPSMessage=true;
end

function validGalileoMessage=validateGalileoMessage(galileoData)



    validGalileoMessage=false;


    if~isa(galileoData,'timetable')
        return
    end


    if isempty(find(strcmp(galileoData.Properties.VariableNames,'GALWeek'),1))||...
        isempty(find(strcmp(galileoData.Properties.VariableNames,'Toe'),1))||...
        isempty(find(strcmp(galileoData.Properties.VariableNames,'SatelliteID'),1))||...
        isempty(find(strcmp(galileoData.Properties.VariableNames,'SISAccuracy'),1))||...
        isempty(find(strcmp(galileoData.Properties.VariableNames,'Eccentricity'),1))||...
        isempty(find(strcmp(galileoData.Properties.VariableNames,'i0'),1))||...
        isempty(find(strcmp(galileoData.Properties.VariableNames,'IDOT'),1))||...
        isempty(find(strcmp(galileoData.Properties.VariableNames,'Cis'),1))||...
        isempty(find(strcmp(galileoData.Properties.VariableNames,'Cic'),1))||...
        isempty(find(strcmp(galileoData.Properties.VariableNames,'Crs'),1))||...
        isempty(find(strcmp(galileoData.Properties.VariableNames,'Crc'),1))||...
        isempty(find(strcmp(galileoData.Properties.VariableNames,'Cus'),1))||...
        isempty(find(strcmp(galileoData.Properties.VariableNames,'Cuc'),1))||...
        isempty(find(strcmp(galileoData.Properties.VariableNames,'OMEGA_DOT'),1))||...
        isempty(find(strcmp(galileoData.Properties.VariableNames,'sqrtA'),1))||...
        isempty(find(strcmp(galileoData.Properties.VariableNames,'Delta_n'),1))||...
        isempty(find(strcmp(galileoData.Properties.VariableNames,'OMEGA0'),1))||...
        isempty(find(strcmp(galileoData.Properties.VariableNames,'omega'),1))||...
        isempty(find(strcmp(galileoData.Properties.VariableNames,'M0'),1))||...
        isempty(find(strcmp(galileoData.Properties.VariableNames,'SVClockBias'),1))||...
        isempty(find(strcmp(galileoData.Properties.VariableNames,'SVClockDrift'),1))||...
        isempty(find(strcmp(galileoData.Properties.VariableNames,'SVHealth'),1))||...
        isempty(find(strcmp(galileoData.Properties.VariableNames,'DataSources'),1))
        return
    end


    if coder.target('MATLAB')
        try
            numTime=numel(galileoData.Time);
            validateattributes(galileoData.Time,...
            {'datetime'},{'nonempty','finite','ncols',1});
            validateattributes(galileoData.GALWeek,...
            {'double'},{'nonempty','real','finite','ncols',1,'integer','nonnegative','numel',numTime});
            validateattributes(galileoData.Toe,...
            {'double'},{'nonempty','real','finite','ncols',1,'nonnegative','numel',numTime});
            validateattributes(galileoData.SatelliteID,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(galileoData.SISAccuracy,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(galileoData.Eccentricity,...
            {'double'},{'nonempty','real','finite','ncols',1,'nonnegative','<',1,'numel',numTime});
            validateattributes(galileoData.i0,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(galileoData.IDOT,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(galileoData.Cis,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(galileoData.Cic,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(galileoData.Crs,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(galileoData.Crc,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(galileoData.Cus,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(galileoData.Cuc,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(galileoData.OMEGA_DOT,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(galileoData.sqrtA,...
            {'double'},{'nonempty','real','finite','ncols',1,'positive','numel',numTime});
            validateattributes(galileoData.Delta_n,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(galileoData.OMEGA0,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(galileoData.omega,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(galileoData.M0,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(galileoData.SVClockBias,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(galileoData.SVClockDrift,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(galileoData.SVHealth,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
            validateattributes(galileoData.DataSources,...
            {'double'},{'nonempty','real','finite','ncols',1,'numel',numTime});
        catch
            return
        end
    end



    validGalileoMessage=true;
end

function gnssRecords=generateGNSSRecords(prnNumber,svn,averageURANumber,...
    eccentricity,inclinationOffset,rateOfInclination,...
    inclinationSineHarmonicCorrectionAmplitude,...
    inclinationCosineHarmonicCorrectionAmplitude,...
    orbitRadiusSineHarmonicCorrectionAmplitude,...
    orbitRadiusCosineHarmonicCorrectionAmplitude,...
    argumentOfLatitudeSineHarmonicCorrectionAmplitude,...
    argumentOfLatitudeCosineHarmonicCorrectionAmplitude,...
    rateOfRightAscension,rateOfRightAscensionDifference,sqrtOfSemiMajorAxis,...
    semiMajorAxisDifference,rateOfSemiMajorAxis,meanMotionDifference,...
    rateOfMeanMotionDifference,geographicLongitudeOfOrbitalPlane,argumentOfPerigee,...
    meanAnomaly,zerothOrderClockCorrection,firstOrderClockCorrection,...
    satelliteHealth,satelliteConfiguration)


    gnssRecords=struct('PRNNumber',prnNumber,...
    'SVN',svn,...
    'AverageURANumber',averageURANumber,...
    'Eccentricity',eccentricity,...
    'InclinationOffset',inclinationOffset,...
    'RateOfInclination',rateOfInclination,...
    'InclinationSineHarmonicCorrectionAmplitude',inclinationSineHarmonicCorrectionAmplitude,...
    'InclinationCosineHarmonicCorrectionAmplitude',inclinationCosineHarmonicCorrectionAmplitude,...
    'OrbitRadiusSineHarmonicCorrectionAmplitude',orbitRadiusSineHarmonicCorrectionAmplitude,...
    'OrbitRadiusCosineHarmonicCorrectionAmplitude',orbitRadiusCosineHarmonicCorrectionAmplitude,...
    'ArgumentOfLatitudeSineHarmonicCorrectionAmplitude',argumentOfLatitudeSineHarmonicCorrectionAmplitude,...
    'ArgumentOfLatitudeCosineHarmonicCorrectionAmplitude',argumentOfLatitudeCosineHarmonicCorrectionAmplitude,...
    'RateOfRightAscension',rateOfRightAscension,...
    'RateOfRightAscensionDifference',rateOfRightAscensionDifference,...
    'SqrtOfSemiMajorAxis',sqrtOfSemiMajorAxis,...
    'SemiMajorAxisDifference',semiMajorAxisDifference,...
    'RateOfSemiMajorAxis',rateOfSemiMajorAxis,...
    'MeanMotionDifference',meanMotionDifference,...
    'RateOfMeanMotionDifference',rateOfMeanMotionDifference,...
    'GeographicLongitudeOfOrbitalPlane',geographicLongitudeOfOrbitalPlane,...
    'ArgumentOfPerigee',argumentOfPerigee,...
    'MeanAnomaly',meanAnomaly,...
    'ZerothOrderClockCorrection',zerothOrderClockCorrection,...
    'FirstOrderClockCorrection',firstOrderClockCorrection,...
    'SatelliteHealth',satelliteHealth,...
    'SatelliteConfiguration',satelliteConfiguration);
end




