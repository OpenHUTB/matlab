function pointAt(trx,varargin)





















































%#codegen


    narginchk(2,3);


    validateattributes(trx,{'satcom.satellitescenario.Transmitter',...
    'satcom.satellitescenario.Receiver'},{'nonempty','vector'},...
    'pointAt','TRX',1);


    numTrx=numel(trx);


    if isa(trx,'satcom.satellitescenario.Transmitter')
        inputType='transmitter';
    else
        inputType='receiver';
    end

    for idx=1:numTrx

        if~isvalid(trx(idx))
            msg=message(...
            'shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject',...
            inputType);
            error(msg);
        end
    end


    simulator=trx(1).Simulator;



    coder.internal.errorIf(simulator.SimulationMode==1&&simulator.SimulationStatus==2,...
    'shared_orbit:orbitPropagator:UnablePointAtIncorrectSimStatus');

    for idx=1:numTrx


        if~isequal(trx(idx).Simulator,simulator)
            msg=message(...
            'shared_orbit:orbitPropagator:InputsDifferentSatelliteScenario');
            error(msg);
        end


        if~isa(trx(idx).Antenna,'phased.internal.AbstractArray')
            msg=message('shared_orbit:orbitPropagator:NonSteerableAntenna');
            error(msg);
        end
    end


    usingExplicitWeights=false;
    if nargin==3

        paramNames={'Weights'};
        pstruct=coder.internal.parseParameterInputs(paramNames,satelliteScenario.InputParserOptions,varargin{:});
        weights=coder.internal.getParameterValue(pstruct.Weights,1,varargin{:});
        validateattributes(weights,{'double'},{'finite','nonempty','2d'},'pointAt','Weights');
        weights=complex(weights);



        if ismatrix(weights)
            validateattributes(weights,{'double'},{'ncols',numTrx'},'pointAt','Weights');
            for idx=1:numTrx
                validateattributes(weights(:,idx),{'double'},{'nrows',getDOF(trx(idx).Antenna)},'pointAt','Weights');
            end
        else
            weights=reshape(weights,[],1);
            for idx=1:numTrx
                validateattributes(weights,{'double'},{'numel',getDOF(trx(idx).Antenna)},'pointAt','Weights');
            end
        end


        usingExplicitWeights=true;
    else




        target=varargin{1};


        validateattributes(target,{'matlabshared.satellitescenario.Satellite',...
        'matlabshared.satellitescenario.GroundStation','double','char','string'},{},...
        'pointAt','TARGET',2);



        validatedTarget='';

        if isa(target,'matlabshared.satellitescenario.Satellite')||...
            isa(target,'matlabshared.satellitescenario.GroundStation')


            validateattributes(target,{'matlabshared.satellitescenario.Satellite',...
            'matlabshared.satellitescenario.GroundStation'},{'nonempty','vector'},'pointAt','TARGET');



            if~isscalar(target)
                validateattributes(target,{'matlabshared.satellitescenario.Satellite',...
                'matlabshared.satellitescenario.GroundStation'},{'numel',numTrx},'pointAt','TARGET');
            end


            for idx=1:numel(target)
                if~isvalid(target(idx))
                    msg=message(...
                    'shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject',...
                    'TARGET');
                    error(msg);
                end


                if target(idx).Simulator~=simulator
                    msg='shared_orbit:orbitPropagator:SatelliteScenarioPointAtTargetDifferentScenario';
                    msg=message(msg);
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
                {'scalar','>=',-90,'<=',90},'pointAt','TARGET latitude');


                if(target(2)>180)||(target(2)<=-180)
                    target(2)=mod(target(2),360);
                    if target(2)>180
                        target(2)=target(2)-360;
                    end
                end
            else
                validateattributes(target,{'double'},...
                {'nrows',3,'ncols',numTrx},...
                'pointAt','TARGET');
                validateattributes(target(1,:),{'double'},...
                {'>=',-90,'<=',90},'pointAt','TARGET latitude');


                indexLonOutside180=(target(2,:)>180)|(target(2,:)<=-180);
                target(2,indexLonOutside180)=mod(target(2,indexLonOutside180),360);
                indexLonGreaterThan180=target(2,:)>180;
                target(2,indexLonGreaterThan180)=target(2,indexLonGreaterThan180)-360;
            end
        else

            validatedTarget=validatestring(target,{'nadir','none'},'pointAt','Weights');
        end
    end




    pointingTargetOrWeightsChanged=false;
    for idx=1:numTrx

        originalPointingTarget=trx(idx).PointingTarget;


        simIndex=getIdxInSimulatorStruct(trx(idx));


        if usingExplicitWeights

            if isvector(weights)
                currentWeights=weights;
            else
                currentWeights=weights(:,idx);
            end


            newPointingTarget=-3;
            switch trx(idx).Type
            case 5
                simulator.Transmitters(simIndex).PointingMode=6;
                originalWeights=simulator.Transmitters(simIndex).PhasedArrayWeights;
                simulator.Transmitters(simIndex).PhasedArrayWeights=currentWeights;
            otherwise
                simulator.Receivers(simIndex).PointingMode=6;
                originalWeights=simulator.Transmitters(simIndex).PhasedArrayWeights;
                simulator.Receivers(simIndex).PhasedArrayWeights=currentWeights;
            end
            trx(idx).PointingTarget=-3;
            if~isequal(originalWeights,currentWeights)
                pointingTargetOrWeightsChanged=true;
            end
        else
            if isa(target,'matlabshared.satellitescenario.Satellite')



                if isscalar(target)
                    targetSimID=target.SimulatorID;
                else
                    targetSimID=target(idx).SimulatorID;
                end
                newPointingTarget=targetSimID;
                switch trx(idx).Type
                case 5
                    simulator.Transmitters(simIndex).PointingMode=1;
                    simulator.Transmitters(simIndex).PointingTargetID=targetSimID;
                otherwise
                    simulator.Receivers(simIndex).PointingMode=1;
                    simulator.Receivers(simIndex).PointingTargetID=targetSimID;
                end
                trx(idx).PointingTarget=targetSimID;
            elseif isa(target,'matlabshared.satellitescenario.GroundStation')



                if isscalar(target)
                    targetSimID=target.SimulatorID;
                else
                    targetSimID=target(idx).SimulatorID;
                end
                newPointingTarget=targetSimID;
                switch trx(idx).Type
                case 5
                    simulator.Transmitters(simIndex).PointingMode=2;
                    simulator.Transmitters(simIndex).PointingTargetID=targetSimID;
                otherwise
                    simulator.Receivers(simIndex).PointingMode=2;
                    simulator.Receivers(simIndex).PointingTargetID=targetSimID;
                end
                trx(idx).PointingTarget=targetSimID;
            elseif isa(target,'double')




                if isvector(target)
                    pointingCoordinates=matlabshared.orbit.internal.Transforms.geographic2itrf(...
                    [target(1)*pi/180;target(2)*pi/180;target(3)]);
                else
                    pointingCoordinates=matlabshared.orbit.internal.Transforms.geographic2itrf(...
                    [target(1,idx)*pi/180;target(2,idx)*pi/180;target(3,idx)]);
                end
                newPointingTarget=pointingCoordinates;
                switch trx(idx).Type
                case 5
                    simulator.Transmitters(simIndex).PointingMode=3;
                    simulator.Transmitters(simIndex).PointingCoordinates=...
                    pointingCoordinates;
                otherwise
                    simulator.Receivers(simIndex).PointingMode=3;
                    simulator.Receivers(simIndex).PointingCoordinates=...
                    pointingCoordinates;
                end
                trx(idx).PointingTarget=target;
            elseif strcmpi(validatedTarget,'nadir')
                newPointingTarget=-1;
                switch trx(idx).Type
                case 5
                    simulator.Transmitters(simIndex).PointingMode=4;
                otherwise
                    simulator.Receivers(simIndex).PointingMode=4;
                end
                trx(idx).PointingTarget=-1;
            else
                newPointingTarget=-2;
                switch trx(idx).Type
                case 5
                    simulator.Transmitters(simIndex).PointingMode=5;
                otherwise
                    simulator.Receivers(simIndex).PointingMode=5;
                end
                trx(idx).PointingTarget=-2;
            end
        end


        if~pointingTargetOrWeightsChanged&&~isequal(originalPointingTarget,newPointingTarget)
            pointingTargetOrWeightsChanged=true;
        end
    end



    if pointingTargetOrWeightsChanged
        advance(simulator,simulator.Time);
        simulator.NeedToSimulate=true;
        if simulator.SimulationMode==1
            updateStateHistory(simulator,true);
        end


        if coder.target('MATLAB')
            trx(1).Scenario.NeedToSimulate=true;
            updateViewers(trx,trx(1).Scenario.Viewers,false,true);
            updateViewersIfAutoShow(trx);
        end
    end
end

