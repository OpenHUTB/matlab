function geographicCoordinates=itrf2geographic(itrf)%#codegen










    if coder.target('MATLAB')
        geographicCoordinates=matlabshared.orbit.internal.Transforms.cg_itrf2geographic(itrf);
        return
    end

    coder.allowpcode('plain');



    x=itrf(1,:);
    y=itrf(2,:);
    z=itrf(3,:);


    R=6378137;
    e=0.081819221456;


    r=vecnorm([x;y;z]);
    latSpherical=asin(max(min(z./r,1),-1));
    lonSpherical=atan2(y,x);


    altitude=zeros(size(latSpherical));

    lat90Idx=abs(latSpherical)==pi/2;
    latGeodetic=latSpherical;
    latGeodetic(lat90Idx)=pi/2;
    b=R*sqrt(1-(e^2));
    altitude(lat90Idx)=r(lat90Idx)-b;

    r_delta=r(~lat90Idx).*cos(latSpherical(~lat90Idx));
    fzeroOptions=coder.const(optimset('TolX',1e-10));
    latGeodetic(~lat90Idx)=arrayfun(@(loc_r,loc_rdelta,loc_lat)...
    fzero(@objectiveFunctionToCalculateGeodeticLatitude,...
    [-pi/2,pi/2],fzeroOptions,...
    loc_r,loc_rdelta,R,e,loc_lat),r(~lat90Idx),r_delta,latSpherical(~lat90Idx));
    C=R./sqrt(1-((e.*sin(latGeodetic(~lat90Idx))).^2));
    altitude(~lat90Idx)=(r_delta./cos(latGeodetic(~lat90Idx)))-C;

    geographicCoordinates=[latGeodetic;lonSpherical;altitude];
end

function val=objectiveFunctionToCalculateGeodeticLatitude(...
    lat,r,r_delta,R,e,latSpherical)


    val=(((r*sin(latSpherical))+((R/sqrt(1-...
    ((e*sin(lat))^2)))*(e^2)*sin(lat)))/r_delta)-tan(lat);
end