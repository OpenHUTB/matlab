function pointAt(gim,target)%#codegen


























































































































































































































































































    coder.allowpcode('plain');


    validateattributes(gim,{'matlabshared.satellitescenario.Gimbal'},{'nonempty','vector'},...
    'pointAt','GIMBAL',1);


    numGimbals=numel(gim);

    if coder.target('MATLAB')

        if~all(isvalid(gim))
            msg=message(...
            'shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject',...
            'GIMBAL');
            error(msg);
        end
    end


    simulator=gim(1).Simulator;



    coder.internal.errorIf(simulator.SimulationMode==1&&simulator.SimulationStatus==2,...
    'shared_orbit:orbitPropagator:UnablePointAtIncorrectSimStatus');

    if coder.target('MATLAB')

        if~all([gim.Simulator]==simulator)
            msg=message(...
            'shared_orbit:orbitPropagator:InputsDifferentSatelliteScenario');
            error(msg);
        end
    end


    validateattributes(target,{'matlabshared.satellitescenario.Satellite',...
    'matlabshared.satellitescenario.GroundStation','double','char',...
    'string','table','timetable','timeseries'},{},'pointAt','TARGET',2);



    validatedTarget='';

    if isa(target,'matlabshared.satellitescenario.Satellite')||...
        isa(target,'matlabshared.satellitescenario.GroundStation')


        validateattributes(target,{'matlabshared.satellitescenario.Satellite',...
        'matlabshared.satellitescenario.GroundStation'},{'nonempty','vector'},'pointAt','TARGET');



        if~isscalar(target)
            validateattributes(target,{'matlabshared.satellitescenario.Satellite',...
            'matlabshared.satellitescenario.GroundStation'},{'numel',numGimbals},'pointAt','TARGET');
        end

        if coder.target('MATLAB')

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
            {'nrows',3,'ncols',numGimbals},...
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


            coder.internal.errorIf(true,'shared_orbit:orbitPropagator:CustomOrientationNotSupportedForCodegen');
        end

        if istable(target)
            target=table2timetable(target);
        end

        if~isdatetime(target.Properties.StartTime)


            target.Properties.StartTime=target.Properties.StartTime...
            +gim(1).Scenario.StartTime;
        end
        if isempty(target.Properties.RowTimes.TimeZone)&&isempty(coder.target)
            target.Properties.RowTimes.TimeZone='UTC';
        end



        target=matlabshared.orbit.internal.processMultiDimTTintoTT(target,2);


        uniqueTimes=sort(unique(target.Properties.RowTimes));
        target=retime(target,uniqueTimes,'firstvalue');

        validateattributes(target.Properties.VariableNames,{'cell'},{'numel',numGimbals},...
        'pointAt','TARGET');

    elseif isa(target,'timeseries')
        if~isempty(coder.target)


            coder.internal.errorIf(true,'shared_orbit:orbitPropagator:CustomOrientationNotSupportedForCodegen');
        end
        validateattributes(target.Data,{'numeric'},...
        {'nonempty','real','finite','3d'},...
        'pointAt','STEERINGTIMESERIES');
        target=matlabshared.orbit.internal.processMultiDimTSintoCellArrayOfTS(target,2);

        validateattributes(target,{'cell'},{'numel',numGimbals},...
        'pointAt','TARGET');
        for tgtIdx=1:numel(target)
            if~isdatetime(target{tgtIdx}.TimeInfo.StartDate)

                target{tgtIdx}.TimeInfo.StartDate=gim(1).Scenario.StartTime;
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

        validatedTarget=validatestring(target,{'nadir','none'},"pointAt");
    end




    pointingTargetChanged=false;
    for idx=1:numGimbals

        originalPointingTarget=gim(idx).PointingTarget;



        gimSimIndex=getIdxInSimulatorStruct(gim(idx));


        if isa(target,'matlabshared.satellitescenario.Satellite')



            if isscalar(target)
                targetSimID=target.SimulatorID;
            else
                targetSimID=target(idx).SimulatorID;
            end
            newPointingTarget=targetSimID;
            simulator.Gimbals(gimSimIndex).PointingMode=1;
            simulator.Gimbals(gimSimIndex).PointingTargetID=targetSimID;
            gim(idx).PointingTarget=targetSimID;
        elseif isa(target,'matlabshared.satellitescenario.GroundStation')



            if isscalar(target)
                targetSimID=target.SimulatorID;
            else
                targetSimID=target(idx).SimulatorID;
            end
            newPointingTarget=targetSimID;
            simulator.Gimbals(gimSimIndex).PointingMode=2;
            simulator.Gimbals(gimSimIndex).PointingTargetID=targetSimID;
            gim(idx).PointingTarget=targetSimID;
        elseif isa(target,'double')




            simulator.Gimbals(gimSimIndex).PointingMode=3;
            if isvector(target)
                pointingCoordinates=matlabshared.orbit.internal.Transforms.geographic2itrf(...
                [target(1)*pi/180;target(2)*pi/180;target(3)]);
            else
                pointingCoordinates=matlabshared.orbit.internal.Transforms.geographic2itrf(...
                [target(1,idx)*pi/180;target(2,idx)*pi/180;target(3,idx)]);
            end
            newPointingTarget=pointingCoordinates;
            simulator.Gimbals(gimSimIndex).PointingCoordinates=...
            pointingCoordinates;
            if isvector(target)
                gim(idx).PointingTarget=reshape(target,3,[]);
            else
                gim(idx).PointingTarget=target(:,idx);
            end
        elseif isa(target,'timetable')




            newPointingTarget=-3;
            simulator.Gimbals(gimSimIndex).PointingMode=6;
            simulator.Gimbals(gimSimIndex).CustomAngles=target(:,idx);
            gim(idx).PointingTarget=-3;

            pointingTargetChanged=true;
        elseif strcmpi(validatedTarget,'nadir')



            newPointingTarget=-1;
            simulator.Gimbals(gimSimIndex).PointingMode=4;
            gim(idx).PointingTarget=-1;
        else



            newPointingTarget=-2;
            simulator.Gimbals(gimSimIndex).PointingMode=5;
            gim(idx).PointingTarget=-2;
        end


        if~pointingTargetChanged&&~isequal(originalPointingTarget,newPointingTarget)
            pointingTargetChanged=true;
        end
    end



    if pointingTargetChanged
        advance(simulator,simulator.Time);
        simulator.NeedToSimulate=true;


        if simulator.SimulationMode==1
            updateStateHistory(simulator,true);
        end

        if coder.target('MATLAB')
            gim(1).Scenario.NeedToSimulate=true;
            updateViewersIfAutoShow(gim);
        end
    end
end


