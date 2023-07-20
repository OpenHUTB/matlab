function[Points,phi,theta]=calcpointsinspace(phi1,theta1,R,coord)


    if strcmpi(coord,'uv')
        [theta,phi]=em.internal.uv2thetaphi(theta1,phi1);
    else
        [theta,phi]=meshgrid(theta1,phi1);
    end

    [mp,np]=size(phi);
    [mt,nt]=size(theta);
    phi=phi(:);
    theta=theta(:);
    [x,y,z]=antennashared.internal.sph2cart(phi,theta,R);
    Points=[x';y';z'];
    phi=reshape(phi,mp,np);
    theta=reshape(theta,mt,nt);








end

