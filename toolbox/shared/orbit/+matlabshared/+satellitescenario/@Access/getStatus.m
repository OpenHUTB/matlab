function[statHistory,intervals,numIntervals]=getStatus(...
    sequence,nodeType,nodeIndex,sat,gs,sensor,simIDMemo,...
    timeHistoryArray,numSamples)%#codegen




    coder.allowpcode('plain');

    if isempty(coder.target)
        [statHistory,intervals,numIntervals]=matlabshared.satellitescenario.Access.cg_getStatus(...
        sequence,nodeType,nodeIndex,sat,gs,sensor,simIDMemo,timeHistoryArray,numSamples);
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

    source=struct("Type",0,...
    "GrandParentType",0,...
    "GrandParentSimulatorID",0,...
    "PositionITRF",[0;0;0],...
    "Altitude",0,...
    "Itrf2BodyTransform",zeros(3,3),...
    "MaxViewAngle",0);

    target=struct("Type",0,...
    "GrandParentType",0,...
    "GrandParentSimulatorID",0,...
    "PositionITRF",[0;0;0],...
    "Altitude",0,...
    "Itrf2BodyTransform",zeros(3,3),...
    "MaxViewAngle",0);


    statHistory=coder.nullcopy(false(1,numSamples));

    for sampleIdx=1:numSamples
        stat=false;

        for idx=1:numNodes-1

            switch nodeType(idx)
            case 1
                sourceStruct=sat(nodeIndex(idx));
                source.Type=sourceStruct.Type;
                source.GrandParentType=sourceStruct.GrandParentType;
                source.GrandParentSimulatorID=sourceStruct.GrandParentSimulatorID;
                source.PositionITRF=sourceStruct.PositionITRF(:,sampleIdx);
                source.Altitude=sourceStruct.Altitude(sampleIdx);
                source.Itrf2BodyTransform=sourceStruct.Itrf2BodyTransform(:,:,sampleIdx);
            case 2
                sourceStruct=gs(nodeIndex(idx));
                source.Type=sourceStruct.Type;
                source.GrandParentType=sourceStruct.GrandParentType;
                source.GrandParentSimulatorID=sourceStruct.GrandParentSimulatorID;
                source.PositionITRF=sourceStruct.PositionITRF(:,sampleIdx);
                source.Altitude=sourceStruct.Altitude(sampleIdx);
                source.Itrf2BodyTransform=sourceStruct.Itrf2BodyTransform(:,:,sampleIdx);
            otherwise
                sourceStruct=sensor(nodeIndex(idx));
                source.Type=sourceStruct.Type;
                source.GrandParentType=sourceStruct.GrandParentType;
                source.GrandParentSimulatorID=sourceStruct.GrandParentSimulatorID;
                source.PositionITRF=sourceStruct.PositionITRF(:,sampleIdx);
                source.Altitude=sourceStruct.Altitude(sampleIdx);
                source.Itrf2BodyTransform=sourceStruct.Itrf2BodyTransform(:,:,sampleIdx);
                source.MaxViewAngle=sourceStruct.MaxViewAngle;
            end



            switch nodeType(idx+1)
            case 1
                targetStruct=sat(nodeIndex(idx+1));
                target.Type=targetStruct.Type;
                target.GrandParentType=targetStruct.GrandParentType;
                target.GrandParentSimulatorID=targetStruct.GrandParentSimulatorID;
                target.PositionITRF=targetStruct.PositionITRF(:,sampleIdx);
                target.Altitude=targetStruct.Altitude(sampleIdx);
                target.Itrf2BodyTransform=targetStruct.Itrf2BodyTransform(:,:,sampleIdx);
            case 2
                targetStruct=gs(nodeIndex(idx+1));
                target.Type=targetStruct.Type;
                target.GrandParentType=targetStruct.GrandParentType;
                target.GrandParentSimulatorID=targetStruct.GrandParentSimulatorID;
                target.PositionITRF=targetStruct.PositionITRF(:,sampleIdx);
                target.Altitude=targetStruct.Altitude(sampleIdx);
                target.Itrf2BodyTransform=targetStruct.Itrf2BodyTransform(:,:,sampleIdx);
            otherwise
                targetStruct=sensor(nodeIndex(idx+1));
                target.Type=targetStruct.Type;
                target.GrandParentType=targetStruct.GrandParentType;
                target.GrandParentSimulatorID=targetStruct.GrandParentSimulatorID;
                target.PositionITRF=targetStruct.PositionITRF(:,sampleIdx);
                target.Altitude=targetStruct.Altitude(sampleIdx);
                target.Itrf2BodyTransform=targetStruct.Itrf2BodyTransform(:,:,sampleIdx);
                target.MaxViewAngle=targetStruct.MaxViewAngle;
            end


            stat=calculateStatus(source,target,sat,gs,sampleIdx,simIDMemo);
            if~stat
                break
            end
        end
        statHistory(sampleIdx)=stat;


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

function stat=calculateStatus(source,target,sat,gs,sampleIdx,simIDMemo)




    if isequal(source,target)
        stat=true;
        return
    end



    if source.GrandParentSimulatorID==target.GrandParentSimulatorID
        stat=true;
        return
    end



    if isequal(source.PositionITRF,target.PositionITRF)
        stat=true;
        return
    end


    grandParentSimID=source.GrandParentSimulatorID;
    grandParentType=source.GrandParentType;
    grandParentIndex=simIDMemo(grandParentSimID);
    sourceGrandParent=struct("Type",0,...
    "PositionITRF",[0;0;0],...
    "Altitude",0,...
    "Itrf2BodyTransform",zeros(3,3),...
    "MinElevationAngle",0);
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
    targetGrandParent=struct("Type",0,...
    "PositionITRF",[0;0;0],...
    "Altitude",0,...
    "Itrf2BodyTransform",zeros(3,3),...
    "MinElevationAngle",0);
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
        return
    end


    stat=calculateOneWayAccess(source,sourceGrandParent,target);


    if stat
        stat=calculateOneWayAccess(target,targetGrandParent,source);
    end
end

function stat=calculateOneWayAccess(source,sourceGrandParent,target)



    stat=true;




    if sourceGrandParent.Type==2
        sourcePositionITRF=sourceGrandParent.PositionITRF;
        sourceItrf2BodyTransform=sourceGrandParent.Itrf2BodyTransform;
        targetPositionITRF=target.PositionITRF;
        [~,el]=getRelativeAzimuthAndElevationAngle(sourcePositionITRF,...
        sourceItrf2BodyTransform,targetPositionITRF);
        if el<sourceGrandParent.MinElevationAngle
            stat=false;
            return
        end
    end






    if source.Type==3
        sourcePositionITRF=source.PositionITRF;
        sourceItrf2BodyTransform=source.Itrf2BodyTransform;
        targetPositionITRF=target.PositionITRF;
        [az,el]=getRelativeAzimuthAndElevationAngle(sourcePositionITRF,...
        sourceItrf2BodyTransform,targetPositionITRF);
        fovConeAngle=source.MaxViewAngle/2;
        unitVectorTargetRelativePosition=...
        [cosd(el)*cosd(az);cosd(el)*sind(az);-sind(el)];
        ang=acosd(max(min(dot(unitVectorTargetRelativePosition,[0;0;1]),1),-1));
        if ang>fovConeAngle
            stat=false;
        end
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

function[az,el]=getRelativeAzimuthAndElevationAngle(sourceITRF,sourceItrf2BodyTransform,targetITRF)


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


        el=asin(max(min(-(z/r),1),-1))*180/pi;
        az=mod(atan2(y,x),2*pi)*180/pi;
    end
end


