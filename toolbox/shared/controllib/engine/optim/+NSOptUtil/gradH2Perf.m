function J=gradH2Perf(SPECDATA,SYSDATA,tInfo,p)






    nx0=size(SYSDATA.Acl,1);
    [nzL,nwL]=size(SYSDATA.Dcl);
    iu=SPECDATA.Input;
    iy=SPECDATA.Output;
    Ts=tInfo.Ts;


    xPerf=SPECDATA.xPerf;
    nxr=numel(xPerf);
    sxr=SYSDATA.Scaling.sx(xPerf,:);


    Acl=SPECDATA.Acl;Bcl=SPECDATA.Bcl;Ccl=SPECDATA.Ccl;Dcl=SPECDATA.Dcl;
    nx=size(Acl,1);
    [ny,nu]=size(Dcl);
    RY=SPECDATA.RY;


    WL=SPECDATA.WL;
    if isempty(WL)
        bL=zeros(0,ny);dL=eye(ny);
    else
        bL=WL.b;dL=WL.d;
    end
    WR=SPECDATA.WR;
    if isempty(WR)
        cR=zeros(nu,0);dR=eye(nu);
    else
        cR=WR.c;dR=WR.d;
    end
    T=SPECDATA.Transform;
    if isempty(T)
        nxE=0;
    else
        nxE=size(T.E.a,1);
        bL=bL*T.F;dL=dL*T.F;
        cR=T.G*cR;dR=T.G*dR;
    end
    nxWL=size(bL,1);
    nxWR=size(cR,2);


    try
        if Ts>0
            RX=dlyapchol(Acl,Bcl,[],'noscale');

            U=zeros(nx0,nx+nu);
            V=zeros(nx0,nx+nu);
            Z=zeros(nzL,nx+nu);
            W=zeros(nwL,nx+nu);

            RYAB=RY*[Acl,Bcl];
            U(xPerf,:)=sxr.\(RY(:,nxWL+nxE+1:nxWL+nxE+nxr)'*RYAB);
            Z(iy,:)=bL'*(RY(:,1:nxWL)'*RYAB)+dL'*[Ccl,Dcl];

            V(xPerf,1:nx)=sxr.*(RX(:,nxWL+nxE+1:nxWL+nxE+nxr)'*RX);
            W(iu,:)=[cR*(RX(:,nx-nxWR+1:nx)'*RX),dR];
        else

            RX=lyapchol(Acl,Bcl,[],'noscale');

            U=zeros(nx0,nx);
            V=zeros(nx0,nx);
            Z=zeros(nzL,nx);
            W=zeros(nwL,nx);

            U(xPerf,:)=sxr.\(RY(:,nxWL+nxE+1:nxWL+nxE+nxr)'*RY);
            Z(iy,:)=bL'*(RY(:,1:nxWL)'*RY)+dL'*Ccl;

            V(xPerf,:)=sxr.*(RX(:,nxWL+nxE+1:nxWL+nxE+nxr)'*RX);
            W(iu,:)=cR*(RX(:,nx-nxWR+1:nx)'*RX)+dR*Bcl';
        end
        J=NSOptUtil.gradLFT(SYSDATA,tInfo,p,[U;Z],[V;W]);


        T=SPECDATA.Transform;
        fObj=SPECDATA.fObj;
        if isempty(T)||isempty(T.h)
            J=J/fObj;
        else
            fH2=T.h(fObj,-1);
            J=J*(T.h(fH2,1)/fH2);
        end
    catch



        J=NaN(size(p));
    end
