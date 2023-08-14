function[I]=solver_infmetalarrayPoisson(obj,V,omega)





    geom=obj.MesherStruct.geom;
    const=obj.MesherStruct.const;
    mur=1;
    epr=1;
    k0=omega/const.c;
    kn=sqrt(epr*mur)*k0;
    FacesTotal=geom.FacesTotal;
    EdgesTotal=geom.EdgesTotal;
    Center=geom.CenterF;

    if isprop(obj,'Element')
        if strcmpi(class(obj.Element),'infiniteArray')
            dx=obj.Element.Element.GroundPlaneLength;
            dy=obj.Element.Element.GroundPlaneWidth;
        else
            dx=obj.Element.GroundPlaneLength;
            dy=obj.Element.GroundPlaneWidth;
        end
    end
    if isprop(obj,'Element.Element')
        dx=obj.Element.Element.GroundPlaneLength;
        dy=obj.Element.Element.GroundPlaneWidth;
    end
    factor=4*pi/dx/dy;
    [X1,X2]=meshgrid(Center(:,1),Center(:,1));
    xminusxp=(X1-X2);
    [Y1,Y2]=meshgrid(Center(:,2),Center(:,2));
    yminusyp=(Y1-Y2);
    if strcmpi(class(obj.Element),'infiniteArray')
        if obj.Element.SolverStruct.sumterms<20
            Nx=20;
        else
            Nx=obj.Element.SolverStruct.sumterms;
        end
        phi=pi/180*(obj.Element.ScanAzimuth);
        theta=pi/180*(90-obj.Element.ScanElevation);
    else
        if obj.SolverStruct.sumterms<20
            Nx=20;
        else
            Nx=obj.SolverStruct.sumterms;
        end
        phi=pi/180*(obj.ScanAzimuth);





        remElev=mod(obj.ScanElevation,90);
        if remElev==0
            theta=pi/180*(90-obj.ScanElevation-0.5);
        else
            theta=pi/180*(90-obj.ScanElevation);
        end
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
        for m=-Nx:Nx
            for n=-Ny:Ny
                alpham=(2*pi*m/dx+k0*u);
                betan=(2*pi*n/dy+k0*v);
                EXP=exp(1j*alpham*xminusxp+1j*betan*yminusyp);
                [Qm,Qe]=function_INTEGRAND(alpham,betan,k0);
                Gm=Gm+factor*Qm*EXP;
                Ge=Ge+factor*Qe*EXP;
            end
        end


        Gmd=zeros(FacesTotal,1);
        Ged=zeros(FacesTotal,1);
        for q=1:geom.FacesTotal
            Gmd(q)=geom.IS(q)-j*k0;
            Ged(q)=geom.IS(q)-j*k0;
            for m=-Nxd:Nxd
                for n=-Nyd:Nyd
                    mdx=m*dx;
                    ndy=n*dy;
                    DIST=sqrt(mdx^2+ndy^2);
                    if DIST>eps
                        phasemn=k0*(m*dx*sin(theta)*cos(phi)+n*dy*sin(theta)*sin(phi));
                        Gmd(q)=Gmd(q)+exp(j*phasemn)*exp(-j*k0*DIST)./DIST;
                        Ged(q)=Ged(q)+exp(j*phasemn)*exp(-j*k0*DIST)./DIST;
                    end
                end
            end
        end


        for p=1:FacesTotal
            Gm(p,p)=Gmd(p);
            Ge(p,p)=Ged(p);
        end
        Z=function_ZDIRECT_EFIE_PER(geom,const,k0,Ge,Gm);
        Z=1j*omega(th)*Z;
        I1=Z\V;
        I(:,th)=I1;
    end
end

function[Qm,Qe]=function_INTEGRAND(alpha,beta,k0)
    lambda=sqrt(alpha^2+beta^2);
    u0=+sqrt(lambda.^2-k0^2);
    Qm=0.5/u0;
    Qe=0.5/u0;
end

function Z=function_ZDIRECT_EFIE_PER(geom,const,k0,Ge,Gm)
    omega=const.c*k0;
    EdgesTotal=geom.EdgesTotal;

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



