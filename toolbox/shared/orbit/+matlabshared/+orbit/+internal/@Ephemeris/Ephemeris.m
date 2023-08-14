classdef Ephemeris<matlabshared.orbit.internal.OrbitPropagationModel %#codegen






    properties(Access=private)
pStartTime
pStopTime
pPositionTimeTable
pVelocityTimeTable
        pEndValues=nan;
    end

    properties(Constant,Access=private)
        pInterpolationMethod="makima";
    end

    properties(Hidden,Access=private)
    end

    methods
        function ephemeris=Ephemeris(varargin)


            coder.allowpcode('plain');

            if nargin~=0
                initialTime=varargin{2};
                coordFrame=varargin{1};
                positionTable=varargin{3};

                validateattributes(positionTable,{'timetable'},...
                {'nonempty'},...
                'orbitPropagator','positionTable',3);


                uniqueTimes=sort(unique(positionTable.Time));
                positionTable=retime(positionTable,uniqueTimes);

                if nargin>3

                    velocityTable=varargin{4};

                    validateattributes(velocityTable,{'timetable'},...
                    {'nonempty'},...
                    'orbitPropagator','velocityTable',4);


                    uniqueTimes=sort(unique(velocityTable.Time));
                    velocityTable=retime(velocityTable,uniqueTimes);




                    if~containsrange(velocityTable,positionTable)
                        msgID='shared_orbit:orbitPropagator:EphemerisPosVelDoNotMatch';
                        if~overlapsrange(velocityTable,positionTable)
                            msgID='shared_orbit:orbitPropagator:EphemerisPosVelDoNotOverlap';
                            if isempty(coder.target)
                                error(message(msgID));
                            else
                                coder.internal.error(msgID);
                            end
                        else
                            warning(message(msgID));
                        end
                    end
                    [~,velocityTable]=ephemeris.extract(...
                    velocityTable,...
                    positionTable.Properties.RowTimes,...
                    ephemeris.pInterpolationMethod,...
                    "extrap");


                    [positionTable,velocityTable]=transformEphemeris(...
                    coordFrame,positionTable,velocityTable);

                else

                    positionTable=transformEphemeris(...
                    coordFrame,positionTable);


                    velocityTable=timetable(positionTable.Properties.RowTimes(2:end,:),...
                    diff(positionTable.Variables)./...
                    seconds(diff(positionTable.Properties.RowTimes)),...
                    'VariableNames',positionTable.Properties.VariableNames);
                end


                ephemeris.pPositionTimeTable=positionTable;
                ephemeris.pVelocityTimeTable=velocityTable;
                ephemeris.pStartTime=positionTable.Properties.StartTime;
                ephemeris.pStopTime=positionTable.Properties.RowTimes(end);



                if isempty(coder.target)&&~isequal(initialTime.TimeZone,'UTC')
                    initialTime.TimeZone='UTC';
                end


                ephemeris.InitialTime=initialTime;


                initialize(ephemeris);
            end
        end

        function infoStruct=info(ephemeris)














            coder.allowpcode('plain');
            infoStruct.StartTime=ephemeris.pStartTime;
            infoStruct.StopTime=ephemeris.pStopTime;
            infoStruct.PositionTimeTable=ephemeris.pPositionTimeTable;
            infoStruct.VelocityTimeTable=ephemeris.pVelocityTimeTable;
            infoStruct.InterpolationMethod=ephemeris.pInterpolationMethod;
            infoStruct.EndValues=ephemeris.pEndValues;

        end
    end

    methods(Access=protected)
        function initialize(ephemeris)


            coder.allowpcode('plain');


            posTable=ephemeris.pPositionTimeTable;
            velTable=ephemeris.pVelocityTimeTable;

            initialTime=ephemeris.InitialTime;



            initialPosition=matlabshared.orbit.internal.Ephemeris.extract(posTable,initialTime,...
            ephemeris.pInterpolationMethod,ephemeris.pEndValues);

            initialVelocity=matlabshared.orbit.internal.Ephemeris.extract(velTable,initialTime,...
            ephemeris.pInterpolationMethod,ephemeris.pEndValues);


            ephemeris.InitialPosition=initialPosition;
            ephemeris.InitialVelocity=initialVelocity;
            ephemeris.Position=initialPosition;
            ephemeris.Velocity=initialVelocity;
            ephemeris.Time=initialTime;
        end

        function[position,velocity]=stepImpl(ephemeris,time)



            coder.allowpcode('plain');

            position=ephemeris.extract(ephemeris.pPositionTimeTable,...
            time,ephemeris.pInterpolationMethod,ephemeris.pEndValues);

            velocity=ephemeris.extract(ephemeris.pVelocityTimeTable,...
            time,ephemeris.pInterpolationMethod,ephemeris.pEndValues);
        end
    end

    methods(Static)

        [state,newTT]=extract(TimeTable,time,interp,extrap);
    end
end

function[varargout]=transformEphemeris(coordFrame,posIn,varargin)



    varargout{1}=posIn;


    calcVel=false;
    if nargin>2
        calcVel=true;
        varargout{2}=varargin{1};
    end

    if coordFrame=="inertial"

        return;
    else
        for idx=1:height(posIn)


            itrf2gcrfTransform=...
            matlabshared.orbit.internal.Transforms.itrf2gcrfTransform(posIn.Time(idx));


            if coordFrame=="geographic"
                geodeticPosition=[posIn{idx,1}(1)*pi/180;...
                posIn{idx,1}(2)*pi/180;...
                posIn{idx,1}(3)];
                itrfPos=matlabshared.orbit.internal.Transforms.geographic2itrf(geodeticPosition);
                if calcVel
                    ned2itrfTransform=...
                    matlabshared.orbit.internal.Transforms.itrf2nedTransform(...
                    geodeticPosition)';
                    itrfVel=ned2itrfTransform*varargin{1}{idx,:}';
                end
            else
                itrfPos=posIn{idx,:}';
                if calcVel
                    itrfVel=varargin{1}{idx,:}';
                end
            end


            omega=[0;0;0.0000729211585530];


            varargout{1}{idx,:}=(itrf2gcrfTransform*itrfPos)';
            if calcVel
                varargout{2}{idx,:}=(itrf2gcrfTransform*...
                (itrfVel+cross(omega,itrfPos)))';
            end
        end
    end
end
