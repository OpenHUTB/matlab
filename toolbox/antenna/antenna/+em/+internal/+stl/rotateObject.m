function[rp,rotatevect,theta]=rotateObject(trobj,triindx,feedPoint)
    points=trobj.Points;
    triang=trobj.ConnectivityList;
    triangPts=points(triang(triindx,:),:);
    centroidT=feedPoint;
    points=points-centroidT;triangPts=triangPts-centroidT;

    normalPlane=cross(triangPts(2,:)-triangPts(1,:),triangPts(3,:)-triangPts(1,:));

    normalPlane=normalPlane/norm(normalPlane);
    dir=[1,0,0;0,1,0;0,0,1;-1,0,0;0,-1,0;0,0,-1];
    cosvect=dir*normalPlane';
    [~,idx]=max(cosvect);
    if idx>3
        normalPlane=normalPlane*-1;
    end

    rotatevect=cross(normalPlane',[0,0,1]);
    if all(round(rotatevect,6)==[0,0,0])||all(round(rotatevect,6)==[0,0,1])
        rp=points;
        theta=0;rotatevect=rand(1,3);
    else
        theta=acosd(normalPlane(3)/sqrt(normalPlane*normalPlane'));
        vect=em.internal.rotateshape(normalPlane',[0,0,0],rotatevect,theta);
        vect=round(vect./norm(vect),5);
        if all(vect'==[0,0,1])
            rp=em.internal.rotateshape(points',[0,0,0],rotatevect,theta);
        else
            theta=-theta;
            rp=em.internal.rotateshape(points',[0,0,0],rotatevect,theta);
        end
        rp=rp';
    end


end