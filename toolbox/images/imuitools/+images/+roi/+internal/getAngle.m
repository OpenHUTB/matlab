function[center,r,theta]=getAngle(pos)












    diffVec=diff(pos);

    center=[mean(pos(:,1)),mean(pos(:,2))];
    r=hypot(diffVec(1),diffVec(2))/2;

    principalAxisVector=[diffVec,0];
    xAxisUnitVector=[1,0,0];

    eCross=cross(principalAxisVector,xAxisUnitVector);
    theta=atan2d(sqrt((eCross(1)^2)+(eCross(2)^2)+(eCross(3)^2)),dot(principalAxisVector,xAxisUnitVector));




    if diffVec(2)>0
        theta=360-theta;
    end

end