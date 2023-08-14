function[contoursHistory,statusHistory,intervals,numIntervals]=getContour(positionHistory,...
    latitudeHistory,longitudeHistory,altitudeHistory,attitudeHistory,...
    maxViewAngle,itrf2gcrfTransforms,numContourPoints,timeHistoryArray,...
    numSamples)%#codegen




    coder.allowpcode('plain');

    if isempty(coder.target)
        [contoursHistory,statusHistory,intervals,numIntervals]=matlabshared.satellitescenario.FieldOfView.cg_getContour(positionHistory,...
        latitudeHistory,longitudeHistory,altitudeHistory,attitudeHistory,...
        maxViewAngle,itrf2gcrfTransforms,numContourPoints,timeHistoryArray,...
        numSamples);
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


    coneHalfAngle=(maxViewAngle/2)*pi/180;

    contoursHistory=nan(numContourPoints,3,numSamples);
    statusHistory=false(1,numSamples);


    numIntervals=0;
    t=NaT;
    intervals=struct("StartTime",t,"EndTime",t);
    coder.varsize('intervals',[1,Inf],[0,1]);
    intervals(1)=[];

    stat=false;
    for idx=1:numSamples


        position=positionHistory(:,idx);
        latitude=latitudeHistory(idx);
        longitude=longitudeHistory(idx);
        altitude=altitudeHistory(idx);
        positionGeographic=...
        [latitude*pi/180;longitude*pi/180;altitude];
        attitudeParent=attitudeHistory(:,idx)*pi/180;


        roll=attitudeParent(1);
        pitch=attitudeParent(2);
        yaw=attitudeParent(3);
        zAxisDirection=[sin(yaw)*sin(roll)+cos(yaw)*sin(pitch)*cos(roll);...
        -cos(yaw)*sin(roll)+sin(yaw)*sin(pitch)*cos(roll);...
        cos(pitch)*cos(roll)];
        pitch=-asin(max(min(zAxisDirection(3),1),-1));
        roll=0;
        tol=1e-6;
        if abs(pitch)>((pi/2)-tol)
            yaw=0;
        else
            yaw=atan2(zAxisDirection(2),zAxisDirection(1));
        end
        attitude=[roll;pitch;yaw];


        gcrf2itrfTransform=itrf2gcrfTransforms(:,:,idx)';


        if idx==1
            previousStat=false;
        else
            previousStat=stat;
        end


        [contours,stat]=calculateContour(position,positionGeographic,...
        gcrf2itrfTransform,coneHalfAngle,attitude,numContourPoints);

        contoursHistory(:,:,idx)=contours;
        statusHistory(idx)=stat;

        if stat&&~previousStat



            numIntervals=numIntervals+1;



            existingIntervals=intervals;
            newIntervalStruct=struct("StartTime",timeHistory(idx),...
            "EndTime",t);
            intervals=[existingIntervals,newIntervalStruct];
        elseif~stat&&previousStat



            intervals(numIntervals).EndTime=timeHistory(idx-1);



            intervalStartTime=intervals(numIntervals).StartTime;
            intervalEndTime=intervals(numIntervals).EndTime;
            if abs(seconds(intervalEndTime-intervalStartTime))<matlabshared.satellitescenario.internal.Simulator.DatetimeComparisonTolerance
                intervals(numIntervals)=[];
                numIntervals=numIntervals-1;
            end
        end

        if(idx==numSamples)&&(numIntervals>0)&&isnat(intervals(end).EndTime)


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

function[contours,status]=calculateContour(position,...
    positionGeographic,gcrf2itrfTransform,coneHalfAngle,orientation,...
    numContourPoints)


    fieldOfViewTol=coder.const(optimset('TolX',1e-6));

    slant=[0;0;0];
    direction=[0;0;0];


    status=false;



    contours=nan(numContourPoints,3);


    if positionGeographic(3)<=0
        return
    end



    statusCondition=0;


    Ra=matlabshared.orbit.internal.Transforms.EarthEquatorialRadius;


    e=matlabshared.orbit.internal.Transforms.EarthEccentricity;


    Rb=Ra*sqrt(1-(e^2));


    itrf2nedTransform=...
    matlabshared.orbit.internal.Transforms.itrf2nedTransform(positionGeographic);

















    yaw=orientation(3);
    roll=orientation(1);


    positionITRF=gcrf2itrfTransform*position;
    x=positionITRF(1);
    y=positionITRF(2);
    z=positionITRF(3);


    thetas=linspace(0,2*pi,numContourPoints);

    for idx=1:numContourPoints

        pitch=orientation(2)+coneHalfAngle;


        slant=[cos(pitch)*cos(yaw);cos(pitch)*sin(yaw);-sin(pitch)];


        slant=itrf2nedTransform'*slant;


        pitch=orientation(2);


        direction=[cos(pitch)*cos(yaw);cos(pitch)*sin(yaw);-sin(pitch)];


        direction=itrf2nedTransform'*direction;


        theta=thetas(idx);


        slantRotated=(slant*cos(theta))-...
        cross(slant,direction*sin(theta))+...
        (dot(slant,direction)*direction*(1-cos(theta)));





        a=slantRotated(1);
        b=slantRotated(2);
        c=slantRotated(3);

        if Ra^2*a^2*z^2+Ra^2*b^2*z^2+Ra^2*c^2*x^2+Ra^2*c^2*y^2+...
            Rb^2*a^2*y^2+Rb^2*b^2*x^2<=Ra^4*c^2+Ra^2*Rb^2*a^2+...
            Ra^2*Rb^2*b^2+2*x*z*Ra^2*a*c+2*y*z*Ra^2*b*c+...
            2*x*y*Rb^2*a*b





            lambda1=-(Rb*real(sqrt(complex(Ra^4*c^2+Ra^2*Rb^2*a^2+Ra^2*Rb^2*b^2-...
            Ra^2*a^2*z^2+2*Ra^2*a*c*x*z-Ra^2*b^2*z^2+...
            2*Ra^2*b*c*y*z-Ra^2*c^2*x^2-Ra^2*c^2*y^2-...
            Rb^2*a^2*y^2+2*Rb^2*a*b*x*y-Rb^2*b^2*x^2)))+...
            Rb^2*a*x+Rb^2*b*y+Ra^2*c*z)/(Ra^2*c^2+Rb^2*a^2+...
            Rb^2*b^2);
            lambda2=-(Rb^2*a*x-Rb*real(sqrt(complex(Ra^4*c^2+Ra^2*Rb^2*a^2+...
            Ra^2*Rb^2*b^2-Ra^2*a^2*z^2+2*Ra^2*a*c*x*z-...
            Ra^2*b^2*z^2+2*Ra^2*b*c*y*z-Ra^2*c^2*x^2-...
            Ra^2*c^2*y^2-Rb^2*a^2*y^2+2*Rb^2*a*b*x*y-...
            Rb^2*b^2*x^2)))+Rb^2*b*y+Ra^2*c*z)/(Ra^2*c^2+...
            Rb^2*a^2+Rb^2*b^2);

            if(lambda1>0)&&(lambda2>0)






                lambda=min(lambda1,lambda2);


                contour=positionITRF+(lambda*slantRotated);


                contours(idx,:)=contour';


                statusCondition=statusCondition+1;
            end
        end
    end





    dummyVar=0;
    coder.varsize('dummyVar',[1,Inf],[0,1]);
    nanIndices=struct("Indices",dummyVar);
    coder.varsize('nanIndices',[1,Inf],[0,1]);
    nanIndices(1)=[];
    tempIdx=0;

    for idx=1:numContourPoints
        if idx==1
            if isnan(contours(idx,1))
                tempIdx=tempIdx+1;
                if tempIdx==1
                    nanIndices=struct("Indices",idx);
                else
                    nanIndices=[nanIndices,struct("Indices",idx)];
                end
            end
        elseif isnan(contours(idx,1))
            if~isnan(contours(idx-1,1))
                tempIdx=tempIdx+1;
                if tempIdx==1
                    nanIndices=struct("Indices",idx);
                else
                    nanIndices=[nanIndices,struct("Indices",idx)];
                end
            else
                nanIndices(tempIdx).Indices=[nanIndices(tempIdx).Indices,idx];
            end
        end
    end





    if tempIdx>1&&isnan(contours(1,1))&&isnan(contours(end,1))
        nanIndices(1).Indices=[nanIndices(1).Indices,nanIndices(end).Indices];
        nanIndices(end)=[];
    end

    if isempty(nanIndices)



        status=true;
    else


        for nanCellIdx=1:numel(nanIndices)
            nanIdx=nanIndices(nanCellIdx).Indices;
            if numel(nanIdx)==numContourPoints






                cosineAng=dot(direction,-positionITRF)/norm(positionITRF);
                if cosineAng>1
                    cosineAng=1;
                elseif cosineAng<-1
                    cosineAng=-1;
                end
                ang=acos(cosineAng);

                if ang<coneHalfAngle








                    status=true;










                    direction=itrf2nedTransform'*[0;0;1];


                    yaw=orientation(3);
                    for idx=1:numContourPoints

                        theta=thetas(idx);





                        newHalfAngle=fzero(@calcHalfAngle,[0,pi/2],...
                        fieldOfViewTol,...
                        positionITRF,itrf2nedTransform,theta,yaw);


                        pitch=-(pi/2)+newHalfAngle;
                        roll=0;
                        newSlant=[cos(pitch)*cos(yaw);cos(pitch)*sin(yaw);-sin(pitch)];
                        newSlant=itrf2nedTransform'*newSlant;



                        slantRotated=(newSlant*cos(theta))-cross(newSlant,...
                        direction*sin(theta))+...
                        (dot(newSlant,direction)*direction*(1-cos(theta)));











                        a=slantRotated(1);
                        b=slantRotated(2);
                        c=slantRotated(3);
                        lambda1=-(Rb*real(sqrt(complex((Ra^4*c^2+Ra^2*Rb^2*a^2+...
                        Ra^2*Rb^2*b^2-Ra^2*a^2*z^2+2*Ra^2*a*c*x*z-...
                        Ra^2*b^2*z^2+2*Ra^2*b*c*y*z-Ra^2*c^2*x^2-...
                        Ra^2*c^2*y^2-Rb^2*a^2*y^2+2*Rb^2*a*b*x*y-...
                        Rb^2*b^2*x^2))))+Rb^2*a*x+Rb^2*b*y+...
                        Ra^2*c*z)/(Ra^2*c^2+Rb^2*a^2+Rb^2*b^2);
                        lambda2=-(Rb^2*a*x-Rb*real(sqrt(complex((Ra^4*c^2+Ra^2*Rb^2*a^2+...
                        Ra^2*Rb^2*b^2-Ra^2*a^2*z^2+2*Ra^2*a*c*x*z-...
                        Ra^2*b^2*z^2+2*Ra^2*b*c*y*z-Ra^2*c^2*x^2-...
                        Ra^2*c^2*y^2-Rb^2*a^2*y^2+2*Rb^2*a*b*x*y-...
                        Rb^2*b^2*x^2))))+Rb^2*b*y+...
                        Ra^2*c*z)/(Ra^2*c^2+Rb^2*a^2+Rb^2*b^2);
                        lambda=min(lambda1,lambda2);


                        contour=positionITRF+(lambda*slantRotated);


                        contours(idx,:)=contour';
                    end
                end
            else





                if(numel(nanIdx)==1)||...
                    ((numel(nanIdx)==2)&&nanIdx(1)==1&&...
                    nanIdx(2)==numContourPoints)






                    theta=thetas(nanIdx(1));


                    slantRotated=(slant*cos(theta))-...
                    cross(slant,direction*sin(theta))+...
                    (dot(slant,direction)*direction*(1-cos(theta)));


                    slantRotatedNED=(itrf2nedTransform)*slantRotated;


                    yaw=mod(atan2(slantRotatedNED(2),slantRotatedNED(1)),2*pi);




                    theta=0;
                    newHalfAngle=fzero(@calcHalfAngle,[0,pi/2],...
                    fieldOfViewTol,...
                    positionITRF,itrf2nedTransform,theta,yaw);


                    pitch=-(pi/2)+newHalfAngle;
                    roll=0;
                    newSlant=[cos(pitch)*cos(yaw);cos(pitch)*sin(yaw);-sin(pitch)];
                    newSlant=itrf2nedTransform'*newSlant;


                    slantRotated=newSlant;










                    a=slantRotated(1);
                    b=slantRotated(2);
                    c=slantRotated(3);
                    lambda1=-(Rb*real(sqrt(complex((Ra^4*c^2+Ra^2*Rb^2*a^2+Ra^2*Rb^2*b^2-...
                    Ra^2*a^2*z^2+2*Ra^2*a*c*x*z-Ra^2*b^2*z^2+...
                    2*Ra^2*b*c*y*z-Ra^2*c^2*x^2-Ra^2*c^2*y^2-...
                    Rb^2*a^2*y^2+2*Rb^2*a*b*x*y-Rb^2*b^2*x^2))))+...
                    Rb^2*a*x+Rb^2*b*y+Ra^2*c*z)/(Ra^2*c^2+Rb^2*a^2+...
                    Rb^2*b^2);
                    lambda2=-(Rb^2*a*x-Rb*real(sqrt(complex((Ra^4*c^2+Ra^2*Rb^2*a^2+...
                    Ra^2*Rb^2*b^2-Ra^2*a^2*z^2+2*Ra^2*a*c*x*z-...
                    Ra^2*b^2*z^2+2*Ra^2*b*c*y*z-Ra^2*c^2*x^2-...
                    Ra^2*c^2*y^2-Rb^2*a^2*y^2+2*Rb^2*a*b*x*y-...
                    Rb^2*b^2*x^2))))+Rb^2*b*y+Ra^2*c*z)/(Ra^2*c^2+...
                    Rb^2*a^2+Rb^2*b^2);
                    lambda=min(lambda1,lambda2);


                    contour=positionITRF+(lambda*slantRotated);

                    if isscalar(nanIdx)



                        contours(nanIdx,:)=contour';
                    else



                        contours(nanIdx(1),:)=contour';
                        contours(nanIdx(2),:)=contour';
                    end


                    status=true;
                else











                    startIdx=nanIdx(1)-1;


                    endIdx=nanIdx(end)+1;


                    diffNanIdx=diff(nanIdx);









                    equallySpaced=true;
                    for idx=1:numel(diffNanIdx)
                        if diffNanIdx(idx)~=1
                            equallySpaced=false;
                            startIdx=nanIdx(idx+1)-1;
                            endIdx=nanIdx(idx)+1;
                            break
                        end
                    end



                    dTheta=thetas(2)-thetas(1);
                    ftheta1_1=calcTheta(thetas(startIdx),positionITRF,...
                    itrf2nedTransform,coneHalfAngle,orientation);
                    ftheta1_2=calcTheta(thetas(startIdx)+dTheta,positionITRF,...
                    itrf2nedTransform,coneHalfAngle,orientation);
                    if sign(ftheta1_1)==sign(ftheta1_2)
                        theta1=thetas(startIdx);
                    else
                        theta1=fzero(@calcTheta,[thetas(startIdx),...
                        thetas(startIdx)+dTheta],...
                        fieldOfViewTol,...
                        positionITRF,itrf2nedTransform,coneHalfAngle,...
                        orientation);
                    end

                    ftheta2_1=calcTheta(thetas(endIdx)-dTheta,positionITRF,...
                    itrf2nedTransform,coneHalfAngle,orientation);
                    ftheta2_2=calcTheta(thetas(endIdx),positionITRF,...
                    itrf2nedTransform,coneHalfAngle,orientation);
                    if sign(ftheta2_1)==sign(ftheta2_2)
                        theta2=thetas(endIdx);
                    else
                        theta2=fzero(@calcTheta,[thetas(endIdx)-dTheta,...
                        thetas(endIdx)],...
                        fieldOfViewTol,...
                        positionITRF,itrf2nedTransform,coneHalfAngle,...
                        orientation);
                    end




                    theta=theta1;
                    slantRotated1=(slant*cos(theta))-...
                    cross(slant,direction*sin(theta))+...
                    (dot(slant,direction)*direction*(1-cos(theta)));
                    theta=theta2;
                    slantRotated2=(slant*cos(theta))-...
                    cross(slant,direction*sin(theta))+...
                    (dot(slant,direction)*direction*(1-cos(theta)));


                    slantRotated1=itrf2nedTransform*slantRotated1;
                    slantRotated2=itrf2nedTransform*slantRotated2;


                    yaw1=mod(atan2(slantRotated1(2),slantRotated1(1)),2*pi);
                    yaw2=mod(atan2(slantRotated2(2),slantRotated2(1)),2*pi);






                    if yaw2<yaw1
                        yaw2=2*pi+yaw2;
                    end

                    if equallySpaced




                        nanThetas=linspace(0,yaw2-yaw1,numel(nanIdx));



                        contourNaN=zeros(numel(nanIdx),3);
                    else







                        nanThetas=linspace(0,yaw2-yaw1,numel(nanIdx)-1);



                        contourNaN=zeros(numel(nanIdx)-1,3);
                    end







                    newDirection=itrf2nedTransform'*[0;0;1];

                    for idx=1:numel(nanThetas)

                        theta=nanThetas(idx);




                        newHalfAngle=fzero(@calcHalfAngle,[0,pi/2],...
                        fieldOfViewTol,...
                        positionITRF,itrf2nedTransform,theta,yaw1);


                        pitch=-(pi/2)+newHalfAngle;
                        roll=0;
                        newSlant=[cos(pitch)*cos(yaw1);cos(pitch)*sin(yaw1);-sin(pitch)];
                        newSlant=itrf2nedTransform'*newSlant;


                        slantRotated=(newSlant*cos(theta))-...
                        cross(newSlant,newDirection*sin(theta))+...
                        (dot(newSlant,newDirection)*newDirection*(1-cos(theta)));











                        a=slantRotated(1);
                        b=slantRotated(2);
                        c=slantRotated(3);
                        lambda1=-(Rb*real(sqrt(complex(Ra^4*c^2+Ra^2*Rb^2*a^2+...
                        Ra^2*Rb^2*b^2-Ra^2*a^2*z^2+2*Ra^2*a*c*x*z-...
                        Ra^2*b^2*z^2+2*Ra^2*b*c*y*z-Ra^2*c^2*x^2-...
                        Ra^2*c^2*y^2-Rb^2*a^2*y^2+2*Rb^2*a*b*x*y-...
                        Rb^2*b^2*x^2)))+Rb^2*a*x+Rb^2*b*y+...
                        Ra^2*c*z)/(Ra^2*c^2+Rb^2*a^2+Rb^2*b^2);
                        lambda2=-(Rb^2*a*x-Rb*real(sqrt(complex(Ra^4*c^2+Ra^2*Rb^2*a^2+...
                        Ra^2*Rb^2*b^2-Ra^2*a^2*z^2+2*Ra^2*a*c*x*z-...
                        Ra^2*b^2*z^2+2*Ra^2*b*c*y*z-Ra^2*c^2*x^2-...
                        Ra^2*c^2*y^2-Rb^2*a^2*y^2+2*Rb^2*a*b*x*y-...
                        Rb^2*b^2*x^2)))+Rb^2*b*y+...
                        Ra^2*c*z)/(Ra^2*c^2+Rb^2*a^2+Rb^2*b^2);
                        lambda=min(real(lambda1),real(lambda2));


                        contour=positionITRF+(lambda*slantRotated);


                        contourNaN(idx,:)=contour';
                    end


                    if equallySpaced
                        contours(startIdx+1:endIdx-1,:)=contourNaN;
                    else
                        contours(startIdx+1:end,:)=...
                        contourNaN(1:(numContourPoints-startIdx),:);
                        contours(1:endIdx-1,:)=...
                        contourNaN((numContourPoints-startIdx):end,:);
                    end


                    status=true;
                end
            end
        end
    end
end

function f=calcTheta(theta,positionITRF,itrf2nedTransform,...
    coneHalfAngle,orientation)



    Ra=matlabshared.orbit.internal.Transforms.EarthEquatorialRadius;


    e=matlabshared.orbit.internal.Transforms.EarthEccentricity;


    Rb=Ra*sqrt(1-(e^2));


    yaw=orientation(3);
    pitch=orientation(2)+coneHalfAngle;
    roll=orientation(1);


    slant=[cos(pitch)*cos(yaw);cos(pitch)*sin(yaw);-sin(pitch)];
    slant=itrf2nedTransform'*slant;


    pitch=orientation(2);
    direction=[cos(pitch)*cos(yaw);cos(pitch)*sin(yaw);-sin(pitch)];
    direction=itrf2nedTransform'*direction;


    slantRotated=(slant*cos(theta))-cross(slant,direction*sin(theta))...
    +(dot(slant,direction)*direction*(1-cos(theta)));











    x=positionITRF(1);
    y=positionITRF(2);
    z=positionITRF(3);
    a=slantRotated(1);
    b=slantRotated(2);
    c=slantRotated(3);
    f=(Ra^2*a^2*z^2+Ra^2*b^2*z^2+Ra^2*c^2*x^2+Ra^2*c^2*y^2+...
    Rb^2*a^2*y^2+Rb^2*b^2*x^2)-(Ra^4*c^2+Ra^2*Rb^2*a^2+...
    Ra^2*Rb^2*b^2+2*x*z*Ra^2*a*c+2*y*z*Ra^2*b*c+2*x*y*Rb^2*a*b);
end

function f=calcHalfAngle(halfAngle,sourcePositionITRF,...
    itrf2nedTransform,theta,yaw)



    Ra=matlabshared.orbit.internal.Transforms.EarthEquatorialRadius;


    e=matlabshared.orbit.internal.Transforms.EarthEccentricity;


    Rb=Ra*sqrt(1-(e^2));


    pitch=-(pi/2)+halfAngle;
    roll=0;
    slant=[cos(pitch)*cos(yaw);cos(pitch)*sin(yaw);-sin(pitch)];
    slant=itrf2nedTransform'*slant;


    direction=itrf2nedTransform'*[0;0;1];


    slantRotated=(slant*cos(theta))-cross(slant,direction*sin(theta))...
    +(dot(slant,direction)*direction*(1-cos(theta)));






    x=sourcePositionITRF(1);
    y=sourcePositionITRF(2);
    z=sourcePositionITRF(3);
    a=slantRotated(1);
    b=slantRotated(2);
    c=slantRotated(3);
    f=(Ra^2*a^2*z^2+Ra^2*b^2*z^2+Ra^2*c^2*x^2+Ra^2*c^2*y^2+...
    Rb^2*a^2*y^2+Rb^2*b^2*x^2)-(Ra^4*c^2+Ra^2*Rb^2*a^2+...
    Ra^2*Rb^2*b^2+2*x*z*Ra^2*a*c+2*y*z*Ra^2*b*c+2*x*y*Rb^2*a*b);
end


