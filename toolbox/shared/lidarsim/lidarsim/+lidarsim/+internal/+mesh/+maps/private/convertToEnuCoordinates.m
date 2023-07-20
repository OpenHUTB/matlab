function mesh=convertToEnuCoordinates(mesh,lat0,long0,h0)

    v=mesh.Vertices;
    lat=v(:,2);
    long=v(:,1);
    h=v(:,3);

    [x,y,z]=geodetic2enu(lat0,long0,h0,lat,long,h);
    mesh.Vertices=[x,y,z];

end

function[X,Y,Z]=geodetic2enu(lat0,lon0,h0,lat,lon,h)


    [X,Y,Z]=pgeodetic2enu(lat0,lon0,h0,lat,lon,h);
end

function[xEast,yNorth,zUp]=pgeodetic2enu(lat0,lon0,h0,lat,lon,h)

    [dx,dy,dz]=pecefOffset(lat0,lon0,h0,lat,lon,h);

    cosPhi=cosd(lat0);
    sinPhi=sind(lat0);
    cosLambda=cosd(lon0);
    sinLambda=sind(lon0);

    t=cosLambda.*dx+sinLambda.*dy;
    xEast=-sinLambda.*dx+cosLambda.*dy;

    zUp=cosPhi.*t+sinPhi.*dz;
    yNorth=-sinPhi.*t+cosPhi.*dz;

end

function[deltaX,deltaY,deltaZ]=pecefOffset(phi1,lambda1,h1,phi2,lambda2,h2)

    [a,~,e]=wgs84ModelParams;

    e2=e^2;

    s1=sind(phi1);
    c1=cosd(phi1);
    s2=sind(phi2);
    c2=cosd(phi2);

    p1=c1.*cosd(lambda1);
    p2=c2.*cosd(lambda2);

    q1=c1.*sind(lambda1);
    q2=c2.*sind(lambda2);

    w1=1./sqrt(1-e2*s1.^2);
    w2=1./sqrt(1-e2*s2.^2);

    deltaX=a*(p2.*w2-p1.*w1)+(h2.*p2-h1.*p1);
    deltaY=a*(q2.*w2-q1.*w1)+(h2.*q2-h1.*q1);
    deltaZ=(1-e2)*a*(s2.*w2-s1.*w1)+(h2.*s2-h1.*s1);

end

function[a,f,e]=wgs84ModelParams

    f=1/298.257223563;


    a=6378137;


    e=0.0818191908426215;

end