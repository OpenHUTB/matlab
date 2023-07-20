function[x,y,z]=sectors_marker_points(r,th,centeredMarkers)


    if centeredMarkers





        th_mk=filter([1,1]/2,1,th);
        th_mk=th_mk(2:end);
    else








        th_mk=th(1:end-1);
    end





    r(r<=0)=eps;

    x=r.*cos(th_mk);
    y=r.*sin(th_mk);
    z=0.25*ones(size(x));

end
