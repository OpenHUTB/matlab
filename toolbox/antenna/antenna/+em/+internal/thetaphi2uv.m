function[u,v]=thetaphi2uv(theta,phi)








    [theta1,phi1]=meshgrid(theta,phi);
    theta=theta1(:);
    phi=phi1(:);
    u=sind(theta).*cosd(phi);
    v=sind(theta).*sind(phi);

end

