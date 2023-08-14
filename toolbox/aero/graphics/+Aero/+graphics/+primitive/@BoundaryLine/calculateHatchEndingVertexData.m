function hatchEndingVertexData=calculateHatchEndingVertexData(hObj,hatchStartingVertexData,prevVertexData,nextVertexData,hatchlength,hatchangle)





    if hObj.FlipBoundary_I
        thetap=pi;
    else
        thetap=0;
    end


    if hObj.HatchTangency_I


        dxyz=nextVertexData-prevVertexData;

        tangentAngle=atan2(dxyz(2,:),dxyz(1,:));
    else
        tangentAngle=zeros(1,size(hatchStartingVertexData,2));
    end

    theta=thetap-tangentAngle;


    sTheta=sin(theta);
    cTheta=cos(theta);

    a=cTheta;
    b=sTheta;
    c=-sTheta;
    d=cTheta;

    x1=cosd(hatchangle).*hatchlength;
    y1=sind(hatchangle).*hatchlength;

    xp=a.*x1+b.*y1;
    yp=c.*x1+d.*y1;
    zp=zeros(size(tangentAngle));

    hatchEndingVertexData=[xp;yp;zp]+hatchStartingVertexData;

end