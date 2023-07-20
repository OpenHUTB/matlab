function result=doSplineJunctionIntersect(spline,junction)


    result=false;

    if isempty(spline)||isempty(junction)
        return;
    end

    radiusJunction=junction.Position.Radius;
    centerJunctionX=junction.Position.Center(1);
    centerJunctionY=junction.Position.Center(2);


    distance=realmax;
    [startX,startY,endX,endY]=deal(0);
    for n=1:length(spline)-1
        midX=mean([spline(n,1),spline(n+1,1)]);
        midY=mean([spline(n,2),spline(n+1,2)]);
        d=sqrt((centerJunctionX-midX)^2+(centerJunctionY-midY)^2);
        if d<distance
            distance=d;
            startX=spline(n,1);
            startY=spline(n,2);
            endX=spline(n+1,1);
            endY=spline(n+1,2);


        end
    end



    P=struct('x',startX,'y',startY);
    Q=struct('x',endX,'y',endY);
    C=struct('x',centerJunctionX,'y',centerJunctionY);


    P2Q=getVector(P.x,P.y,Q.x,Q.y);
    lenP2Q=getLength(P2Q);



    C2P=getVector(C.x,C.y,P.x,P.y);
    lenC2P=getLength(C2P);

    C2Q=getVector(C.x,C.y,Q.x,Q.y);
    lenC2Q=getLength(C2Q);

    if radiusJunction>=lenC2Q||...
        radiusJunction>=lenC2P




        result=true;
        return;
    end

    if lenC2Q>lenP2Q&&lenC2P>lenP2Q

        return;
    end


    unitP2Q=getUnitVector(P2Q);
    if(lenC2Q>lenC2P)
        lenProjection=getDotProduct(unitP2Q,C2P);
        lenVecC2=lenC2P;
    else
        lenProjection=getDotProduct(unitP2Q,C2Q);
        lenVecC2=lenC2Q;
    end

    shortestDistance=sqrt(lenVecC2^2-lenProjection^2);


    if(radiusJunction>=shortestDistance)







        result=true;
        return;
    end

end

function vector=getVector(startX,startY,endX,endY)
    vector=struct('x',endX-startX,'y',endY-startY);
end

function unitVector=getUnitVector(vector)
    vLen=getLength(vector);
    unitVector=vector;
    unitVector.x=vector.x/vLen;
    unitVector.y=vector.y/vLen;
end

function lengthVector=getLength(vector)
    lengthVector=sqrt(vector.x^2+vector.y^2);
end

function dotProduct=getDotProduct(vector1,vector2)
    dotProduct=(vector1.x*vector2.x)+(vector1.y*vector2.y);
end

