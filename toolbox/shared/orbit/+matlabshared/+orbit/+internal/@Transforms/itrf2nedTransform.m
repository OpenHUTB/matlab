function transformationMatrix=itrf2nedTransform(geographicCoordinates)%#codegen










    coder.allowpcode('plain');


    if isvector(geographicCoordinates)
        lat=geographicCoordinates(1);
        lon=geographicCoordinates(2);
    else
        lat=geographicCoordinates(1,:);
        lon=geographicCoordinates(2,:);
    end


    I_C_a=permute(cat(3,...
    cat(1,cos(lon),-sin(lon),zeros(size(lon))),...
    cat(1,sin(lon),cos(lon),zeros(size(lon))),...
    cat(1,zeros(size(lon)),zeros(size(lon)),ones(size(lon)))),...
    [3,1,2]);

    a_C_b=permute(cat(3,...
    cat(1,cos(lat),zeros(size(lat)),-sin(lat)),...
    cat(1,zeros(size(lat)),ones(size(lat)),zeros(size(lat))),...
    cat(1,sin(lat),zeros(size(lat)),cos(lat))),...
    [3,1,2]);

    b_C_c=[0,0,-1;0,1,0;1,0,0];

    transformationMatrix=permute(pagemtimes(pagemtimes(I_C_a,a_C_b),b_C_c),[2,1,3]);

end