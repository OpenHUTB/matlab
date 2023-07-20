function itrf=geographic2itrf(geographicCoordinates)%#codegen









    coder.allowpcode('plain');


    R=matlabshared.orbit.internal.Transforms.EarthEquatorialRadius;
    e=matlabshared.orbit.internal.Transforms.EarthEccentricity;


    geographicCoordinates=reshape(geographicCoordinates,3,[]);
    latGeographic=geographicCoordinates(1,:);
    lonGeographic=geographicCoordinates(2,:);
    altitude=geographicCoordinates(3,:);



    C=(R./sqrt(1-((e*sin(latGeographic)).^2)));
    r_delta=(altitude+C).*cos(latGeographic);
    z=(r_delta.*tan(latGeographic))-(C.*(e^2).*sin(latGeographic));
    lat=atan(z./r_delta);
    lon=lonGeographic;
    r=sqrt((z.^2)+(r_delta.^2));


    x=r.*cos(lat).*cos(lon);
    y=r.*cos(lat).*sin(lon);
    z=r.*sin(lat);

    itrf=[x;y;z];
end