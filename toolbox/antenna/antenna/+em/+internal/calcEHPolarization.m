function[E,H]=calcEHPolarization(points,polarization,Etemp,Htemp)










    [az,el,~]=cart2sph(points(1,:),points(2,:),points(3,:));
    phi=rad2deg(az);
    el=rad2deg(el);

    if strcmpi(polarization,'V')||strcmpi(polarization,'H')








        theta=90-el;

        if strcmpi(polarization,'V')
            E=Etemp(1,:).*cosd(theta(:)).'.*cosd(phi(:)).'+...
            Etemp(2,:).*cosd(theta(:)).'.*sind(phi(:)).'-Etemp(3,:).*sind(theta(:)).';


            E=-1*E;

            H=-Htemp(1,:).*sind(phi(:)).'+Htemp(2,:).*cosd(phi(:)).';
        elseif strcmpi(polarization,'H')
            E=-Etemp(1,:).*sind(phi(:)).'+Etemp(2,:).*cosd(phi(:)).';

            H=Htemp(1,:).*cosd(theta(:)).'.*cosd(phi(:)).'+...
            Htemp(2,:).*cosd(theta(:)).'.*sind(phi(:)).'-Htemp(3,:).*sind(theta(:)).';
            H=-1*H;
        end


    end
end