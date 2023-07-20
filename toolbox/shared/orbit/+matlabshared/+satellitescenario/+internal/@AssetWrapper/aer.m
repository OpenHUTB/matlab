function[az,el,r,time]=aer(obj,target,varargin)%#codegen
































































































































    coder.allowpcode('plain');


    narginchk(2,5);





    historyRequested=mod(nargin,2)==0;


    if~historyRequested
        time=varargin{1};
        paramArgs={varargin{2:end}};
    else
        paramArgs=varargin;
    end
    paramNames={'CoordinateFrame'};
    pstruct=coder.internal.parseParameterInputs(paramNames,satelliteScenario.InputParserOptions,paramArgs{:});
    coordinateFrame=coder.internal.getParameterValue(pstruct.CoordinateFrame,'ned',paramArgs{:});


    validateattributes(obj,{'matlabshared.satellitescenario.Satellite',...
    'matlabshared.satellitescenario.GroundStation',...
    'matlabshared.satellitescenario.ConicalSensor',...
    'matlabshared.satellitescenario.Gimbal',...
    'satcom.satellitescenario.Transmitter',...
    'satcom.satellitescenario.Receiver'},...
    {'nonempty','vector'},'aer','OBJ',1);


    validateattributes(target,...
    {'matlabshared.satellitescenario.Satellite',...
    'matlabshared.satellitescenario.GroundStation',...
    'matlabshared.satellitescenario.ConicalSensor',...
    'matlabshared.satellitescenario.Gimbal',...
    'satcom.satellitescenario.Transmitter',...
    'satcom.satellitescenario.Receiver'},...
    {'nonempty','vector'},'aer','TARGET',2);


    numSource=numel(obj);


    numTarget=numel(target);

    if isempty(coder.target)

        errMsg=message('shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject','OBJ');
        for idx=1:numSource
            if~isvalid(obj(idx))
                error(errMsg);
            end
        end


        errMsg=message('shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject','TARGET');
        for idx=1:numTarget
            if~isvalid(target(idx))
                error(errMsg);
            end
        end
    end


    coordFrame=validatestring(coordinateFrame,...
    {'ned','body'},...
    'aer','CoordinateFrame');


    if strcmp(coordFrame,'ned')
        isFrameNED=true;
    else
        isFrameNED=false;
    end


    simulator=obj(1).Simulator;

    if isempty(coder.target)

        errMsg=message('shared_orbit:orbitPropagator:InputsDifferentSatelliteScenario');
        for idx=1:numSource
            if~isequal(obj(idx).Simulator,simulator)
                error(errMsg);
            end
        end



        for idx=1:numTarget
            if~isequal(target(idx).Simulator,simulator)
                error(errMsg);
            end
        end
    end

    if numSource~=1&&numTarget~=1
        validateattributes(target,...
        {'matlabshared.satellitescenario.Satellite',...
        'matlabshared.satellitescenario.GroundStation',...
        'matlabshared.satellitescenario.ConicalSensor',...
        'matlabshared.satellitescenario.Gimbal',...
        'satcom.satellitescenario.Transmitter',...
        'satcom.satellitescenario.Receiver'},...
        {'numel',numSource},'aer','TARGET',2);
    end


    numRows=max([numSource,numTarget]);

    if historyRequested




        simulate(simulator);


        time=simulator.TimeHistory;


        historyLength=numel(time);


        az=zeros(numRows,historyLength);
        el=zeros(numRows,historyLength);
        r=zeros(numRows,historyLength);



        if isempty(time)
            return
        end


        for idx=1:numRows

            if~isscalar(obj)
                objCurrent=obj(idx);
            else
                objCurrent=obj;
            end


            if~isscalar(target)
                targetCurrent=target(idx);
            else
                targetCurrent=target;
            end



            if objCurrent==targetCurrent
                continue
            end


            objITRF=objCurrent.pPositionITRFHistory;


            targetITRF=targetCurrent.pPositionITRFHistory;




            coder.internal.errorIf((size(objITRF,2)~=historyLength)||...
            (size(targetITRF,2)~=historyLength),...
            'shared_orbit:orbitPropagator:AssetOrAnalysisAddedWhenSimulationRunning',...
            'azimuth, elevation, and range','assets');


            relativePositionITRF=targetITRF-objITRF;



            if isFrameNED
                transformationMatrix=...
                matlabshared.orbit.internal.Transforms.itrf2nedTransform(...
                [objCurrent.pLatitudeHistory*pi/180;...
                objCurrent.pLongitudeHistory*pi/180;...
                objCurrent.pAltitudeHistory]);
            else
                transformationMatrix=objCurrent.pItrf2BodyTransformHistory;
            end


            relativePositionNED=reshape(pagemtimes(transformationMatrix,reshape(relativePositionITRF,3,1,[])),3,[]);


            r(idx,:)=vecnorm(relativePositionITRF,2);


            rangeZeroIndices=r==0;


            x=relativePositionNED(1,:);
            y=relativePositionNED(2,:);
            az(idx,:)=mod(atan2d(y,x),360);


            z=relativePositionNED(3,:);
            el(idx,:)=asind(max(min(-(z./r(idx,:)),1),-1));


            az(rangeZeroIndices)=0;
            el(rangeZeroIndices)=0;
        end
    else




        validateattributes(time,...
        {'datetime'},{'nonempty','finite','scalar'},'aer','TIME');

        if isempty(coder.target)

            time.TimeZone="UTC";
        end



        if time<simulator.StartTime||time>simulator.StopTime
            msg='shared_orbit:orbitPropagator:TimeOutsideBounds';
            erroringFunction='aer';
            if coder.target('MATLAB')
                error(message(msg,erroringFunction));
            else
                coder.internal.error(msg,erroringFunction);
            end
        end




        originalTime=simulator.Time;


        advance(simulator,time);


        az=zeros(numRows,1);
        el=az;
        r=az;


        for idx=1:numRows

            if isscalar(obj)
                objCurrent=obj;
            else
                objCurrent=obj(idx);
            end


            if isscalar(target)
                targetCurrent=target;
            else
                targetCurrent=target(idx);
            end


            [az(idx),el(idx),r(idx)]=currentAzimuthAndElevationAngle(objCurrent,targetCurrent,isFrameNED);
        end



        if simulator.SimulationMode==1
            advance(simulator,originalTime);
        end
    end
end


