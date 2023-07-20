function w=aeroblkhwm14(lla,day,sec,ap,mdl)




%#codegen
    coder.allowpcode('plain');
    coder.license('checkout','Aerospace_Toolbox');
    coder.license('checkout','Aerospace_Blockset');


    lat=lla(1);
    lon=lla(2);
    alt=lla(3);




    secWithDayExcess=mod(day,1)*86400+sec;


    sec=mod(secWithDayExcess,86400);


    day=floor(day)+floor(secWithDayExcess/86400);

    if(alt<0||alt>500)
        if alt<0
            alt=0;
        else
            alt=500;
        end
    end
    if(ap<0||ap>400)
        if ap<0
            ap=0;
        else
            ap=400;
        end
    end



    if(lat>180||lat<-180)

        lat=mod(lat+180,360)-180;
    end
    if(lat>90||lat<-90)

        flat=abs(lat);
        lat=sign(lat)*(90-(flat-90));
        lon=lon+180;
    end

    if(lon>180||lon<-180)

        lon=mod(lon+180,360)-180;
    end

    w=hwm14(day,sec,alt,lat,lon,ap,mdl);

end

function w=hwm14(day,sec,alt,glat,glon,ap,mdl)

    nmaxhwm=0;
    omaxhwm=0;
    nmaxdwm=0;
    mmaxdwm=0;
    nmaxqdc=0;
    mmaxqdc=0;
    nmaxgeo=0;
    mmaxgeo=0;


    S=coder.load('hwm123114.mat');

    nbf=S.nbf;
    maxs=S.maxs;
    maxm=S.maxm;
    maxl=S.maxl;
    maxn=S.maxn;
    ncomp=S.ncomp;
    nlev=S.nlev;
    p=S.p;
    vnode=S.vnode;
    order=S.order;
    nb=S.nb;
    mparm=S.mparm;
    e1=S.e1;
    e2=S.e2;

    nnode=nlev+p;

    tparm=zeros(nbf,nlev+1);

    for k=1:nlev-p+1-2+1
        amaxs=order(1,k);
        amaxn=order(2,k);
        pmaxm=order(3,k);
        pmaxs=order(4,k);
        pmaxn=order(5,k);
        tmaxl=order(6,k);
        tmaxs=order(7,k);
        tmaxn=order(8,k);

        c=1;

        for n=1:amaxn
            tparm(c,k)=0.0;
            tparm(c+1,k)=-mparm(c+1,k);
            mparm(c+1,k)=0.0;
            c=c+2;
        end
        for s=1:amaxs
            for n=1:amaxn
                tparm(c,k)=0;
                tparm(c+1,k)=0;
                tparm(c+2,k)=-mparm(c+2,k);
                tparm(c+3,k)=-mparm(c+3,k);
                mparm(c+2,k)=0;
                mparm(c+3,k)=0;
                c=c+4;
            end
        end

        for m=1:pmaxm
            for n=m:pmaxn
                tparm(c,k)=mparm(c+2,k);
                tparm(c+1,k)=mparm(c+3,k);
                tparm(c+2,k)=-mparm(c,k);
                tparm(c+3,k)=-mparm(c+1,k);
                c=c+4;
            end
            for s=1:pmaxs
                for n=m:pmaxn
                    tparm(c,k)=mparm(c+2,k);
                    tparm(c+1,k)=mparm(c+3,k);
                    tparm(c+2,k)=-mparm(c,k);
                    tparm(c+3,k)=-mparm(c+1,k);
                    tparm(c+4,k)=mparm(c+6,k);
                    tparm(c+5,k)=mparm(c+7,k);
                    tparm(c+6,k)=-mparm(c+4,k);
                    tparm(c+7,k)=-mparm(c+5,k);
                    c=c+8;
                end
            end

        end

        for l=1:tmaxl
            for n=l:tmaxn
                tparm(c,k)=mparm(c+2,k);
                tparm(c+1,k)=mparm(c+3,k);
                tparm(c+2,k)=-mparm(c,k);
                tparm(c+3,k)=-mparm(c+1,k);
                c=c+4;
            end
            for s=1:tmaxs
                for n=l:tmaxn
                    tparm(c,k)=mparm(c+2,k);
                    tparm(c+1,k)=mparm(c+3,k);
                    tparm(c+2,k)=-mparm(c,k);
                    tparm(c+3,k)=-mparm(c+1,k);
                    tparm(c+4,k)=mparm(c+6,k);
                    tparm(c+5,k)=mparm(c+7,k);
                    tparm(c+6,k)=-mparm(c+4,k);
                    tparm(c+7,k)=-mparm(c+5,k);
                    c=c+8;
                end
            end
        end
    end



    maxo=max([max([maxs,maxm]),maxl]);
    omaxhwm=maxo;
    nmaxhwm=maxn;


    G=coder.load('hwmgd2qd14.mat');

    nterm=G.nterm;
    nmax=G.nmax;
    mmax=G.mmax;
    epoch=G.epoch;
    altg=G.altg;
    xcoeff=G.xcoeff';
    ycoeff=G.ycoeff';
    zcoeff=G.zcoeff';
    sh=zeros(nterm,1);
    shgradtheta=zeros(nterm,1);
    shgradphi=zeros(nterm,1);

    nmaxqdc=nmax;
    mmaxqdc=mmax;



    D=coder.load('dwm07b_104i.mat');

    nterm=D.nterm;
    mmaxdwm=D.mmax;
    nmaxdwm=D.lmax;
    termarr=D.termarr';
    coeffd=D.coeff;
    twidth=D.twidth;

    nmaxgeo=max([nmaxhwm,nmaxqdc]);
    mmaxgeo=max([omaxhwm,mmaxqdc]);

    nmax0=max([nmaxgeo,nmaxdwm]);
    mmax0=max([mmaxgeo,mmaxdwm]);


    anm=zeros(nmax0+1,mmax0+1);
    bnm=zeros(nmax0+1,mmax0+1);

    dnm=zeros(nmax0+1,mmax0+1);
    cmalf=zeros(mmax0+1,1);
    en=zeros(nmax0+1,1);
    marr=zeros(mmax0+1,1);
    narr=zeros(nmax0+1,1);

    [narr,en,marr,anm,bnm,cmalf,dnm]=initalf(nmax0,mmax0,narr,en,marr,anm,bnm,cmalf,dnm);

    gpbar=zeros(nmaxgeo+1,mmaxgeo+1);
    gvbar=zeros(nmaxgeo+1,mmaxgeo+1);
    gwbar=zeros(nmaxgeo+1,mmaxgeo+1);

    glatalf=-1;


    switch mdl

    case 0
        w=hwmqt(day,sec,alt,glat,glon,ap,maxs,maxm,maxl,maxn,...
        glatalf,gpbar,gvbar,gwbar,anm,bnm,dnm,marr,cmalf,...
        en,narr,nbf,p,nnode,vnode,e1,e2,nlev,nb,mparm,tparm,...
        order);

    case 1
        w=hwmqt(day,sec,alt,glat,glon,ap,maxs,maxm,maxl,maxn,...
        glatalf,gpbar,gvbar,gwbar,anm,bnm,dnm,marr,cmalf,...
        en,narr,nbf,p,nnode,vnode,e1,e2,nlev,nb,mparm,tparm,...
        order);
        if ap>=0.0
            dw=dwm07(day,sec,alt,glat,glon,ap,nmaxqdc,mmaxqdc,gpbar,gvbar,gwbar,...
            glatalf,anm,bnm,dnm,marr,cmalf,en,narr,...
            xcoeff,ycoeff,zcoeff,sh,shgradtheta,...
            shgradphi,nmaxgeo,mmaxgeo,nterm,termarr,coeffd,twidth,nmaxdwm,mmaxdwm);
            w=w+dw;

        end

    case 2
        w=dwm07(day,sec,alt,glat,glon,ap,nmaxqdc,mmaxqdc,gpbar,gvbar,gwbar,...
        glatalf,anm,bnm,dnm,marr,cmalf,en,narr,...
        xcoeff,ycoeff,zcoeff,sh,shgradtheta,...
        shgradphi,nmaxgeo,mmaxgeo,nterm,termarr,coeffd,twidth,nmaxdwm,mmaxdwm);

    otherwise
        w=[0;0];
    end
end

function[narr,en,marr,anm,bnm,cmalf,dnm]=initalf(nmax0,mmax0,narr,en,marr,anm,bnm,cmalf,dnm)

    for n=1:nmax0
        narr(n+1)=n;
        en(n+1)=sqrt(n*(n+1));
        anm(n+1,1)=sqrt((2*n-1)*(2*n+1))/narr(n+1);
        bnm(n+1,1)=sqrt(abs((2*n+1)*(n-1)*(n-1)/(2*n-3)))/narr(n+1);
    end
    for m=1:mmax0
        marr(m+1)=m;
        cmalf(m+1)=sqrt((2*m+1)/(2*m*m*(m+1)));
        for n=m+1:nmax0
            anm(n+1,m+1)=sqrt((2*n-1)*(2*n+1)*(n-1)/((n-m)*(n+m)*(n+1)));
            bnm(n+1,m+1)=sqrt((2*n+1)*(n+m-1)*(n-m-1)*(n-2)*(n-1)...
            /((n-m)*(n+m)*(2*n-3)*n*(n+1)));
            dnm(n+1,m+1)=sqrt((n-m)*(n+m)*(2*n+1)*(n-1)/((2*n-1)*(n+1)));
        end
    end

end


function w=hwmqt(iyd,sec,alt,glat,glon,ap,maxs,maxm,maxl,maxn,...
    glatalf,gpbar,gvbar,gwbar,anm,bnm,dnm,marr,cmalf,...
    en,narr,nbf,p,nnode,vnode,e1,e2,nlev,nb,mparm,tparm,...
    order)

    previous=-1.0*ones(6,1);
    bz=zeros(nbf,1);
    zwght=zeros(p+1,1);
    cseason=0;
    cwave=0;
    ctide=0;

    content=[true,true,true,true,true];
    component=[true,true];

    wavefactor=[1.0,1.0,1.0,1.0,1.0];
    tidefactor=[1.0,1.0,1.0,1.0,1.0];
    alttns=vnode(nlev-2+1);
    altsym=vnode(nlev-1+1);
    altiso=vnode(nlev+1);



    refresh=zeros(5,1);
    H=60.0;

    priornb=0;



    input=zeros(5,1);
    input(1)=rem(iyd,1000);
    input(2)=sec;
    input(3)=glon;
    input(4)=glat;
    input(5)=alt;
    twoPi=2*pi;
    deg2rad=pi/180;
    fs=zeros(maxs+1,3);
    fm=zeros(maxm+1,3);
    fl=zeros(maxl+1,3);

    if(input(1)~=previous(1))
        AA=input(1)*twoPi/365.25;
        for s=1:maxs+1
            BB=s*AA;
            fs(s,1)=cos(BB);
            fs(s,2)=sin(BB);
        end
        for s=1:5
            refresh(s)=true;
        end
        previous(1)=input(1);
    end



    if((input(2)~=previous(2))||(input(3)~=previous(3)))
        AA=mod(input(2)/3600+input(3)/15+48,24);
        BB=AA*twoPi/24;
        for l=1:maxl+1
            CC=l*BB;
            fl(l,1)=cos(CC);
            fl(l,2)=sin(CC);
        end
        refresh(3)=true;
        previous(2)=input(2);
    end



    if(input(3)~=previous(3))
        AA=input(3)*deg2rad;
        for m=1:maxm+1
            BB=m*AA;
            fm(m,1)=cos(BB);
            fm(m,2)=sin(BB);
        end
        refresh(2)=true;
        previous(3)=input(3);
    end



    theta=(90.0-input(4))*deg2rad;
    if(input(4)~=glatalf)
        AA=(90.0-input(4))*deg2rad;
        [gpbar,gvbar,gwbar]=alfbasis(maxn,maxm,AA,gpbar,gvbar,gwbar,anm,bnm,dnm,marr,...
        cmalf,en,narr);
        for s=1:4
            refresh(s)=true;
        end
        glatalf=input(4);
        previous(4)=input(4);
    end


    lev=0;
    if(input(5)~=previous(5))
        [lev,zwght]=vertwght(input(5),nnode,p,vnode,e1,e2,alttns,H,zwght);
        previous(5)=input(5);
    end



    u=0.0;
    v=0.0;

    for b=1:p+1
        if zwght(b)==0
            continue;
        end

        d=b+lev-1;

        if(priornb~=nb(d))
            for s=1:5
                refresh(s)=true;
            end
        end
        priornb=nb(d);

        amaxs=order(1,d);
        amaxn=order(2,d);
        pmaxm=order(3,d);
        pmaxs=order(4,d);
        pmaxn=order(5,d);
        tmaxl=order(6,d);
        tmaxs=order(7,d);
        tmaxn=order(8,d);

        c=1;



        if(refresh(1)&&content(1))
            for n=1:amaxn
                bz(c)=-sin(n*theta);
                bz(c+1)=sin(n*theta);
                c=c+2;
            end
            for s=1:amaxs

                cs=fs(s,1);
                ss=fs(s,2);
                for n=1:amaxn
                    sc=sin(n*theta);
                    bz(c)=-sc*cs;
                    bz(c+1)=sc*ss;
                    bz(c+2)=sc*cs;
                    bz(c+3)=-sc*ss;
                    c=c+4;
                end
            end
            cseason=c;
        else
            c=cseason;
        end



        if(refresh(2)&&content(2))
            for m=1:pmaxm
                cm=fm(m,1)*wavefactor(m);
                sm=fm(m,2)*wavefactor(m);
                for n=m:pmaxn
                    vb=gvbar(n+1,m+1);
                    wb=gwbar(n+1,m+1);
                    bz(c)=-vb*cm;
                    bz(c+1)=vb*sm;
                    bz(c+2)=-wb*sm;
                    bz(c+3)=-wb*cm;
                    c=c+4;
                end
                for s=1:pmaxs
                    cs=fs(s,1);
                    ss=fs(s,2);
                    for n=m:pmaxn
                        vb=gvbar(n+1,m+1);
                        wb=gwbar(n+1,m+1);
                        bz(c)=-vb*cm*cs;
                        bz(c+1)=vb*sm*cs;
                        bz(c+2)=-wb*sm*cs;
                        bz(c+3)=-wb*cm*cs;
                        bz(c+4)=-vb*cm*ss;
                        bz(c+5)=vb*sm*ss;
                        bz(c+6)=-wb*sm*ss;
                        bz(c+7)=-wb*cm*ss;
                        c=c+8;
                    end
                end
                cwave=c;
            end
        else
            c=cwave;
        end



        if(refresh(3)&&content(3))
            for l=1:tmaxl
                cl=fl(l,1)*tidefactor(l);
                sl=fl(l,2)*tidefactor(l);
                for n=l:tmaxn
                    vb=gvbar(n+1,l+1);
                    wb=gwbar(n+1,l+1);
                    bz(c)=-vb*cl;
                    bz(c+1)=vb*sl;
                    bz(c+2)=-wb*sl;
                    bz(c+3)=-wb*cl;
                    c=c+4;
                end
                for s=1:tmaxs
                    cs=fs(s,1);
                    ss=fs(s,2);
                    for n=l:tmaxn
                        vb=gvbar(n+1,l+1);
                        wb=gwbar(n+1,l+1);
                        bz(c)=-vb*cl*cs;
                        bz(c+1)=vb*sl*cs;
                        bz(c+2)=-wb*sl*cs;
                        bz(c+3)=-wb*cl*cs;
                        bz(c+4)=-vb*cl*ss;
                        bz(c+5)=vb*sl*ss;
                        bz(c+6)=-wb*sl*ss;
                        bz(c+7)=-wb*cl*ss;
                        c=c+8;
                    end
                end
                ctide=c;
            end
        else
            c=ctide;
        end



        c=c-1;


        if(component(1))
            u=u+zwght(b)*dot(bz,mparm(:,d));
        end
        if(component(2))
            v=v+zwght(b)*dot(bz,tparm(:,d));
        end
    end
    w=zeros(2,1);
    w(1)=v;
    w(2)=u;

end

function[P,V,W]=alfbasis(nmax,mmax,theta,P,V,W,anm,bnm,dnm,marr,cm,en,narr)

    p00=0.70710678118654746;

    P(1,1)=p00;
    x=cos(theta);
    y=sin(theta);
    for m=2:mmax+1
        W(m,m)=cm(m)*P(m-1,m-1);
        P(m,m)=y*en(m)*W(m,m);
        for n=m+1:nmax+1
            W(n,m)=anm(n,m)*x*W(n-1,m)-bnm(n,m)*W(n-2,m);
            P(n,m)=y*en(n)*W(n,m);
            V(n,m)=narr(n)*x*W(n,m)-dnm(n,m)*W(n-1,m);
            W(n-2,m)=marr(m)*W(n-2,m);
        end
        W(nmax-1+1,m)=marr(m)*W(nmax-1+1,m);
        W(nmax+1,m)=marr(m)*W(nmax+1,m);
        V(m,m)=x*W(m,m);
    end
    P(2,1)=anm(2,1)*x*P(1,1);
    V(2,1)=-P(2,2);
    for n=3:nmax+1
        P(n,1)=anm(n,1)*x*P(n-1,1)-bnm(n,1)*P(n-2,1);
        V(n,1)=-P(n,2);
    end

end

function[iz,wght]=vertwght(alt,nnode,p,vnode,e1,e2,alttns,H,wght)

    iz=aeroblkfindspan(nnode-p-1,p,alt,vnode)-p;

    iz=min([iz,26+1]);

    wght(1)=aeroblkbspline(p,nnode,vnode,iz,alt);
    wght(2)=aeroblkbspline(p,nnode,vnode,iz+1,alt);
    if(iz<=25+1)
        wght(3)=aeroblkbspline(p,nnode,vnode,iz+2,alt);
        wght(4)=aeroblkbspline(p,nnode,vnode,iz+3,alt);
        return;
    end
    we=zeros(5,1);
    if(alt>alttns)
        we(1)=0.0;
        we(2)=0.0;
        we(3)=0.0;
        we(4)=exp(-(alt-alttns)/H);
        we(5)=1.0;
    else
        we(1)=aeroblkbspline(p,nnode,vnode,iz+2,alt);
        we(2)=aeroblkbspline(p,nnode,vnode,iz+3,alt);
        we(3)=aeroblkbspline(p,nnode,vnode,iz+4,alt);
        we(4)=0.0;
        we(5)=0.0;
    end
    wght(3)=dot(we,e1);
    wght(4)=dot(we,e2);
end

function dw=dwm07(iyd,sec,alt,glat,glon,ap,nmax,mmax,gpbar,gvbar,gwbar,...
    glatalf,anm,bnm,dnm,marr,cm,en,narr,...
    xcoeff,ycoeff,zcoeff,sh,shgradtheta,...
    shgradphi,nmaxgeo,mmaxgeo,nterm,termarr,coeff,twidth,nmaxout,mmaxout)

    f1e=0;
    f1n=0;
    f2e=0;
    f2n=0;
    mlon=0;
    mlat=0;
    mlt=0;
    glatlast=1e16;
    glonlast=1e16;
    daylast=1e16;
    utlast=1e16;
    aplast=1e16;
    talt=125;


    kp=0;
    if(ap~=aplast)
        kp=aptokp(ap);
    end


    if((glat~=glatlast)||(glon~=glonlast))
        [f1e,f1n,f2e,f2n,mlat,mlon]=gd2qd(glat,glon,glatalf,nmax,mmax,...
        gpbar,gvbar,gwbar,anm,bnm,dnm,marr,cm,en,narr,xcoeff,ycoeff,...
        zcoeff,sh,shgradtheta,shgradphi);
    end


    day=mod(iyd,1000);
    ut=sec/3600.0;
    if((day~=daylast)||(ut~=utlast)||...
        (glat~=glatlast)||(glon~=glonlast))
        mlt=mltcalc(mlat,mlon,day,ut,nmax,mmax,nmaxgeo,mmaxgeo,anm,bnm,...
        dnm,marr,cm,en,narr,sh,xcoeff,ycoeff);
    end


    [mmpwind,mzpwind]=dwm07b14(mlt,mlat,kp,nmaxout,mmaxout,twidth,nterm,termarr,coeff);


    dw=zeros(2,1);
    dw(1)=(f2n*mmpwind+f1n*mzpwind)/(1+exp(-(alt-talt)/twidth));
    dw(2)=(f2e*mmpwind+f1e*mzpwind)/(1+exp(-(alt-talt)/twidth));

    glatlast=glat;
    glonlast=glon;
    daylast=day;
    utlast=ut;
    aplast=ap;
end


function apkp_out=aptokp(ap)
    apgrid=[0.,2.,3.,4.,5.,6.,7.,9.,12.,15.,18.,22.,27.,32.,39.,...
    48.,56.,67.,80.,94.,111.,132.,154.,179.,207.,236.,300.,400];
    kpgrid=[0.,1./3.0,2./3.0,3./3.0,4./3.0,5./3.0,6./3.0,7./3.0,...
    8./3.0,9./3.0,10./3.0,11./3.0,12./3.0,13./3.0,14./3.0,15./3.0,16./3.0,...
    17./3.0,18./3.0,19./3.0,20./3.0,21./3.0,22./3.0,23./3.0,24./3.0,25./3.0,...
    26./3.0,27/3.0];

    if(ap<0)
        ap=0;
    end
    if(ap>400)
        ap=400;
    end
    i=1;
    while(ap>apgrid(i))
        i=i+1;
    end
    if(ap==apgrid(i))
        apkp_out=kpgrid(i);
    else
        apkp_out=kpgrid(i-1)+(ap-apgrid(i-1))/(3*(apgrid(i)-apgrid(i-1)));
    end

end

function[f1e,f1n,f2e,f2n,qlat,qlon]=gd2qd(glat,glon,glatalf,nmax,mmax,...
    gpbar,gvbar,gwbar,anm,bnm,dnm,marr,cm,en,narr,xcoeff,ycoeff,...
    zcoeff,sh,shgradtheta,shgradphi)
    normadj=zeros(nmax+1,1);
    for n=1:nmax
        normadj(n+1)=sqrt((n*(n+1)));
    end
    deg2rad=pi/180;
    if(glat~=glatalf)
        theta=(90-glat)*deg2rad;
        [gpbar,gvbar,gwbar]=alfbasis(nmax,mmax,theta,gpbar,gvbar,gwbar,anm,bnm,dnm,marr,cm,en,...
        narr);
        glatalf=glat;
    end
    phi=glon*deg2rad;

    i=1;
    for n=1:nmax+1
        sh(i)=gpbar(n,1);
        shgradtheta(i)=gvbar(n,1)*normadj(n);
        shgradphi(i)=0;
        i=i+1;
    end
    for m=1:mmax
        mphi=m*phi;
        cosmphi=cos(mphi);
        sinmphi=sin(mphi);
        for n=m:nmax
            sh(i)=gpbar(n+1,m+1)*cosmphi;
            sh(i+1)=gpbar(n+1,m+1)*sinmphi;
            shgradtheta(i)=gvbar(n+1,m+1)*normadj(n+1)*cosmphi;
            shgradtheta(i+1)=gvbar(n+1,m+1)*normadj(n+1)*sinmphi;
            shgradphi(i)=-gwbar(n+1,m+1)*normadj(n+1)*sinmphi;
            shgradphi(i+1)=gwbar(n+1,m+1)*normadj(n+1)*cosmphi;
            i=i+2;
        end
    end

    x=dot(sh,xcoeff);
    y=dot(sh,ycoeff);
    z=dot(sh,zcoeff);

    qlonrad=atan2(y,x);
    cosqlon=cos(qlonrad);
    sinqlon=sin(qlonrad);
    cosqlat=x*cosqlon+y*sinqlon;

    qlat=atan2(z,cosqlat)/(deg2rad);
    qlon=qlonrad/(deg2rad);

    xgradtheta=dot(shgradtheta,xcoeff);
    ygradtheta=dot(shgradtheta,ycoeff);
    zgradtheta=dot(shgradtheta,zcoeff);

    xgradphi=dot(shgradphi,xcoeff);
    ygradphi=dot(shgradphi,ycoeff);
    zgradphi=dot(shgradphi,zcoeff);

    f1e=(-zgradtheta*cosqlat+(xgradtheta*cosqlon+ygradtheta*sinqlon)*z);
    f1n=(-zgradphi*cosqlat+(xgradphi*cosqlon+ygradphi*sinqlon)*z);
    f2e=(ygradtheta*cosqlon-xgradtheta*sinqlon);
    f2n=(ygradphi*cosqlon-xgradphi*sinqlon);
end

function mltcalc_out=mltcalc(qlat,qlon,day,ut,nmax,mmax,...
    nmaxgeo,mmaxgeo,anm,...
    bnm,dnm,...
    marr,cm,en,...
    narr,sh,xcoeff,...
    ycoeff)
    sineps=0.39781868;
    deg2rad=pi/180;
    spbar=zeros(nmaxgeo+1,mmaxgeo+1);
    svbar=zeros(nmaxgeo+1,mmaxgeo+1);
    swbar=zeros(nmaxgeo+1,mmaxgeo+1);


    asunglat=-asin(sin((day+ut/24.0-80.0)*deg2rad)*sineps)/(deg2rad);
    asunglon=-ut*15;


    theta=(90-asunglat)*deg2rad;
    [spbar,svbar,swbar]=alfbasis(nmax,mmax,theta,spbar,svbar,swbar,anm,bnm,dnm,marr,cm,en,...
    narr);
    phi=asunglon*deg2rad;
    i=1;
    for n=1:nmax+1
        sh(i)=spbar(n,1);
        i=i+1;
    end
    for m=1:mmax
        mphi=m*phi;
        cosmphi=cos(mphi);
        sinmphi=sin(mphi);
        for n=m:nmax
            sh(i)=spbar(n+1,m+1)*cosmphi;
            sh(i+1)=spbar(n+1,m+1)*sinmphi;
            i=i+2;
        end
    end
    x=dot(sh,xcoeff);
    y=dot(sh,ycoeff);
    asunqlon=atan2(y,x)/(deg2rad);


    mltcalc_out=(qlon-(asunqlon))/15;

end

function[mmpwind,mzpwind]=dwm07b14(mlt,mlat,kp,...
    nmax,mmax,twidth,nterm,termarr,...
    coeff)

    termvaltemp=[1.0,1.0];
    mltlast=1e16;
    mlatlast=1e16;
    kplast=1e16;
    deg2rad=pi/180;

    dpbar=zeros(nmax+1,mmax+1);
    dvbar=zeros(nmax+1,mmax+1);
    dwbar=zeros(nmax+1,mmax+1);

    nvshterm=(((nmax+1)*(nmax+2)-(nmax-mmax)*(nmax-mmax+1))/2-1)*4-2*nmax;

    mltterms=zeros(mmax+1,2);
    vshterms=zeros(2,nvshterm);
    termval=zeros(2,nterm);
    anm=zeros(nmax+1,mmax+1);
    bnm=zeros(nmax+1,mmax+1);
    dnm=zeros(nmax+1,mmax+1);
    cmalf=zeros(mmax+1,1);
    en=zeros(nmax+1,1);
    marr=zeros(mmax+1,1);
    narr=zeros(nmax+1,1);

    [narr,en,marr,anm,bnm,cmalf,dnm]=initalf(nmax,mmax,narr,en,marr,anm,bnm,cmalf,dnm);


    if(mlat~=mlatlast)
        theta=(90-(mlat))*deg2rad;
        [dpbar,dvbar,dwbar]=alfbasis(nmax,mmax,theta,dpbar,dvbar,dwbar,anm,bnm,dnm,marr,cmalf,en,...
        narr);
    end


    if(mlt~=mltlast)
        phi=mlt*deg2rad*15;
        for m=1:mmax+1
            mphi=(m-1)*phi;
            mltterms(m,1)=cos(mphi);
            mltterms(m,2)=sin(mphi);
        end
    end


    if((mlat~=mlatlast)||(mlt~=mltlast))
        ivshterm=1;
        for n=1:nmax
            vshterms(1,ivshterm)=-(dvbar(n+1,1)*mltterms(1,1));
            vshterms(1,ivshterm+1)=(dwbar(n+1,1)*mltterms(1,1));
            vshterms(2,ivshterm)=-vshterms(1,ivshterm+1);
            vshterms(2,ivshterm+1)=vshterms(1,ivshterm);
            ivshterm=ivshterm+2;
            for m=1:mmax
                if(m>n)
                    continue;
                end
                vshterms(1,ivshterm)=-(dvbar(n+1,m+1)*mltterms(m+1,1));
                vshterms(1,ivshterm+1)=(dvbar(n+1,m+1)*mltterms(m+1,2));
                vshterms(1,ivshterm+2)=(dwbar(n+1,m+1)*mltterms(m+1,2));
                vshterms(1,ivshterm+3)=(dwbar(n+1,m+1)*mltterms(m+1,1));
                vshterms(2,ivshterm)=-vshterms(1,ivshterm+2);
                vshterms(2,ivshterm+1)=-vshterms(1,ivshterm+3);
                vshterms(2,ivshterm+2)=vshterms(1,ivshterm);
                vshterms(2,ivshterm+3)=vshterms(1,ivshterm+1);
                ivshterm=ivshterm+4;
            end
        end
    end


    kpterms=zeros(3,1);
    if(kp~=kplast)
        kpterms=kpspl3(kp);
    end


    latwgtterm=latwgt2(mlat,mlt,kp,twidth);


    for iterm=1:nterm-1+1
        for k=1:2
            termvaltemp(k)=1.0;
        end
        if(termarr(1,iterm)~=999)
            termvaltemp(1)=termvaltemp(1)*vshterms(1,termarr(1,iterm)+1);
            termvaltemp(2)=termvaltemp(2)*vshterms(2,termarr(1,iterm)+1);
        end
        if(termarr(2,iterm)~=999)
            termvaltemp(1)=termvaltemp(1)*kpterms(termarr(2,iterm)+1);
            termvaltemp(2)=termvaltemp(2)*kpterms(termarr(2,iterm)+1);
        end
        if(termarr(3,iterm)~=999)
            termvaltemp(1)=termvaltemp(1)*latwgtterm;
            termvaltemp(2)=termvaltemp(2)*latwgtterm;
        end
        termval(1,iterm)=termvaltemp(1);
        termval(2,iterm)=termvaltemp(2);
    end


    mmpwind=dot(coeff,termval(1,:)');
    mzpwind=dot(coeff,termval(2,:)');

    mlatlast=mlat;
    mltlast=mlt;
    kplast=kp;

end


function kpterms=kpspl3(kp)

    node=[-10,-8,0,2,5,8,18,20];

    x=(max([kp,0.0]));
    x=(min([x,8.0]));
    kpterms=zeros(3,1);
    kpspl=zeros(7,1);

    kpterms(1)=0.0;
    kpterms(2)=0.0;
    kpterms(3)=0.0;
    for i=1:6+1
        kpspl(i)=0.0;
        if((x>=node(i))&&(x<node(i+1)))
            kpspl(i)=1.0;
        end
    end
    for j=2:3
        for i=1:8-j-1+1
            kpspl(i)=kpspl(i)*(x-node(i))/(node(i+j-1)-node(i))+...
            kpspl(i+1)*(node(i+j)-x)/(node(i+j)-node(i+1));
        end
    end
    kpterms(1)=kpspl(1)+kpspl(2);
    kpterms(2)=kpspl(3);
    kpterms(3)=kpspl(4)+kpspl(5);
end


function latwgt2_out=latwgt2(mlat,mlt,kp0,twidth)
    coeff=[65.7633,-4.60256,-3.53915,-1.99971,-0.752193,0.972388];
    deg2rad=pi/180;
    mltrad=(mlt*15.0*deg2rad);
    sinmlt=sin(mltrad);
    cosmlt=cos(mltrad);
    kp=max([kp0,0.0]);
    kp=min([kp,8.0]);
    tlat=coeff(1)+coeff(2)*cosmlt+coeff(3)*sinmlt+...
    kp*(coeff(4)+coeff(5)*cosmlt+coeff(6)*sinmlt);
    latwgt2_out=1/(1+exp(-(abs(mlat)-tlat)/twidth));
end
