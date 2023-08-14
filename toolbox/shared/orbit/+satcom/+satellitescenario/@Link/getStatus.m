function[statHistory,ebnoHistory,ripHistory,rxInputPowerHistory,intervals,numIntervals]=getStatus(...
    sequence,nodeType,nodeIndex,sat,gs,tx,rx,simIDMemo,timeHistoryArray,...
    antennaType,numSamples,updateTaper)%#codegen




    coder.allowpcode('plain');

    if isempty(coder.target)&&(antennaType==0||antennaType==1)
        [statHistory,ebnoHistory,ripHistory,rxInputPowerHistory,intervals,numIntervals]=satcom.satellitescenario.Link.cg_getStatus(...
        sequence,nodeType,nodeIndex,sat,gs,tx,rx,simIDMemo,timeHistoryArray,antennaType,numSamples,updateTaper);
        for idx=1:numIntervals
            intervals(idx).StartTime.TimeZone='UTC';
            intervals(idx).EndTime.TimeZone='UTC';
        end
        return
    end


    if coder.target('MATLAB')
        timeHistory=datetime(timeHistoryArray,'TimeZone','UTC');
    else
        timeHistory=datetime(timeHistoryArray);
    end


    numIntervals=0;
    t=NaT;
    intervals=struct("StartTime",t,"EndTime",t);
    coder.varsize('intervals',[1,Inf],[0,1]);
    intervals(1)=[];


    numNodes=numel(sequence);

    source=getSourceTargetDummyStruct;
    target=getSourceTargetDummyStruct;


    statHistory=coder.nullcopy(false(1,numSamples));


    ebnoHistory=coder.nullcopy(zeros(1,numSamples));
    ripHistory=coder.nullcopy(zeros(1,numSamples));
    rxInputPowerHistory=coder.nullcopy(zeros(1,numSamples));

    for sampleIdx=1:numSamples
        stat=false;
        ebnoLevel=0;
        rip=0;
        rxInputPower=0;

        for idx=1:numNodes-1

            switch nodeType(idx)
            case 5
                sourceStruct=tx(nodeIndex(idx));
                source.Type=sourceStruct.Type;
                source.GrandParentType=sourceStruct.GrandParentType;
                source.GrandParentSimulatorID=sourceStruct.GrandParentSimulatorID;
                source.PositionITRF=sourceStruct.PositionITRF(:,sampleIdx);
                source.Altitude=sourceStruct.Altitude(sampleIdx);
                source.Itrf2BodyTransform=sourceStruct.Itrf2BodyTransform(:,:,sampleIdx);
                source.Frequency=sourceStruct.Frequency;
                source.DishDiameter=sourceStruct.DishDiameter;
                source.ApertureEfficiency=sourceStruct.ApertureEfficiency;
                source.Antenna=sourceStruct.Antenna;
                source.AntennaPattern=sourceStruct.AntennaPattern;
                source.AntennaType=sourceStruct.AntennaType;
                source.AntennaPatternFrequency=sourceStruct.AntennaPatternFrequency;
                source.Power=sourceStruct.Power;
                source.BitRate=sourceStruct.BitRate;
                source.SystemLoss=sourceStruct.SystemLoss;
                source.PointingMode=sourceStruct.PointingMode;
                source.PhasedArrayWeights=sourceStruct.PhasedArrayWeights;
                source.PhasedArrayWeightsDefault=sourceStruct.PhasedArrayWeightsDefault;
                source.PointingDirection=sourceStruct.PointingDirection(:,sampleIdx);
            otherwise
                sourceStruct=rx(nodeIndex(idx));
                source.Type=sourceStruct.Type;
                source.GrandParentType=sourceStruct.GrandParentType;
                source.GrandParentSimulatorID=sourceStruct.GrandParentSimulatorID;
                source.PositionITRF=sourceStruct.PositionITRF(:,sampleIdx);
                source.Altitude=sourceStruct.Altitude(sampleIdx);
                source.Itrf2BodyTransform=sourceStruct.Itrf2BodyTransform(:,:,sampleIdx);
                source.DishDiameter=sourceStruct.DishDiameter;
                source.ApertureEfficiency=sourceStruct.ApertureEfficiency;
                source.Antenna=sourceStruct.Antenna;
                source.AntennaPattern=sourceStruct.AntennaPattern;
                source.AntennaType=sourceStruct.AntennaType;
                source.AntennaPatternFrequency=sourceStruct.AntennaPatternFrequency;
                source.SystemLoss=sourceStruct.SystemLoss;
                source.PreReceiverLoss=sourceStruct.PreReceiverLoss;
                source.GainToNoiseTemperatureRatio=sourceStruct.GainToNoiseTemperatureRatio;
                source.RequiredEbNo=sourceStruct.RequiredEbNo;
                source.PointingMode=sourceStruct.PointingMode;
                source.PhasedArrayWeights=sourceStruct.PhasedArrayWeights;
                source.PhasedArrayWeightsDefault=sourceStruct.PhasedArrayWeightsDefault;
                source.PointingDirection=sourceStruct.PointingDirection(:,sampleIdx);
            end


            switch nodeType(idx+1)
            case 5
                targetStruct=tx(nodeIndex(idx+1));
                target.Type=targetStruct.Type;
                target.GrandParentType=targetStruct.GrandParentType;
                target.GrandParentSimulatorID=targetStruct.GrandParentSimulatorID;
                target.PositionITRF=targetStruct.PositionITRF(:,sampleIdx);
                target.Altitude=targetStruct.Altitude(sampleIdx);
                target.Itrf2BodyTransform=targetStruct.Itrf2BodyTransform(:,:,sampleIdx);
                target.Frequency=targetStruct.Frequency;
                target.DishDiameter=targetStruct.DishDiameter;
                target.Antenna=targetStruct.Antenna;
                target.AntennaPattern=targetStruct.AntennaPattern;
                target.AntennaType=targetStruct.AntennaType;
                target.AntennaPatternFrequency=targetStruct.AntennaPatternFrequency;
                target.ApertureEfficiency=targetStruct.ApertureEfficiency;
                target.Power=targetStruct.Power;
                target.BitRate=targetStruct.BitRate;
                target.SystemLoss=targetStruct.SystemLoss;
                target.PointingMode=targetStruct.PointingMode;
                target.PhasedArrayWeights=targetStruct.PhasedArrayWeights;
                target.PhasedArrayWeightsDefault=targetStruct.PhasedArrayWeightsDefault;
                target.PointingDirection=targetStruct.PointingDirection(:,sampleIdx);
            otherwise
                targetStruct=rx(nodeIndex(idx+1));
                target.Type=targetStruct.Type;
                target.GrandParentType=targetStruct.GrandParentType;
                target.GrandParentSimulatorID=targetStruct.GrandParentSimulatorID;
                target.PositionITRF=targetStruct.PositionITRF(:,sampleIdx);
                target.Altitude=targetStruct.Altitude(sampleIdx);
                target.Itrf2BodyTransform=targetStruct.Itrf2BodyTransform(:,:,sampleIdx);
                target.DishDiameter=targetStruct.DishDiameter;
                target.ApertureEfficiency=targetStruct.ApertureEfficiency;
                target.Antenna=targetStruct.Antenna;
                target.AntennaPattern=targetStruct.AntennaPattern;
                target.AntennaType=targetStruct.AntennaType;
                target.AntennaPatternFrequency=targetStruct.AntennaPatternFrequency;
                target.SystemLoss=targetStruct.SystemLoss;
                target.PreReceiverLoss=targetStruct.PreReceiverLoss;
                target.GainToNoiseTemperatureRatio=targetStruct.GainToNoiseTemperatureRatio;
                target.RequiredEbNo=targetStruct.RequiredEbNo;
                target.PointingMode=targetStruct.PointingMode;
                target.PhasedArrayWeights=targetStruct.PhasedArrayWeights;
                target.PhasedArrayWeightsDefault=targetStruct.PhasedArrayWeightsDefault;
                target.PointingDirection=targetStruct.PointingDirection(:,sampleIdx);
            end


            [stat,ebnoLevel,rip,rxInputPower]=calculateStatus(source,target,sat,gs,sampleIdx,simIDMemo,updateTaper);
            if~stat


                if idx~=(numNodes-1)
                    ebnoLevel=-Inf;
                    rip=-Inf;
                    rxInputPower=-Inf;
                end


                break
            end
        end
        statHistory(sampleIdx)=stat;
        ebnoHistory(sampleIdx)=ebnoLevel;
        ripHistory(sampleIdx)=rip;
        rxInputPowerHistory(sampleIdx)=rxInputPower;


        if sampleIdx==1
            previousStat=false;
        else
            previousStat=statHistory(sampleIdx-1);
        end

        if stat&&~previousStat



            numIntervals=numIntervals+1;



            existingIntervals=intervals;
            newIntervalStruct=struct("StartTime",timeHistory(sampleIdx),...
            "EndTime",t);
            intervals=[existingIntervals,newIntervalStruct];
        elseif~stat&&previousStat



            intervals(numIntervals).EndTime=timeHistory(sampleIdx-1);



            intervalStartTime=intervals(numIntervals).StartTime;
            intervalEndTime=intervals(numIntervals).EndTime;
            if abs(seconds(intervalEndTime-intervalStartTime))<matlabshared.satellitescenario.internal.Simulator.DatetimeComparisonTolerance
                intervals(numIntervals)=[];
                numIntervals=numIntervals-1;
            end
        end

        if(sampleIdx==numSamples)&&(numIntervals>0)&&isnat(intervals(end).EndTime)


            intervalStartTime=intervals(end).StartTime;
            intervalEndTime=timeHistory(end);
            if abs(seconds(intervalEndTime-intervalStartTime))<matlabshared.satellitescenario.internal.Simulator.DatetimeComparisonTolerance
                intervals(end)=[];
                numIntervals=numIntervals-1;
            else

                intervals(end).EndTime=intervalEndTime;
            end
        end
    end
end

function[stat,ebnoLevel,rip,rxInputPower]=calculateStatus(source,target,sat,gs,sampleIdx,simIDMemo,updateTaper)


    coder.allowpcode('plain');



    if isequal(source,target)
        stat=true;
        ebnoLevel=Inf;
        rip=Inf;
        rxInputPower=Inf;
        return
    end



    if source.GrandParentSimulatorID==target.GrandParentSimulatorID
        stat=true;
        ebnoLevel=Inf;
        rip=Inf;
        rxInputPower=Inf;
        return
    end



    if(source.Type==6)||(target.Type==5)
        stat=false;
        ebnoLevel=-Inf;
        rip=-Inf;
        rxInputPower=-Inf;
        return
    end




    if abs(source.Altitude)<=1e-3
        sourcePosition=source.PositionITRF+(source.PositionITRF/norm(source.PositionITRF))*1e-3;
    else
        sourcePosition=source.PositionITRF;
    end
    if abs(target.Altitude)<=1e-3
        targetPosition=target.PositionITRF+(target.PositionITRF/norm(target.PositionITRF))*1e-3;
    else
        targetPosition=target.PositionITRF;
    end
    if isEarthBlocking(sourcePosition,targetPosition)
        stat=false;
        ebnoLevel=-Inf;
        rip=-Inf;
        rxInputPower=-Inf;
        return
    end


    grandParentSimID=source.GrandParentSimulatorID;
    grandParentType=source.GrandParentType;
    grandParentIndex=simIDMemo(grandParentSimID);
    sourceGrandParent=coder.nullcopy(struct("Type",0,...
    "PositionITRF",[0;0;0],...
    "Altitude",0,...
    "Itrf2BodyTransform",zeros(3),...
    "MinElevationAngle",0));
    switch grandParentType
    case 1
        sourceGrandParentStruct=sat(grandParentIndex);
        sourceGrandParent.Type=sourceGrandParentStruct.Type;
        sourceGrandParent.PositionITRF=sourceGrandParentStruct.PositionITRF(:,sampleIdx);
        sourceGrandParent.Altitude=sourceGrandParentStruct.Altitude(sampleIdx);
        sourceGrandParent.Itrf2BodyTransform=sourceGrandParentStruct.Itrf2BodyTransform(:,:,sampleIdx);
    otherwise
        sourceGrandParentStruct=gs(grandParentIndex);
        sourceGrandParent.Type=sourceGrandParentStruct.Type;
        sourceGrandParent.PositionITRF=sourceGrandParentStruct.PositionITRF(:,sampleIdx);
        sourceGrandParent.Altitude=sourceGrandParentStruct.Altitude(sampleIdx);
        sourceGrandParent.Itrf2BodyTransform=sourceGrandParentStruct.Itrf2BodyTransform(:,:,sampleIdx);
        sourceGrandParent.MinElevationAngle=sourceGrandParentStruct.MinElevationAngle;
    end


    grandParentSimID=target.GrandParentSimulatorID;
    grandParentType=target.GrandParentType;
    grandParentIndex=simIDMemo(grandParentSimID);
    targetGrandParent=coder.nullcopy(struct("Type",0,...
    "PositionITRF",[0;0;0],...
    "Altitude",0,...
    "Itrf2BodyTransform",zeros(3),...
    "MinElevationAngle",0));
    switch grandParentType
    case 1
        targetGrandParentStruct=sat(grandParentIndex);
        targetGrandParent.Type=targetGrandParentStruct.Type;
        targetGrandParent.PositionITRF=targetGrandParentStruct.PositionITRF(:,sampleIdx);
        targetGrandParent.Altitude=targetGrandParentStruct.Altitude(sampleIdx);
        targetGrandParent.Itrf2BodyTransform=targetGrandParentStruct.Itrf2BodyTransform(:,:,sampleIdx);
    otherwise
        targetGrandParentStruct=gs(grandParentIndex);
        targetGrandParent.Type=targetGrandParentStruct.Type;
        targetGrandParent.PositionITRF=targetGrandParentStruct.PositionITRF(:,sampleIdx);
        targetGrandParent.Altitude=targetGrandParentStruct.Altitude(sampleIdx);
        targetGrandParent.Itrf2BodyTransform=targetGrandParentStruct.Itrf2BodyTransform(:,:,sampleIdx);
        targetGrandParent.MinElevationAngle=targetGrandParentStruct.MinElevationAngle;
    end





    if sourceGrandParent.Type==2
        sourceITRF=sourceGrandParent.PositionITRF;
        sourceItrf2BodyTransform=sourceGrandParent.Itrf2BodyTransform;
        targetITRF=target.PositionITRF;
        [~,el]=getRelativeAzimuthAndElevationAngle(...
        sourceITRF,sourceItrf2BodyTransform,targetITRF);
        if el<sourceGrandParent.MinElevationAngle
            stat=false;
            ebnoLevel=-Inf;
            rip=-Inf;
            rxInputPower=-Inf;
            return
        end
    end
    if targetGrandParent.Type==2
        targetITRF=targetGrandParent.PositionITRF;
        targetItrf2BodyTransform=targetGrandParent.Itrf2BodyTransform;
        sourceITRF=source.PositionITRF;
        [~,el]=getRelativeAzimuthAndElevationAngle(...
        targetITRF,targetItrf2BodyTransform,sourceITRF);
        if el<targetGrandParent.MinElevationAngle
            stat=false;
            ebnoLevel=-Inf;
            rip=-Inf;
            rxInputPower=-Inf;
            return
        end
    end


    [stat,ebnoLevel,rip,rxInputPower]=linkComputation(source,target,updateTaper);
end

function[stat,ebnoLevel,receivedIsotropicPower,rxInputPower]=linkComputation(tx,rx,updateTaper)


    coder.allowpcode('plain');


    frequency=tx.Frequency;



    txITRF=tx.PositionITRF;
    txItrf2BodyTransform=tx.Itrf2BodyTransform;
    rxITRF=rx.PositionITRF;
    [az,el,distance]=getRelativeAzimuthAndElevationAngle(...
    txITRF,txItrf2BodyTransform,rxITRF);

    if tx.AntennaType==0
        dishDiameter=tx.DishDiameter;
        apertureEfficiency=tx.ApertureEfficiency;
        txAntennaGain=satcom.satellitescenario.GaussianAntenna.getPattern(dishDiameter,apertureEfficiency,frequency,az,-el);
    elseif tx.AntennaType==1
        freqIdx=find(tx.AntennaPatternFrequency==frequency,1);
        patTx=tx.AntennaPattern(freqIdx);
        if sum(any(~isfinite(patTx(1).Gain)))>0
            txAntennaGain=interp2(patTx(1).Azimuth,...
            patTx(1).Elevation,...
            patTx(1).Gain,wrapTo180(az),-el,'linear');
        else
            txAntennaGain=interp2(patTx(1).Azimuth,...
            patTx(1).Elevation,...
            patTx(1).Gain,wrapTo180(az),-el,'spline');
        end
    else
        if isempty(coder.target)

            switch tx.PointingMode
            case 6

                weights=tx.PhasedArrayWeights;
            case 5


                weights=conj(tx.PhasedArrayWeightsDefault);
                if isscalar(weights)
                    weights=repmat(weights,getDOF(tx.Antenna),1);
                end
            otherwise

                stv=phased.SteeringVector('SensorArray',tx.Antenna);
                weights=stv(frequency,tx.PointingDirection);
            end


            txAntennaGain=directivity(tx.Antenna,frequency,[az;-el],'Weights',weights);
            if updateTaper
                tx.Antenna.Taper=conj(weights);
            end
        else

            txAntennaGain=NaN;
        end
    end


    if txAntennaGain==-Inf
        stat=false;
        ebnoLevel=-Inf;
        receivedIsotropicPower=-Inf;
        rxInputPower=-Inf;
        return
    end


    txPower=tx.Power;
    bitRate=tx.BitRate;
    txSystemLoss=tx.SystemLoss;


    rxItrf2BodyTransform=rx.Itrf2BodyTransform;
    [az,el]=getRelativeAzimuthAndElevationAngle(...
    rxITRF,rxItrf2BodyTransform,txITRF);

    if rx.AntennaType==0
        dishDiameter=rx.DishDiameter;
        apertureEfficiency=rx.ApertureEfficiency;
        rxAntennaGain=satcom.satellitescenario.GaussianAntenna.getPattern(dishDiameter,apertureEfficiency,frequency,az,-el);
        rxGainMax=satcom.satellitescenario.GaussianAntenna.getPattern(dishDiameter,apertureEfficiency,frequency,0,90);
    elseif rx.AntennaType==1
        freqIdx=find(rx.AntennaPatternFrequency==frequency,1);
        patRx=rx.AntennaPattern(freqIdx);
        if sum(any(~isfinite(patRx(1).Gain)))>0
            rxAntennaGain=interp2(patRx(1).Azimuth,patRx(1).Elevation,patRx(1).Gain,wrapTo180(az),-el,'linear');
        else
            rxAntennaGain=interp2(patRx(1).Azimuth,patRx(1).Elevation,patRx(1).Gain,wrapTo180(az),-el,'spline');
        end
        rxGainMax=max(max(patRx(1).Gain));
    else
        if isempty(coder.target)

            originalTaper=rx.Antenna.Taper;
            rx.Antenna.Taper=rx.PhasedArrayWeightsDefault;
            gainPat=pattern(rx.Antenna,frequency);
            rxGainMax=max(max(gainPat));
            rx.Antenna.Taper=originalTaper;
            switch rx.PointingMode
            case 6

                weights=rx.PhasedArrayWeights;
            case 5


                weights=conj(rx.PhasedArrayWeightsDefault);
                if isscalar(weights)
                    weights=repmat(weights,getDOF(rx.Antenna),1);
                end
            otherwise

                stv=phased.SteeringVector('SensorArray',rx.Antenna);
                weights=stv(frequency,rx.PointingDirection);
            end


            rxAntennaGain=directivity(rx.Antenna,frequency,[az;-el],'Weights',weights);
            if updateTaper
                rx.Antenna.Taper=conj(weights);
            end
        else

            rxAntennaGain=NaN;
            rxGainMax=NaN;
        end
    end


    rxGbyTMax=rx.GainToNoiseTemperatureRatio;
    rxNoiseTemperature=rxGainMax-rxGbyTMax;


    requiredEbNo=rx.RequiredEbNo;
    rxSystemLoss=rx.SystemLoss;
    preReceiverLoss=rx.PreReceiverLoss;


    txEIRP=txPower-txSystemLoss+txAntennaGain;
    lightSpeed=299792458;
    boltzmann=1.3806504e-23;
    fsplDB=20*log10(4*pi*distance*frequency/lightSpeed);
    receivedIsotropicPower=txEIRP-fsplDB;
    receivedPowerAfterAntenna=receivedIsotropicPower+rxAntennaGain;
    rxInputPower=receivedPowerAfterAntenna-preReceiverLoss;
    cno=receivedPowerAfterAntenna-rxSystemLoss-rxNoiseTemperature-10*log10(boltzmann);
    ebnoLevel=cno-10*log10(bitRate)-60;
    margin=ebnoLevel-requiredEbNo;


    if margin>0
        stat=true;
    else
        stat=false;
    end
end

function blocking=isEarthBlocking(position1,position2)




    semiMajorAxis=complex(matlabshared.orbit.internal.Transforms.EarthEquatorialRadius);
    eccentricity=complex(matlabshared.orbit.internal.Transforms.EarthEccentricity);
    semiMinorAxis=semiMajorAxis*sqrt(1-(eccentricity^2));


    cposition1=complex(position1);
    x1=cposition1(1);
    y1=cposition1(2);
    z1=cposition1(3);


    cposition2=complex(position2);
    x2=cposition2(1);
    y2=cposition2(2);
    z2=cposition2(3);













































    lambda1=((((2*x1*(x1-x2))/(semiMajorAxis^2*(abs(x1-x2)^2+...
    abs(y1-y2)^2+abs(z1-z2)^2)^(1/2))+(2*y1*(y1-y2))/...
    (semiMajorAxis^2*(abs(x1-x2)^2+abs(y1-y2)^2+abs(z1-z2)^2)^...
    (1/2))+(2*z1*(z1-z2))/(semiMinorAxis^2*(abs(x1-x2)^2+...
    abs(y1-y2)^2+abs(z1-z2)^2)^(1/2)))^2-((4*(x1-x2)^2)/...
    (semiMajorAxis^2*(abs(x1-x2)^2+abs(y1-y2)^2+abs(z1-z2)^2))+...
    (4*(y1-y2)^2)/(semiMajorAxis^2*(abs(x1-x2)^2+abs(y1-y2)^2+...
    abs(z1-z2)^2))+(4*(z1-z2)^2)/(semiMinorAxis^2*(abs(x1-x2)^2+...
    abs(y1-y2)^2+abs(z1-z2)^2)))*(x1^2/semiMajorAxis^2+y1^2/...
    semiMajorAxis^2+z1^2/semiMinorAxis^2-1))^(1/2)+(2*x1*(x1-x2))/...
    (semiMajorAxis^2*(abs(x1-x2)^2+abs(y1-y2)^2+abs(z1-z2)^2)^...
    (1/2))+(2*y1*(y1-y2))/(semiMajorAxis^2*(abs(x1-x2)^2+...
    abs(y1-y2)^2+abs(z1-z2)^2)^(1/2))+(2*z1*(z1-z2))/...
    (semiMinorAxis^2*(abs(x1-x2)^2+abs(y1-y2)^2+abs(z1-z2)^2)^...
    (1/2)))/((2*(x1-x2)^2)/(semiMajorAxis^2*(abs(x1-x2)^2+...
    abs(y1-y2)^2+abs(z1-z2)^2))+(2*(y1-y2)^2)/(semiMajorAxis^2*...
    (abs(x1-x2)^2+abs(y1-y2)^2+abs(z1-z2)^2))+(2*(z1-z2)^2)/...
    (semiMinorAxis^2*(abs(x1-x2)^2+abs(y1-y2)^2+abs(z1-z2)^2)));
    lambda2=((2*x1*(x1-x2))/(semiMajorAxis^2*(abs(x1-x2)^2+...
    abs(y1-y2)^2+abs(z1-z2)^2)^(1/2))-(((2*x1*(x1-x2))/...
    (semiMajorAxis^2*(abs(x1-x2)^2+abs(y1-y2)^2+abs(z1-z2)^2)^...
    (1/2))+(2*y1*(y1-y2))/(semiMajorAxis^2*(abs(x1-x2)^2+...
    abs(y1-y2)^2+abs(z1-z2)^2)^(1/2))+(2*z1*(z1-z2))/...
    (semiMinorAxis^2*(abs(x1-x2)^2+abs(y1-y2)^2+abs(z1-z2)^2)^...
    (1/2)))^2-((4*(x1-x2)^2)/(semiMajorAxis^2*(abs(x1-x2)^2+...
    abs(y1-y2)^2+abs(z1-z2)^2))+(4*(y1-y2)^2)/(semiMajorAxis^2*...
    (abs(x1-x2)^2+abs(y1-y2)^2+abs(z1-z2)^2))+(4*(z1-z2)^2)/...
    (semiMinorAxis^2*(abs(x1-x2)^2+abs(y1-y2)^2+abs(z1-z2)^2)))*...
    (x1^2/semiMajorAxis^2+y1^2/semiMajorAxis^2+z1^2/semiMinorAxis^2-...
    1))^(1/2)+(2*y1*(y1-y2))/(semiMajorAxis^2*(abs(x1-x2)^2+...
    abs(y1-y2)^2+abs(z1-z2)^2)^(1/2))+(2*z1*(z1-z2))/...
    (semiMinorAxis^2*(abs(x1-x2)^2+abs(y1-y2)^2+abs(z1-z2)^2)^...
    (1/2)))/((2*(x1-x2)^2)/(semiMajorAxis^2*(abs(x1-x2)^2+...
    abs(y1-y2)^2+abs(z1-z2)^2))+(2*(y1-y2)^2)/(semiMajorAxis^2*...
    (abs(x1-x2)^2+abs(y1-y2)^2+abs(z1-z2)^2))+(2*(z1-z2)^2)/...
    (semiMinorAxis^2*(abs(x1-x2)^2+abs(y1-y2)^2+abs(z1-z2)^2)));


    blocking=false;
    if(imag(lambda1)==0)||(imag(lambda2)==0)
        lambda1Real=real(lambda1);
        lambda2Real=real(lambda2);
        if lambda1Real>0&&lambda2Real>0
            lambda=min(lambda1Real,lambda2Real);
            if lambda<norm(position2-position1)



                blocking=true;
            end
        else



            lambda=max(lambda1Real,lambda2Real);
            if lambda>0
                blocking=true;
            end
        end
    end
end

function[az,el,r]=getRelativeAzimuthAndElevationAngle(sourceITRF,sourceItrf2BodyTransform,targetITRF)

    coder.allowpcode('plain');


    relativePositionITRF=targetITRF-sourceITRF;


    relativePosition=sourceItrf2BodyTransform*relativePositionITRF;


    x=relativePosition(1);
    y=relativePosition(2);
    z=relativePosition(3);


    r=norm(relativePosition);

    if r==0

        az=0;
        el=0;
    else


        el=asind(max(min(-(z/r),1),-1));
        az=atan2d(y,x);
    end
end

function ang=wrapTo180(ang)


    coder.allowpcode('plain');

    indexAngOutside180=(ang>180)|(ang<=-180);
    ang(indexAngOutside180)=mod(ang(indexAngOutside180),360);
    indexAngGreaterThan180=ang>180;
    ang(indexAngGreaterThan180)=ang(indexAngGreaterThan180)-360;
end

function s=getSourceTargetDummyStruct



    coder.allowpcode('plain');

    anPatStruct=matlabshared.satellitescenario.internal.Simulator.antennaPatternStruct;

    s=coder.nullcopy(struct("Type",0,...
    "GrandParentType",0,...
    "GrandParentSimulatorID",0,...
    "PositionITRF",[0;0;0],...
    "Altitude",0,...
    "Itrf2BodyTransform",zeros(3),...
    "Frequency",0,...
    "DishDiameter",1,...
    "ApertureEfficiency",1,...
    "Antenna",0,...
    "AntennaPattern",anPatStruct,...
    "AntennaType",0,...
    "AntennaPatternFrequency",0,...
    "Power",0,...
    "BitRate",0,...
    "SystemLoss",0,...
    "PreReceiverLoss",0,...
    "GainToNoiseTemperatureRatio",0,...
    "RequiredEbNo",0,...
    'PointingMode',5,...
    'PhasedArrayWeights',1,...
    'PhasedArrayWeightsDefault',1,...
    'PointingDirection',[0;0]));
end


