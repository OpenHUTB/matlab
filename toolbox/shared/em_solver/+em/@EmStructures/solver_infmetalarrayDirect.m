function[I]=solver_infmetalarrayDirect(obj,V,omega)





    geom=obj.MesherStruct.geom;
    const=obj.MesherStruct.const;
    EdgesTotal=geom.EdgesTotal;
    FacesTotal=geom.FacesTotal;
    k0=omega/const.c;
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

    CenterFmn=Center';
    X1=repmat(CenterFmn(1,:),[FacesTotal,1]);
    X2=X1';
    Y1=repmat(CenterFmn(2,:),[FacesTotal,1]);
    Y2=Y1';
    Z1=repmat(CenterFmn(3,:),[FacesTotal,1]);
    Z2=Z1';
    xminusxp=(X1-X2);
    yminusyp=(Y1-Y2);
    zminuszp=(Z1-Z2);
    DIST=sqrt(xminusxp.^2+yminusyp.^2+zminuszp.^2);

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
        theta=pi/180*(90-obj.ScanElevation);
    end
    Ny=Nx;


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

    AA=1./geom.EdgeLength;
    BB=geom.EdgeLength';
    ma=size(AA,1);
    na=size(AA,2);
    mb=size(BB,1);
    nb=size(BB,2);
    AA=reshape(AA,1,ma,1,na);
    BB=reshape(BB,mb,1,nb,1);
    EdgeLengthkron=reshape(AA.*BB,ma*mb,na*nb);

    I=zeros(EdgesTotal,length(omega))+1j*zeros(EdgesTotal,length(omega));
    for th=1:length(omega)
        k0=k0(th);
        G0=exp(-1j*k0*DIST)./DIST;
        for m=1:geom.FacesTotal
            G0(m,m)=geom.IS(m)-1j*k0;
        end

        Gcenter=zeros(size(G0));
        Gborder=zeros(size(G0));
        for m=-Nx:Nx
            for n=-Ny:Ny
                if abs(m)>0||abs(n)>0
                    CenterFmnx=CenterFmn(1,:)+m*dx;
                    CenterFmny=CenterFmn(2,:)+n*dy;
                    X1=repmat(CenterFmnx,[FacesTotal,1]);
                    Y1=repmat(CenterFmny,[FacesTotal,1]);
                    xminusxp=(X1-X2);
                    yminusyp=(Y1-Y2);
                    DIST=sqrt(xminusxp.^2+yminusyp.^2+zminuszp.^2);
                    phasemn=k0*(m*dx*sin(theta)*cos(phi)+n*dy*sin(theta)*sin(phi));
                    Goff=(exp(-1j*k0*DIST)./DIST);
                    if abs(m)<Nx&&abs(n)<Ny
                        Gcenter=Gcenter+exp(1j*phasemn)*Goff;
                    else
                        Gborder=Gborder+exp(1j*phasemn)*Goff;
                    end
                end
            end
        end

        G=G0+Gcenter+1/2*Gborder;
        Z=+1/(4*pi*1j*omega*const.epsilon)*(...
        G(geom.TriP,geom.TriP)-...
        G(geom.TriP,geom.TriM)-...
        G(geom.TriM,geom.TriP)+...
        G(geom.TriM,geom.TriM));
        Z=Z+1j*omega*const.mu/(16*pi)*(...
        G(geom.TriP,geom.TriP).*RhoPP+...
        G(geom.TriP,geom.TriM).*RhoMP+...
        G(geom.TriM,geom.TriP).*RhoPM+...
        G(geom.TriM,geom.TriM).*RhoMM);
        Z=Z.*EdgeLengthkron;
        Z=1j*omega(th)*Z;
        I1=Z\V;
        I(:,th)=I1;
    end
end
