function[alon,xlatqd,f1,f2,ist]=aeroblkapex(glat,glon,alt,hr)


%#codegen


    coder.allowpcode('plain');
    coder.license('checkout','Aerospace_Toolbox');
    coder.license('checkout','Aerospace_Blockset');

    xmiss=-32767.0;
    glatlim=89.9;
    precise=7.6e-11;
    datdmx=1.;
    datimx=2.5;
    irlf=4;

    io=2;
    jo=2;
    ko=2;


    S=coder.load('apexgrid.mat');
    kgma=S.kgma;
    glalmn=S.glalmn;
    glalmx=S.glalmx;
    nla=S.nla;
    nlo=S.nlo;
    nal=S.nal;
    lbx=S.lbx;
    lby=S.lby;
    lbz=S.lbz;
    lbv=S.lbv;
    lla=S.lla;
    llo=S.llo;
    lal=S.lal;
    colat=S.colat;
    elon=S.elon;
    vp=S.vp;
    ctp=S.ctp;
    stp=S.stp;
    rtod=S.rtod;
    dtor=S.dtor;
    re=S.re;
    req=S.req;
    msgu=S.msgu;
    pola=S.pola;

    lwk=nla*nlo*nal*5+nla+nlo+nal;
    wk=S.wk;

    x=zeros(nla,nlo,nal);
    y=zeros(nla,nlo,nal);
    z=zeros(nla,nlo,nal);
    v=zeros(nla,nlo,nal);
    itx=lbx;
    ity=lby;
    itz=lbz;
    itv=lbv;
    for i=1:nal
        for j=1:nlo
            for k=1:nla
                x(k,j,i)=wk(itx);
                itx=itx+1;
                y(k,j,i)=wk(ity);
                ity=ity+1;
                z(k,j,i)=wk(itz);
                itz=itz+1;
                v(k,j,i)=wk(itv);
                itv=itv+1;
            end
        end
    end
    gplat=zeros(nla,1);
    gplon=zeros(nlo,1);
    gpalt=zeros(nal,1);

    gplat(:,1)=wk(lla:lla+nla-1);
    gplon(:,1)=wk(llo:llo+nlo-1);
    gpalt(:,1)=wk(lal:lal+nal-1);

    [f,dfdth,dfdln,dfdh]=intrp(glat,glon,alt,x,y,z,v,gplat,gplon,gpalt,io,jo,...
    ko,re,rtod);
    [cth,sth,f,dfdth,dfdln]=adpl(glat,glon,f,dfdth,dfdln,elon,dtor,ctp,stp);
    [gradx,grady,gradz,gradv]=gradxyzv(alt,cth,sth,dfdth,dfdln,dfdh);





    if((glat>glalmx)||(glat<glalmn))

        glatx=(glalmx);

        if(glat<0.0)
            glatx=(glalmn);
        end
        [fdum,dfmdth,dfdln,dfmdh]=intrp(glatx,glon,alt,x,y,z,v,gplat,gplon,gpalt,io,jo,...
        ko,re,rtod);
        [cth,sth,fdum,dfdth,dfdln]=adpl(glatx,glon,fdum,dfmdth,dfdln,elon,dtor,ctp,stp);
        [gradx,grady,gradz,gradv]=grapxyzv(alt,cth,sth,dfdln,gradx,grady,gradz,gradv);
    end

    [xlatm,alon,vmp,grclm,clmgrp,xlatqd,rgrlp,b,clm,r3_2]=gradlpv(hr,alt,f,gradx,grady,gradz,gradv,re,rtod,vp);
    [bmag,sim,si,ff,d,w,bhat,d1,d2,d3,e1,e2,e3,f1,f2]=basvec(hr,xlatm,grclm,clmgrp,rgrlp,b,clm,r3_2,re,dtor);

    be3=bmag/d;

    ist=0;
end

function[bmag,sim,si,f,d,w,bhat,d1,d2,d3,e1,e2,e3,f1,f2]=basvec(hr,xlatm,grclm,clmgrp,rgrlp,b,clm,r3_2,re,dtor)




























    rr=re+(hr);
    simoslm=(2.0/sqrt(4.0-3.0*clm*clm));
    sim=simoslm*sin(xlatm*dtor);
    bmag=sqrt(b(1)*b(1)+b(2)*b(2)+b(3)*b(3));
    d1db=0.0;
    d2db=0.0;
    bhat=zeros(3,1);
    d1=zeros(3,1);
    d2=zeros(3,1);
    d3=zeros(3,1);
    e1=zeros(3,1);
    e2=zeros(3,1);
    e3=zeros(3,1);
    f1=zeros(3,1);
    f2=zeros(3,1);

    for i=1:3
        bhat(i)=b(i)/(bmag);
        d1(i)=rr*clmgrp(i);
        d1db=d1db+d1(i)*bhat(i);
        d2(i)=rr*simoslm*grclm(i);
        d2db=d2db+d2(i)*bhat(i);
    end



    for i=1:3
        d1(i)=d1(i)-d1db*bhat(i);
        d2(i)=d2(i)-d2db*bhat(i);
    end

    e3(1)=d1(2)*d2(3)-d1(3)*d2(2);
    e3(2)=d1(3)*d2(1)-d1(1)*d2(3);
    e3(3)=d1(1)*d2(2)-d1(2)*d2(1);
    d=bhat(1)*e3(1)+bhat(2)*e3(2)+bhat(3)*e3(3);



    for i=1:3
        d3(i)=bhat(i)/(d);
        e3(i)=bhat(i)*(d);
    end

    e1(1)=d2(2)*d3(3)-d2(3)*d3(2);
    e1(2)=d2(3)*d3(1)-d2(1)*d3(3);
    e1(3)=d2(1)*d3(2)-d2(2)*d3(1);
    e2(1)=d3(2)*d1(3)-d3(3)*d1(2);
    e2(2)=d3(3)*d1(1)-d3(1)*d1(3);
    e2(3)=d3(1)*d1(2)-d3(2)*d1(1);

    w=rr*rr*clm*abs(sim)/(bmag*(d));

    si=-bhat(3);

    f1(1)=(rgrlp(2));
    f1(2)=(-rgrlp(1));
    f2(1)=(-d1(2)*r3_2);
    f2(2)=(d1(1)*r3_2);
    f=(f1(1)*f2(2)-f1(2)*f2(1));

end

function[xlatm,xlonm,vmp,grclm,clmgrp,qdlat,rgrlp,b,clm,r3_2]=gradlpv(hr,alt,f,gradx,grady,gradz,gradv,re,rtod,vp)
























    fx=f(1);
    fy=f(2);
    fz=f(3);
    fv=f(4);
    b=zeros(3,1);
    rgrlp=zeros(3,1);
    grclm=zeros(3,1);
    clmgrp=zeros(3,1);
    rr=re+(hr);
    r=re+(alt);
    rn=r/re;
    sqrror=sqrt(rr/r);
    r3_2=(1.0/sqrror/sqrror/sqrror);
    xlonm=atan2(fy,fx);
    cpm=cos(xlonm);
    spm=sin(xlonm);
    xlonm=rtod*(xlonm);
    bo=(vp*1.e6);



    rn2=rn*rn;
    vmp=vp*fv/rn2;
    b(1)=-bo*gradv(1)/rn2;
    b(2)=-bo*gradv(2)/rn2;
    b(3)=(-bo*(gradv(3)-2.0*fv/r)/rn2);

    x2py2=fx*fx+fy*fy;
    xnorm=sqrt(x2py2+fz*fz);
    xlp=atan2(fz,sqrt(x2py2));
    slp=sin(xlp);
    clp=cos(xlp);
    qdlat=xlp*rtod;
    clm=sqrror*clp;

    xlatm=rtod*acos(clm);



    if(slp<0.0)
        xlatm=-xlatm;
    end
    for i=1:3
        grclp=cpm*gradx(i)+spm*grady(i);
        rgrlp(i)=r*(clp*gradz(i)-slp*grclp);
        grclm(i)=sqrror*grclp;
        clmgrp(i)=sqrror*(cpm*grady(i)-spm*gradx(i));
    end

    grclm(3)=(grclm(3)-sqrror*clp/(2.0*r));

end

function[gradx,grady,gradz,gradv]=grapxyzv(alt,cth,sth,dfdln,gradx,grady,gradz,gradv)












    d2=40680925-272340*cth*cth;
    d=sqrt(d2);
    rho=(sth*(alt+40680925/d));
    dddthod=272340*cth*sth/d2;
    drhodth=(alt*cth+(40680925/d)*(cth-sth*dddthod));
    dzetdth=(-alt*sth-(40408585/d)*(sth+cth*dddthod));
    ddisdth=sqrt(drhodth*drhodth+dzetdth*dzetdth);

    gradx(1)=dfdln(1)/rho;
    grady(1)=dfdln(2)/rho;
    gradz(1)=dfdln(3)/rho;
    gradv(1)=dfdln(4)/rho;

end

function[gradx,grady,gradz,gradv]=gradxyzv(alt,cth,sth,dfdth,dfdln,dfdh)












    gradx=zeros(3,1);
    grady=zeros(3,1);
    gradz=zeros(3,1);
    gradv=zeros(3,1);

    d2=40680925-272340*cth*cth;
    d=sqrt(d2);
    rho=(sth*(alt+40680925/d));
    dddthod=272340*cth*sth/d2;
    drhodth=(alt*cth+(40680925/d)*(cth-sth*dddthod));
    dzetdth=(-alt*sth-(40408585/d)*(sth+cth*dddthod));
    ddisdth=sqrt(drhodth*drhodth+dzetdth*dzetdth);

    gradx(1)=dfdln(1)/rho;
    grady(1)=dfdln(2)/rho;
    gradz(1)=dfdln(3)/rho;
    gradv(1)=dfdln(4)/rho;

    gradx(2)=-dfdth(1)/ddisdth;
    grady(2)=-dfdth(2)/ddisdth;
    gradz(2)=-dfdth(3)/ddisdth;
    gradv(2)=-dfdth(4)/ddisdth;

    gradx(3)=dfdh(1);
    grady(3)=dfdh(2);
    gradz(3)=dfdh(3);
    gradv(3)=dfdh(4);


end

function[cth,sth,f,dfdth,dfdln]=adpl(glat,glon,f,dfdth,dfdln,elon,dtor,ctp,stp)

    cph=cos((glon-elon)*dtor);
    sph=sin((glon-elon)*dtor);
    cth=sin(glat*dtor);
    sth=cos(glat*dtor);
    ctm=ctp*cth+stp*sth*cph;

    f(1)=f(1)+sth*ctp*cph-cth*stp;
    f(2)=f(2)+sth*sph;
    f(3)=f(3)+ctm;
    f(4)=f(4)-ctm;

    dfdth(1)=dfdth(1)+ctp*cth*cph+stp*sth;
    dfdth(2)=dfdth(2)+cth*sph;
    dfdth(3)=dfdth(3)-ctp*sth+stp*cth*cph;
    dfdth(4)=dfdth(4)+ctp*sth-stp*cth*cph;
    dfdln(1)=dfdln(1)-ctp*sth*sph;
    dfdln(2)=dfdln(2)+sth*cph;
    dfdln(3)=dfdln(3)-stp*sth*sph;
    dfdln(4)=dfdln(4)+stp*sth*sph;
end

function[fu,dfudx,dfudy,dfudz]=trilin(u,xi,yj,zk)

















    omxi=(1.0-xi);
    omyj=(1.0-yj);
    omzk=(1.0-zk);

    fu=u(1,1,1)*omxi*omyj*omzk...
    +u(1+1,1,1)*xi*omyj*omzk...
    +u(1,1+1,1)*omxi*yj*omzk...
    +u(1,1,1+1)*omxi*omyj*zk...
    +u(1+1,1+1,1)*xi*yj*omzk...
    +u(1+1,1,1+1)*xi*omyj*zk...
    +u(1,1+1,1+1)*omxi*yj*zk...
    +u(1+1,1+1,1+1)*xi*yj*zk;

    dfudx=(u(1+1,1,1)-u(1,1,1))*omyj*omzk...
    +(u(1+1,1+1,1)-u(1,1+1,1))*yj*omzk...
    +(u(1+1,1,1+1)-u(1,1,1+1))*omyj*zk...
    +(u(1+1,1+1,1+1)-u(1,1+1,1+1))*yj*zk;

    dfudy=(u(1,1+1,1)-u(1,1,1))*omxi*omzk...
    +(u(1+1,1+1,1)-u(1+1,1,1))*xi*omzk...
    +(u(1,1+1,1+1)-u(1,1,1+1))*omxi*zk...
    +(u(1+1,1+1,1+1)-u(1+1,1,1+1))*xi*zk;

    dfudz=(u(1,1,1+1)-u(1,1,1))*omxi*omyj...
    +(u(1+1,1,1+1)-u(1+1,1,1))*xi*omyj...
    +(u(1,1+1,1+1)-u(1,1+1,1))*omxi*yj...
    +(u(1+1,1+1,1+1)-u(1+1,1+1,1))*xi*yj;
end


function[f,dfdth,dfdln,dfdh]=intrp(glat,glon,alt,x,y,z,v,gplat,gplon,...
    gpalt,io,jo,ko,re,rtod)









    i=io;
    if(gplat(i)<glat)
        while(gplat(i)<glat)
            i=i+1;
        end
    end
    if(gplat(i-1)>glat)
        while(gplat(i-1)>glat)
            i=i-1;
        end
    end

    io=i;

    dlat=gplat(i)-gplat(i-1);
    xi=((glat-gplat(i-1))/dlat);



    j=jo;
    if(gplon(j)<glon)
        while(gplon(j)<glon)
            j=j+1;
        end
    end
    if(gplon(j-1)>glon)
        while(gplon(j-1)>glon)
            j=j-1;
        end
    end

    jo=j;
    dlon=gplon(j)-gplon(j-1);
    yj=((glon-gplon(j-1))/dlon);



    k=ko;
    if(gpalt(k)<alt)
        while(gpalt(k)<alt)
            k=k+1;
        end
    end
    if(gpalt(k-1)>alt)
        while(gpalt(k-1)>alt)
            k=k-1;
        end
    end
    ko=k;

    hti=(re/(re+alt));
    diht=re/(re+gpalt(k))-re/(re+gpalt(k-1));
    zk=(hti-re/(re+gpalt(k-1)))/diht;

    [fx,dfxdn,dfxde,dfxdd]=trilin(x(i-1:i,j-1:j,k-1:k),xi,yj,zk);
    dfxdth=-dfxdn*rtod/dlat;
    dfxdln=dfxde*rtod/dlon;
    dfxdh=-hti*hti*dfxdd/(re*diht);

    [fy,dfydn,dfyde,dfydd]=trilin(y(i-1:i,j-1:j,k-1:k),xi,yj,zk);
    dfydth=-dfydn*rtod/dlat;
    dfydln=dfyde*rtod/dlon;
    dfydh=-hti*hti*dfydd/(re*diht);

    [fz,dfzdn,dfzde,dfzdd]=trilin(z(i-1:i,j-1:j,k-1:k),xi,yj,zk);
    dfzdth=-dfzdn*rtod/dlat;
    dfzdln=dfzde*rtod/dlon;
    dfzdh=-hti*hti*dfzdd/(re*diht);

    [fv,dfvdn,dfvde,dfvdd]=trilin(v(i-1:i,j-1:j,k-1:k),xi,yj,zk);
    dfvdth=-dfvdn*rtod/dlat;
    dfvdln=dfvde*rtod/dlon;
    dfvdh=-hti*hti*dfvdd/(re*diht);



    if(glat<(dlat-90.0))
        fac=(0.5*xi);
        omfac=(1.0-fac);
        xi=(xi-1.0);
        i=i+1;
        [dmf,dmdfdn,dmdfde,dmdfdd]=trilin(x(i-1:i,j-1:j,k-1:k),xi,yj,zk);
        dfxdln=dfxdln*omfac+fac*dmdfde*rtod/dlon;
        [dmf,dmdfdn,dmdfde,dmdfdd]=trilin(y(i-1:i,j-1:j,k-1:k),xi,yj,zk);
        dfydln=dfydln*omfac+fac*dmdfde*rtod/dlon;
        [dmf,dmdfdn,dmdfde,dmdfdd]=trilin(v(i-1:i,j-1:j,k-1:k),xi,yj,zk);
        dfvdln=dfvdln*omfac+fac*dmdfde*rtod/dlon;
    end
    if(glat>(90.0-dlat))
        fac=(0.5*(1.0-xi));
        omfac=(1.0-fac);
        xi=(xi+1.0);
        i=i-1;
        [dmf,dmdfdn,dmdfde,dmdfdd]=trilin(x(i-1:i,j-1:j,k-1:k),xi,yj,zk);
        dfxdln=dfxdln*omfac+fac*dmdfde*rtod/dlon;
        [dmf,dmdfdn,dmdfde,dmdfdd]=trilin(y(i-1:i,j-1:j,k-1:k),xi,yj,zk);
        dfydln=dfydln*omfac+fac*dmdfde*rtod/dlon;
        [dmf,dmdfdn,dmdfde,dmdfdd]=trilin(v(i-1:i,j-1:j,k-1:k),xi,yj,zk);
        dfvdln=dfvdln*omfac+fac*dmdfde*rtod/dlon;
    end
    f=[fx,fy,fz,fv];
    dfdth=[dfxdth,dfydth,dfzdth,dfvdth];
    dfdln=[dfxdln,dfydln,dfzdln,dfvdln];
    dfdh=[dfxdh,dfydh,dfzdh,dfvdh];
end
