function[I]=solver_infdielarray(geom,const,obj,V,omega)





    h=obj.Element.Substrate.Thickness;
    mur=1;
    epr=obj.Element.Substrate.EpsilonR*(1+1j*obj.Element.Substrate.LossTangent);
    k0=omega/const.c;
    kn=sqrt(epr*mur)*k0;
    FacesTotal=geom.FacesTotal;
    EdgesTotal=geom.EdgesTotal;
    Center=geom.CenterF;

    if strcmpi(class(obj),'planeWaveExcitation')&&strcmpi(class(obj.Element),'infiniteArray')
        objElement=obj.Element;
        if isprop(objElement,'Element')&&strcmpi(class(objElement.Element),'pcbStack')
            dx=objElement.Element.BoardShape.Length;
            dy=objElement.Element.BoardShape.Width;
        else
            dx=objElement.Element.GroundPlaneLength;
            dy=objElement.Element.GroundPlaneWidth;
        end
        if isprop(objElement,'Element.Element')
            dx=objElement.Element.Element.GroundPlaneLength;
            dy=objElement.Element.Element.GroundPlaneWidth;
        end
        if objElement.SolverStruct.sumterms<20
            Nx=20;
        else
            Nx=objElement.SolverStruct.sumterms;
        end
        phi=pi/180*(objElement.ScanAzimuth);
        theta=pi/180*(90-objElement.ScanElevation);

        if strcmpi(class(objElement.Element),'pcbStack')&&...
            ~isempty(objElement.Element.ViaLocations)
            viaPresent=1;
        else
            viaPresent=0;
        end
    else
        if isprop(obj,'Element')&&~strcmpi(class(obj.Element),'pcbStack')
            dx=obj.Element.GroundPlaneLength;
            dy=obj.Element.GroundPlaneWidth;
        else
            dx=obj.Element.BoardShape.Length;
            dy=obj.Element.BoardShape.Width;
        end
        if isprop(obj,'Element.Element')
            dx=obj.Element.Element.GroundPlaneLength;
            dy=obj.Element.Element.GroundPlaneWidth;
        end
        if obj.SolverStruct.sumterms<20
            Nx=20;
        else
            Nx=obj.SolverStruct.sumterms;
        end
        phi=pi/180*(obj.ScanAzimuth);
        theta=pi/180*(90-obj.ScanElevation);

        if(isprop(obj.Element,'ViaLocations')||isfield(obj.Element,'ViaLocations'))&&~isempty(obj.Element.ViaLocations)
            viaPresent=1;
        else
            viaPresent=0;
        end
    end
    factor=4*pi/dx/dy;
    [X1,X2]=meshgrid(Center(:,1),Center(:,1));
    xminusxp=(X1-X2);
    [Y1,Y2]=meshgrid(Center(:,2),Center(:,2));
    yminusyp=(Y1-Y2);
    [Z1,Z2]=meshgrid(Center(:,3),Center(:,3));
    zminuszp=(Z1-Z2);

    if viaPresent==1
        cz=geom.NormalF(:,3);
        angtilt(:,1)=acosd(cz);
        angtilt=repmat(angtilt,[1,FacesTotal]);
    end
    Ny=Nx;
    Nxd=1;
    Nyd=1;
    I=zeros(EdgesTotal,length(omega))+1j*zeros(EdgesTotal,length(omega));
    for th=1:length(omega)
        u=sin(theta)*cos(phi);
        v=sin(theta)*sin(phi);
        omega=omega(th);
        k0=k0(th);
        kn=kn(th);

        Ge=zeros(FacesTotal,FacesTotal);
        Gm=zeros(FacesTotal,FacesTotal);

        if viaPresent==1
            for m=-Nx:Nx
                for n=-Ny:Ny
                    alpham=(2*pi*m/dx+k0*u);
                    betan=(2*pi*n/dy+k0*v);
                    gammaz=+sqrt(alpham^2+betan^2-k0^2);
                    ktdotrho=alpham*xminusxp+betan*yminusyp;
                    kndotz=gammaz*zminuszp;
                    ktdotrho=ktdotrho.*(cosd(angtilt)).^2+kndotz.*(sind(angtilt)).^2;
                    kndotz=ktdotrho.*(sind(angtilt)).^2+kndotz.*(cosd(angtilt)).^2;
                    EXP=exp(1j*ktdotrho).*exp(-1j*kndotz);
                    [Qm,Qe]=function_INTEGRAND(alpham,betan,k0,kn,h,mur,epr);
                    Gm=Gm+factor*Qm*EXP;
                    Ge=Ge+factor*Qe*EXP;
                end
            end
        else

            for m=-Nx:Nx
                for n=-Ny:Ny
                    alpham=(2*pi*m/dx+k0*u);
                    betan=(2*pi*n/dy+k0*v);
                    EXP=exp(1j*alpham*xminusxp+1j*betan*yminusyp);
                    [Qm,Qe]=function_INTEGRAND(alpham,betan,k0,kn,h,mur,epr);
                    Gm=Gm+factor*Qm*EXP;
                    Ge=Ge+factor*Qe*EXP;
                end
            end
        end

        Gmd=zeros(FacesTotal,1);
        Ged=zeros(FacesTotal,1);
        for m=-Nxd:Nxd
            for n=-Nyd:Nyd
                mdx=m*dx;
                ndy=n*dy;
                [Gmp,Gep]=function_ZDIRECT_EFIE_POISSON_DIAG(geom,k0,h,epr,mur,u,v,mdx,ndy);
                Gmd=Gmd+Gmp(1:FacesTotal);
                Ged=Ged+Gep(1:FacesTotal);
            end
        end


        for p=1:FacesTotal
            Gm(p,p)=Gmd(p);
            Ge(p,p)=Ged(p);
        end
        Z=function_ZDIRECT_EFIE(geom,const,k0,Ge,Gm,obj.SolverStruct.RWG.feededge);
        Z=1j*omega(th)*Z;
        I1=Z\V;
        I(:,th)=I1;
    end
end

function[Qm,Qe]=function_INTEGRAND(alpha,beta,k0,kn,h,mur,epr)
    lambda=sqrt(alpha^2+beta^2);
    u0=+sqrt(lambda.^2-k0^2);
    un=+sqrt(lambda.^2-kn^2);
    Dtm=mur*u0+un*coth(un*h);
    Dte=epr*u0+un*tanh(un*h);
    Dtt=u0+mur*un*tanh(un*h);
    Qm=mur/Dtm;
    Qe=Dtt/(Dtm*Dte);
end

function[Gm,Ge]=function_ZDIRECT_EFIE_POISSON_DIAG(geom,k0,h,epr,mur,u,v,mdx,ndy)
    kn=sqrt(epr*mur)*k0;
    phasemn=k0*(mdx*u+ndy*v);
    rho=sqrt(mdx^2+ndy^2);

    H=0.05*k0;

    D=05*abs(kn);

    pointsperperiod=2048;

    period=2*pi/rho;

    N1=round(pointsperperiod*H/period);
    N1=max(N1,100);

    N2=round(pointsperperiod*D/period);
    N2=max(N2,100);

    N3=round(pointsperperiod*H/period);
    N3=max(N3,100);


    Gm=zeros(geom.FacesTotal,1);
    Ge=zeros(geom.FacesTotal,1);


    lambda=1j*linspace(0,H,N1);
    step=lambda(2)-lambda(1);
    u0=+sqrt(lambda.^2-k0^2);
    un=+sqrt(lambda.^2-kn^2);
    Dtm=mur*u0+un.*coth(un*h);
    Dte=epr*u0+un.*tanh(un*h);
    Dtt=u0+mur*un.*tanh(un*h);
    tempm=(mur*lambda./Dtm-mur/(mur+1));
    tempe=(lambda.*Dtt./(Dtm.*Dte)-1/(epr+1));
    Bessel=besselj(0,rho*lambda);
    IntegrandGm=2*Bessel.*tempm;
    IntegrandGe=2*Bessel.*tempe;
    Gm(:)=step*sum(IntegrandGm);
    Ge(:)=step*sum(IntegrandGe);


    lambda=1j*H+linspace(0,D,N2);
    step=lambda(2)-lambda(1);
    u0=+sqrt(lambda.^2-k0^2);
    un=+sqrt(lambda.^2-kn^2);
    Dtm=mur*u0+un.*coth(un*h);
    Dte=epr*u0+un.*tanh(un*h);
    Dtt=u0+mur*un.*tanh(un*h);
    tempm=(mur*lambda./Dtm-mur/(mur+1));
    tempe=(lambda.*Dtt./(Dtm.*Dte)-1/(epr+1));
    Bessel=besselj(0,rho*lambda);
    IntegrandGm=2*Bessel.*tempm;
    IntegrandGe=2*Bessel.*tempe;
    Gm(:)=Gm(:)+step*sum(IntegrandGm);
    Ge(:)=Ge(:)+step*sum(IntegrandGe);


    lambda=1j*H+D-1j*linspace(0,H,N3);
    step=lambda(2)-lambda(1);
    u0=+sqrt(lambda.^2-k0^2);
    un=+sqrt(lambda.^2-kn^2);
    Dtm=mur*u0+un.*coth(un*h);
    Dte=epr*u0+un.*tanh(un*h);
    Dtt=u0+mur*un.*tanh(un*h);
    tempm=(mur*lambda./Dtm-mur/(mur+1));
    tempe=(lambda.*Dtt./(Dtm.*Dte)-1/(epr+1));
    Bessel=besselj(0,rho*lambda);
    IntegrandGm=2*Bessel.*tempm;
    IntegrandGe=2*Bessel.*tempe;
    Gm(:)=Gm(:)+step*sum(IntegrandGm);
    Ge(:)=Ge(:)+step*sum(IntegrandGe);


    Gm(:)=+Gm(:)+2*mur/(mur+1)*(1/rho);
    Ge(:)=+Ge(:)+2/(epr+1)*(1/rho);


    if(mdx==0)&&(ndy==0)
        for m=1:geom.FacesTotal
            Gm(m)=2*mur/(mur+1)*(geom.IS(m)-1j*k0);
        end
        for m=1:geom.FacesTotal
            Ge(m)=2/(epr+1)*(geom.IS(m)-1j*k0);
        end
    end
    Gm=exp(1j*phasemn)*Gm;
    Ge=exp(1j*phasemn)*Ge;
end

function Z=function_ZDIRECT_EFIE(geom,const,k0,Ge,Gm,feededge)
    omega=const.c*k0;
    EdgesTotal=geom.EdgesTotal;

    geom.FCRhoP(feededge,:)=-geom.FCRhoP(feededge,:);

    RhoPP=zeros(EdgesTotal,EdgesTotal);
    RhoPM=zeros(EdgesTotal,EdgesTotal);
    RhoMP=zeros(EdgesTotal,EdgesTotal);
    RhoMM=zeros(EdgesTotal,EdgesTotal);
    for m=1:EdgesTotal
        RhoPP(m,:)=sum(geom.FCRhoP.*repmat(geom.FCRhoP(m,:),[EdgesTotal,1]),2);
        RhoPM(m,:)=sum(geom.FCRhoP.*repmat(geom.FCRhoM(m,:),[EdgesTotal,1]),2);
        RhoMP(m,:)=sum(geom.FCRhoM.*repmat(geom.FCRhoP(m,:),[EdgesTotal,1]),2);
        RhoMM(m,:)=sum(geom.FCRhoM.*repmat(geom.FCRhoM(m,:),[EdgesTotal,1]),2);
    end
    PP=Ge(geom.TriP,geom.TriP);
    PM=Ge(geom.TriP,geom.TriM);
    MP=Ge(geom.TriM,geom.TriP);
    MM=Ge(geom.TriM,geom.TriM);

    PP(feededge,:)=-PP(feededge,:);
    PP(:,feededge)=-PP(:,feededge);
    PM(feededge,:)=-PM(feededge,:);
    MP(:,feededge)=-MP(:,feededge);

    Z=+1/(4*pi*1j*omega*const.epsilon)*(PP-PM-MP+MM);
    Z=Z+1j*omega*const.mu/(16*pi)*(...
    Gm(geom.TriP,geom.TriP).*RhoPP+...
    Gm(geom.TriP,geom.TriM).*RhoMP+...
    Gm(geom.TriM,geom.TriP).*RhoPM+...
    Gm(geom.TriM,geom.TriM).*RhoMM);
    AA=1./geom.EdgeLength;
    BB=geom.EdgeLength';
    ma=size(AA,1);
    na=size(AA,2);
    mb=size(BB,1);
    nb=size(BB,2);
    AA=reshape(AA,1,ma,1,na);
    BB=reshape(BB,mb,1,nb,1);
    EdgeLengthkron=reshape(AA.*BB,ma*mb,na*nb);

    Z=Z.*EdgeLengthkron;
end