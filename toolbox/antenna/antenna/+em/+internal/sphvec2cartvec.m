function cv=sphvec2cartvec(sv,th,phi)


    A=[sind(th)*cosd(phi),sind(th)*sind(phi),cosd(th);...
    -cosd(th)*cosd(phi),-cosd(th)*sind(phi),sind(th);...
    -sind(phi),cosd(phi),0];

    if isrow(sv)
        sv=sv';
    end
    cv=A\sv;