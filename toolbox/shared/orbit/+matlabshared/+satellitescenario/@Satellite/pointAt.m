function pointAt(sat,target,varargin)%#codegen






























































































































































































































































    coder.allowpcode('plain');


    validateattributes(sat,{'matlabshared.satellitescenario.Satellite'},{'nonempty','vector'},...
    'pointAt','SAT',1);


    numSat=numel(sat);

    if isempty(coder.target)

        if~all(isvalid(sat))
            msg=message(...
            'shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject',...
            'SAT');
            error(msg);
        end
    end


    simulator=sat(1).Simulator;



    coder.internal.errorIf(simulator.SimulationMode==1&&simulator.SimulationStatus==2,...
    'shared_orbit:orbitPropagator:UnablePointAtIncorrectSimStatus');

    if isempty(coder.target)

        if~all([sat.Simulator]==simulator)
            msg=message(...
            'shared_orbit:orbitPropagator:InputsDifferentSatelliteScenario');
            error(msg);
        end
    end


    validateattributes(target,{'matlabshared.satellitescenario.Satellite',...
    'matlabshared.satellitescenario.GroundStation','double','char',...
    'string','table','timetable','timeseries'},{},'pointAt','TARGET',2);


    pstruct=coder.internal.parseParameterInputs({'CoordinateFrame','ExtrapolationMethod',"Format"},satelliteScenario.InputParserOptions,varargin{:});
    coordFrame=coder.internal.getParameterValue(pstruct.CoordinateFrame,'inertial',varargin{:});
    coordFrame=validatestring(coordFrame,...
    {'inertial','ecef','ned'},...
    'pointAt','CoordinateFrame');
    defaultAtt=coder.internal.getParameterValue(pstruct.ExtrapolationMethod,'nadir',varargin{:});
    defaultAtt=validatestring(defaultAtt,...
    {'nadir','fixed'},...
    'pointAt','ExtrapolationMethod');
    attFormat=coder.internal.getParameterValue(pstruct.Format,'quaternion',varargin{:});
    attFormat=validatestring(attFormat,...
    {'quaternion','euler'},...
    'pointAt','Format');

    if~isa(target,'timetable')&&~isa(target,'table')&&~isa(target,'timeseries')
        if pstruct.CoordinateFrame>0
            msg='shared_orbit:orbitPropagator:SatelliteScenarioNVPairProvidedForNonCustom';
            if isempty(coder.target)
                warning(message(msg,"CoordinateFrame"));
            else
                coder.internal.compileWarning(msg,"CoordinateFrame");
            end
        end
        if pstruct.ExtrapolationMethod>0
            msg='shared_orbit:orbitPropagator:SatelliteScenarioNVPairProvidedForNonCustom';
            if isempty(coder.target)
                warning(message(msg,"ExtrapolationMethod"));
            else
                coder.internal.compileWarning(msg,"ExtrapolationMethod");
            end
        end
        if pstruct.Format>0
            msg='shared_orbit:orbitPropagator:SatelliteScenarioNVPairProvidedForNonCustom';
            if isempty(coder.target)
                warning(message(msg,"Format"));
            else
                coder.internal.compileWarning(msg,"Format");
            end
        end
    else
        if pstruct.ExtrapolationMethod==0


            defaultAtt='default';
        end
    end

    if isa(target,'matlabshared.satellitescenario.Satellite')||...
        isa(target,'matlabshared.satellitescenario.GroundStation')


        validateattributes(target,{'matlabshared.satellitescenario.Satellite',...
        'matlabshared.satellitescenario.GroundStation'},{'nonempty','vector'},'pointAt','TARGET');



        if~isscalar(target)
            validateattributes(target,{'matlabshared.satellitescenario.Satellite',...
            'matlabshared.satellitescenario.GroundStation'},{'numel',numSat},'pointAt','TARGET');
        end
        if isempty(coder.target)

            if~all(isvalid(target))
                msg=message(...
                'shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject',...
                'TARGET');
                error(msg);
            end


            if~all([target.Simulator]==simulator)
                msg=message(...
                'shared_orbit:orbitPropagator:InputsDifferentSatelliteScenario');
                error(msg);
            end
        end


        msg='shared_orbit:orbitPropagator:SatelliteScenarioPointAtInvalidTarget';
        for idx=1:numSat
            coder.internal.errorIf((isscalar(target)&&target==sat(idx))||(~isscalar(target)&&target(idx)==sat(idx)),msg);
        end
    elseif isa(target,'double')



        validateattributes(target,{'double'},...
        {'nonempty','real','finite','2d'},...
        'pointAt','TARGET');
        if isvector(target)
            validateattributes(target,{'double'},...
            {'numel',3},...
            'pointAt','TARGET');
            validateattributes(target(1),{'double'},...
            {'>=',-90,'<=',90},'pointAt','TARGET latitude');


            if(target(2)>180)||(target(2)<=-180)
                target(2)=mod(target(2),360);
                if target(2)>180
                    target(2)=target(2)-360;
                end
            end
        else
            validateattributes(target,{'double'},...
            {'nrows',3,'ncols',numSat},...
            'pointAt','TARGET');
            validateattributes(target(1,:),{'double'},...
            {'>=',-90,'<=',90},'pointAt','TARGET latitude');


            indexLonOutside180=(target(2,:)>180)|(target(2,:)<=-180);
            target(2,indexLonOutside180)=mod(target(2,indexLonOutside180),360);
            indexLonGreaterThan180=target(2,:)>180;
            target(2,indexLonGreaterThan180)=target(2,indexLonGreaterThan180)-360;
        end
    elseif isa(target,'timetable')||isa(target,'table')
        if~isempty(coder.target)


            coder.internal.errorIf(true,'shared_orbit:orbitPropagator:CustomAttitudeNotSupportedForCodegen');
        end

        if istable(target)
            target=table2timetable(target);
        end

        if~isdatetime(target.Properties.StartTime)


            target.Properties.StartTime=target.Properties.StartTime...
            +sat(1).Scenario.StartTime;
        end
        if isempty(target.Properties.RowTimes.TimeZone)&&isempty(coder.target)
            target.Properties.RowTimes.TimeZone='UTC';
        end



        switch attFormat
        case "quaternion"
            target=matlabshared.orbit.internal.processMultiDimTTintoTT(target,4);
        case "euler"
            target=matlabshared.orbit.internal.processMultiDimTTintoTT(target,3);
        end


        uniqueTimes=sort(unique(target.Properties.RowTimes));
        target=retime(target,uniqueTimes,'firstvalue');

        validateattributes(target.Properties.VariableNames,{'cell'},{'numel',numSat},...
        'pointAt','TARGET');

    elseif isa(target,'timeseries')
        if~isempty(coder.target)


            coder.internal.errorIf(true,'shared_orbit:orbitPropagator:CustomAttitudeNotSupportedForCodegen');
        end
        validateattributes(target.Data,{'numeric'},...
        {'nonempty','real','finite','3d'},...
        'pointAt','ATTITUDETIMESERIES');

        switch attFormat
        case "quaternion"
            target=matlabshared.orbit.internal.processMultiDimTSintoCellArrayOfTS(target,4);
        case "euler"
            target=matlabshared.orbit.internal.processMultiDimTSintoCellArrayOfTS(target,3);
        end


        validateattributes(target,{'cell'},{'numel',numSat},...
        'pointAt','TARGET');
        for tgtIdx=1:numel(target)
            if~isdatetime(target{tgtIdx}.TimeInfo.StartDate)

                target{tgtIdx}.TimeInfo.StartDate=sat(1).Scenario.StartTime;
            end

            target{tgtIdx}=timetable(...
            datetime(target{tgtIdx}.getabstime,'Locale','en'),...
            target{tgtIdx}.Data);
            if isempty(target{tgtIdx}.Properties.RowTimes.TimeZone)&&isempty(coder.target)
                target{tgtIdx}.Properties.RowTimes.TimeZone='UTC';
            end

            uniqueTimes=sort(unique(target{tgtIdx}.Properties.RowTimes));
            target{tgtIdx}=retime(target{tgtIdx},uniqueTimes,'firstvalue');
        end
        target=synchronize(target{:});
    else

        if coder.target('MATLAB')
            target=validatestring(target,"nadir");
        else
            validatestring(target,"nadir","pointAt");
        end
    end




    pointingTargetChanged=false;
    for idx=1:numSat

        originalPointingTarget=sat(idx).PointingTarget;



        satSimIndex=getIdxInSimulatorStruct(sat(idx));


        if isa(target,'matlabshared.satellitescenario.Satellite')



            if isscalar(target)
                targetSimID=target.SimulatorID;
            else
                targetSimID=target(idx).SimulatorID;
            end
            newPointingTarget=targetSimID;
            simulator.Satellites(satSimIndex).PointingMode=1;
            simulator.Satellites(satSimIndex).PointingTargetID=targetSimID;
            sat(idx).PointingTarget=targetSimID;
        elseif isa(target,'matlabshared.satellitescenario.GroundStation')



            if isscalar(target)
                targetSimID=target.SimulatorID;
            else
                targetSimID=target(idx).SimulatorID;
            end
            newPointingTarget=targetSimID;
            simulator.Satellites(satSimIndex).PointingMode=2;
            simulator.Satellites(satSimIndex).PointingTargetID=targetSimID;
            sat(idx).PointingTarget=targetSimID;
        elseif isa(target,'double')




            simulator.Satellites(satSimIndex).PointingMode=3;
            if isvector(target)
                pointingCoordinates=matlabshared.orbit.internal.Transforms.geographic2itrf(...
                [target(1)*pi/180;target(2)*pi/180;target(3)]);
            else
                pointingCoordinates=matlabshared.orbit.internal.Transforms.geographic2itrf(...
                [target(1,idx)*pi/180;target(2,idx)*pi/180;target(3,idx)]);
            end
            newPointingTarget=pointingCoordinates;
            simulator.Satellites(satSimIndex).PointingCoordinates=...
            pointingCoordinates;
            if isvector(target)
                sat(idx).PointingTarget=reshape(target,3,[]);
            else
                sat(idx).PointingTarget=target(:,idx);
            end
        elseif isa(target,'timetable')




            newPointingTarget=-3;
            simulator.Satellites(satSimIndex).PointingMode=5;
            simulator.Satellites(satSimIndex).CustomAttitude=target(:,idx);
            simulator.Satellites(satSimIndex).CustomAttitudeDefault=defaultAtt;
            simulator.Satellites(satSimIndex).CustomAttitudeCoordFrame=coordFrame;
            simulator.Satellites(satSimIndex).CustomAttitudeFormat=attFormat;
            sat(idx).PointingTarget=-3;

            pointingTargetChanged=true;
        else



            newPointingTarget=-1;
            simulator.Satellites(satSimIndex).PointingMode=4;
            sat(idx).PointingTarget=-1;
        end


        if~pointingTargetChanged&&~isequal(originalPointingTarget,newPointingTarget)
            pointingTargetChanged=true;
        end
    end



    if pointingTargetChanged

        advance(simulator,simulator.Time);



        if simulator.SimulationMode==1
            updateStateHistory(simulator,true);
        end


        simulator.NeedToSimulate=true;


        if coder.target('MATLAB')
            sat(1).Scenario.NeedToSimulate=true;
            updateViewersIfAutoShow(sat);
        end
    end
end


