function[MagE,PhaseE]=calcefield(obj,freq,theta1,phi1,polarization,...
    Normalize,coord,R,calc_emb_pattern,ElemNumber)


    [Points,phi,theta]=em.internal.calcpointsinspace(phi1,theta1,R,coord);

    if isfield(obj.MesherStruct,'infGP')&&obj.MesherStruct.infGP==1
        hemisphere=1;
    else
        hemisphere=0;
    end

    E=calcEHfields(obj,freq,Points,calc_emb_pattern,hemisphere,[],ElemNumber);


    if isfield(obj.MesherStruct,'infGP')&&obj.MesherStruct.infGP==1
        PointsIndexOnIGP=find(Points(3,:)==0);
        E(1,PointsIndexOnIGP)=0;
        E(2,PointsIndexOnIGP)=0;
    end

    if strcmpi(polarization,'V')
        Etheta=E(1,:).*cosd(theta(:)).'.*cosd(phi(:)).'+...
        E(2,:).*cosd(theta(:)).'.*sind(phi(:)).'-E(3,:).*sind(theta(:)).';
        MagE=abs(Etheta)+eps;
        PhaseE=angle(Etheta);
    elseif strcmpi(polarization,'H')
        Ephi=-E(1,:).*sind(phi(:)).'+E(2,:).*cosd(phi(:)).';
        MagE=abs(Ephi)+eps;
        PhaseE=angle(Ephi);
    elseif strcmpi(polarization,'RHCP')
        Etheta=E(1,:).*cosd(theta(:)).'.*cosd(phi(:)).'+...
        E(2,:).*cosd(theta(:)).'.*sind(phi(:)).'-E(3,:).*sind(theta(:)).';
        Ephi=-E(1,:).*sind(phi(:)).'+E(2,:).*cosd(phi(:)).';
        Er=(Etheta+1i*Ephi)./sqrt(2);
        MagE=abs(Er)+eps;
        PhaseE=angle(Er);
    elseif strcmpi(polarization,'LHCP')
        Etheta=E(1,:).*cosd(theta(:)).'.*cosd(phi(:)).'+...
        E(2,:).*cosd(theta(:)).'.*sind(phi(:)).'-E(3,:).*sind(theta(:)).';
        Ephi=-E(1,:).*sind(phi(:)).'+E(2,:).*cosd(phi(:)).';
        Er=(Etheta-1i*Ephi)./sqrt(2);
        MagE=abs(Er)+eps;
        PhaseE=angle(Er);
    else
        MagEsquare=dot(E,E);
        MagE=sqrt(MagEsquare);
        PhaseE=angle(sum(E));
    end

    if Normalize
        MagE=MagE./max(MagE);
    end

end

