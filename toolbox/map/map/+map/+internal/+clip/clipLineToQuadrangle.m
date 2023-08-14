function[latc,lonc,Ic]=clipLineToQuadrangle(lat,lon,south,north,west,east)














    I=(1:length(lat))';
    lat=lat(:);
    lon=lon(:);
    [Ia,lata,lona]=map.internal.clip.removeExtraNaNs(I,lat,lon);







    if(south>-90)||(north<90)
        [Ia,~]=map.internal.clip.clipIndexedSequence(Ia,lata,south,north);
        lona=map.internal.clip.interpolateWithIndex(lon,Ia,@interpolateCircular);
    end



    [lonc,Ic]=map.internal.clip.cutSequenceOnCircle(west,lona,Ia);


    if(east-west~=360)
        [Ic,lonc]=map.internal.clip.clipIndexedSequence(Ic,lonc,west,east);
    end


    latc=map.internal.clip.interpolateWithIndex(lat,Ic);


    latc(latc<south)=south;
    latc(latc>north)=north;
end


function theta=interpolateCircular(theta0,theta1,f)











    dtheta=wrapTo180(theta1-theta0);
    theta=wrapTo180(theta0+f.*dtheta);
end
