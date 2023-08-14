function w=aeroblkhwm07(lla,day,sec,ap,mdl)




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

    switch mdl
    case 0
        w=hwm07(day,sec,alt,lat,lon);
    case 1
        qw=hwm07(day,sec,alt,lat,lon);
        dw=aeroblkdwm07b(day,sec,alt,lat,lon,ap);
        w=qw+dw;
    case 2
        w=aeroblkdwm07b(day,sec,alt,lat,lon,ap);
    otherwise
        w=[0;0];
    end

end

function w=hwm07(day,sec,alt,glat,glon)


    cseason=0;
    cwave=0;
    ctide=0;


    S=coder.load('hwm071308e.mat');

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

    nnode=nlev+p;

    alttns=vnode(nlev-2);
    altsym=vnode(nlev-1);
    altiso=vnode(nlev);



    mmax=11;
    nmax=11;
    p0=zeros(nmax+1,mmax+1);
    p1=zeros(nmax+1,mmax+1);
    sf=zeros(nmax+1,mmax+1);
    a=zeros(nmax+1,mmax+1);
    b=zeros(nmax+1,mmax+1);
    c=zeros(nmax+1,mmax+1);
    d=zeros(nmax+1,mmax+1);
    nm1=nmax-1;
    nm2=nmax-2;

    for m=1:nmax+1
        p0=alfk(nm1,m-1,p0);
        p1=alfk(nm2,m-1,p1);
        fnmm=(nmax-m+1);
        fnpn=(nmax+nm1);
        fnpm=(nmax+m-1);
        i=1;
        for n=m:nm1
            fnmm=fnmm-1.0;
            fnpn=fnpn-2.0;
            fnpm=fnpm-1.0;
            sf(i,m)=sqrt((fnmm*fnpm/(fnpn*(fnpn+2.0))));
            i=i+1;
        end
    end
    for n=1:nmax
        nfac1=0.5/sqrt((n*(n+1)));
        nfac2=nfac1*sqrt((2*n+1)/(2*n-1));
        for m=1:n
            npm=n+m;
            nmm=n-m;
            a(n+1,m+1)=-nfac1*sqrt((nmm*(npm+1)));
            b(n+1,m+1)=nfac1*sqrt((npm*(nmm+1)));
            c(n+1,m+1)=nfac2*sqrt(npm*(npm-1));
            d(n+1,m+1)=nfac2*sqrt((nmm*(nmm-1)));
        end
    end
    input=zeros(5,1);
    input(1)=day;
    input(2)=sec;
    input(3)=glon;
    input(4)=glat;
    input(5)=alt;

    maxo=max([maxs,maxm,maxl]);
    u=0.0;
    v=0.0;
    [u,v]=HWMUpdate(input,maxs,maxl,maxm,maxo,maxn,nmax,p0,p1,sf,nnode,p,vnode,...
    order,mparm,a,b,c,d,nbf);
    w=[-v;u];

end

function[u,v]=HWMUpdate(input,maxs,maxl,maxm,maxo,maxn,nmax,p0,p1,sf,nnode,p,vnode,...
    order,mparm,abasis,bbasis,cbasis,dbasis,nbf)




    twoPi=2.0*3.1415926535897932384626433832795;
    deg2rad=twoPi/360.0;
    fs=zeros(maxs+1,2);
    fl=zeros(maxl+1,2);
    fm=zeros(maxm+1,2);
    refresh=zeros(5,1);



    AA=input(1)*twoPi/365.25;
    for s=1:maxs+1
        BB=(s-1)*AA;
        fs(s,1)=cos(BB);
        fs(s,2)=sin(BB);
    end
    for s=1:5
        refresh(s)=1;
    end


    AA=mod(input(2)/3600+input(3)/15+48,24.0);
    BB=AA*twoPi/24;
    for l=1:maxl+1
        CC=(l-1)*BB;
        fl(l,1)=cos(CC);
        fl(l,2)=sin(CC);
    end

    refresh(3)=1;


    AA=input(3)*deg2rad;
    for m=1:maxm+1
        BB=(m-1)*AA;
        fm(m,1)=cos(BB);
        fm(m,2)=sin(BB);
    end
    refresh(2)=1;


    AA=(90.0-input(4))*deg2rad;
    [vbar,wbar]=vshbasis(maxn,maxo,AA,nmax,p0,p1,sf,abasis,bbasis,cbasis,dbasis);
    refresh(1:4)=1;


    [zwght,lev]=vertwght(input(5),nnode,p,vnode);


    u=0.0;
    v=0.0;
    ebz=zeros(p+1,nbf);
    ebm=zeros(p+1,nbf);
    refresh(1:5)=1;



    for b=1:p+1

        if(zwght(b)==0.0)
            continue;
        end

        d=b+lev-1;

        amaxs=order(1,d);
        amaxn=order(2,d);
        pmaxm=order(3,d);
        pmaxs=order(4,d);
        pmaxn=order(5,d);
        tmaxl=order(6,d);
        tmaxs=order(7,d);
        tmaxn=order(8,d);

        c=1;




        c=1;
        for n=1:amaxn
            ebz(b,c)=-0.5*vbar(n+1,1);
            ebz(b,c+1)=0.0;
            ebm(b,c)=0.0;
            ebm(b,c+1)=0.5*vbar(n+1,1);
            c=c+2;
        end

        for s=2:amaxs+1
            cs=fs(s,1);
            ss=fs(s,2);
            for n=s:amaxn+1
                vb=vbar(n,s);
                wb=wbar(n,s);
                AA=vb*cs;
                BB=vb*ss;
                CC=-wb*ss;
                DD=-wb*cs;
                ebz(b,c)=-AA;
                ebz(b,c+1)=BB;
                ebz(b,c+2)=CC;
                ebz(b,c+3)=DD;
                ebm(b,c)=CC;
                ebm(b,c+1)=DD;
                ebm(b,c+2)=AA;
                ebm(b,c+3)=-BB;
                c=c+4;
            end
        end
        cseason=c;




        for m=1:pmaxm

            cm=fm(m+1,1);
            sm=fm(m+1,2);

            for n=m:pmaxn

                vb=vbar(n+1,m+1);
                wb=wbar(n+1,m+1);

                ebz(b,c)=-vb*cm;
                ebz(b,c+1)=vb*sm;
                ebz(b,c+2)=-wb*sm;
                ebz(b,c+3)=-wb*cm;

                ebm(b,c)=-wb*sm;
                ebm(b,c+1)=-wb*cm;
                ebm(b,c+2)=vb*cm;
                ebm(b,c+3)=-vb*sm;

                c=c+4;
            end


            for s=2:pmaxs+1

                cs=fs(s,1);
                ss=fs(s,2);

                for n=m:pmaxn
                    vb=vbar(n+1,m+1);
                    wb=wbar(n+1,m+1);

                    ebz(b,c)=-vb*cm*cs;
                    ebz(b,c+1)=vb*sm*cs;
                    ebz(b,c+2)=-wb*sm*cs;
                    ebz(b,c+3)=-wb*cm*cs;
                    ebz(b,c+4)=-vb*cm*ss;
                    ebz(b,c+5)=vb*sm*ss;
                    ebz(b,c+6)=-wb*sm*ss;
                    ebz(b,c+7)=-wb*cm*ss;

                    ebm(b,c)=-wb*sm*cs;
                    ebm(b,c+1)=-wb*cm*cs;
                    ebm(b,c+2)=vb*cm*cs;
                    ebm(b,c+3)=-vb*sm*cs;
                    ebm(b,c+4)=-wb*sm*ss;
                    ebm(b,c+5)=-wb*cm*ss;
                    ebm(b,c+6)=vb*cm*ss;
                    ebm(b,c+7)=-vb*sm*ss;

                    c=c+8;

                end

            end
            cwave=c;
        end



        for l=2:tmaxl+1

            cl=fl(l,1);
            sl=fl(l,2);

            s=0;
            for n=l:tmaxn+1

                vb=vbar(n,l);
                wb=wbar(n,l);

                ebz(b,c)=-vb*cl;
                ebz(b,c+1)=vb*sl;
                ebz(b,c+2)=-wb*sl;
                ebz(b,c+3)=-wb*cl;

                ebm(b,c)=-wb*sl;
                ebm(b,c+1)=-wb*cl;
                ebm(b,c+2)=vb*cl;
                ebm(b,c+3)=-vb*sl;

                c=c+4;
            end


            for s=2:tmaxs+1

                cs=fs(s,1);
                ss=fs(s,2);

                for n=l:tmaxn+1

                    vb=vbar(n,l);
                    wb=wbar(n,l);

                    ebz(b,c)=-vb*cl*cs;
                    ebz(b,c+1)=vb*sl*cs;
                    ebz(b,c+2)=-wb*sl*cs;
                    ebz(b,c+3)=-wb*cl*cs;

                    ebz(b,c+4)=-vb*cl*ss;
                    ebz(b,c+5)=vb*sl*ss;
                    ebz(b,c+6)=-wb*sl*ss;
                    ebz(b,c+7)=-wb*cl*ss;

                    ebm(b,c)=-wb*sl*cs;
                    ebm(b,c+1)=-wb*cl*cs;
                    ebm(b,c+2)=vb*cl*cs;
                    ebm(b,c+3)=-vb*sl*cs;

                    ebm(b,c+4)=-wb*sl*ss;
                    ebm(b,c+5)=-wb*cl*ss;
                    ebm(b,c+6)=vb*cl*ss;
                    ebm(b,c+7)=-vb*sl*ss;

                    c=c+8;
                end

            end
            ctide=c;
        end






        c=c-1;





        u=u+zwght(b)*dot(ebz(b,:),mparm(:,d));


        v=v+zwght(b)*dot(ebm(b,:),mparm(:,d));
    end

end

function[wght,iz]=vertwght(alt,nnode,p,vnode)



    wght=zeros(4,1);
    we=zeros(5,1);

    e1=[1,0.428251121076233,0.192825112107623,0.484304932735426,0.0];
    e2=[0,0.571748878923767,0.807174887892377,-0.484304932735426,1.0];
    H=60.0;

    iz=aeroblkfindspan(nnode-p-1,p,alt,vnode)-p;
    iz=min([iz,27]);

    wght(1)=aeroblkbspline(p,nnode,vnode,iz,alt);
    wght(2)=aeroblkbspline(p,nnode,vnode,iz+1,alt);
    if(iz<=26)
        wght(3)=aeroblkbspline(p,nnode,vnode,iz+2,alt);
        wght(4)=aeroblkbspline(p,nnode,vnode,iz+3,alt);
        return;
    end
    if(alt>250.0)
        we(1)=0.0;
        we(2)=0.0;
        we(3)=0.0;
        we(4)=exp(-(alt-250.0)/H);
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

function[vbar,wbar]=vshbasis(maxn,maxo,theta,nmax,p0,p1,sf,a,b,c,d)




    pb=zeros(nmax+1,1);
    td=zeros(nmax+1,1);
    pbar=zeros(nmax,maxo+2);
    wbar=zeros(maxn+1,maxo+1);
    vbar=zeros(maxn+1,maxo+1);


    nm1=nmax-1;
    nm2=nmax-2;

    for m=1:maxo+2
        nmm=nmax-m+1;
        p0i=lfpt(nm1,m-1,theta,p0);
        p1i=lfpt(nm2,m-1,theta,p1);
        pbar(nm1,m)=p0i;
        if(nmm<=0)
            break;
        end
        pbar(nm2,m)=p1i;
        if(nmm==1)
            break;
        end
        cost=cos(theta);
        for n=1:nmm
            pb(n)=-cost;
            td(n)=sf(n,m);
        end
        if(abs(p0i)>=abs(p1i))
            pb(1)=p0i;
            r=-td(1)*pb(1);
            [pb(2:end),td(2:end)]=tridiag(nmm-1,r,td(1:end),pb(2:end),td(2:end));
        else
            pb(1)=p0i;
            pb(2)=p1i;
            r=-td(2)*pb(2);
            [pb(3:end),td(3:end)]=tridiag(nmm-2,r,td(2:end),pb(3:end),td(3:end));
        end
        for n=m:nmax
            i=nmax-n+1;
            pbar(n,m)=pb(i);
        end
    end


    for n=1:maxn+1
        vbar(n,1)=-pbar(n,2);
    end

    for m=2:maxo+1
        mm1=m-1;
        mp1=m+1;
        for n=m:maxn+1
            nm1=n-1;
            vbar(n,m)=a(n,m)*pbar(n,mp1)+b(n,m)*pbar(n,mm1);
            wbar(n,m)=c(n,m)*pbar(nm1,mm1)+d(n,m)*pbar(nm1,mp1);
        end
    end

end

function[b,c]=tridiag(n,r,a,b,c)




    nswitch=n;

    if((n>=0)&&(n<=3))
        nswitch=n;
    else
        if(n<0)
            nswitch=0;
        end
        if(n>3)
            nswitch=3;
        end
    end
    switch nswitch
    case 0
        return;
    case 1
        b(1)=r/b(1);
        return;
    case 2
        qih=a(2);
        bih=b(2);
    case 3
        qih=a(n);
        bih=b(n);
        for j=3:n+1
            i=n-j+3;
            if(abs(bih)>=abs(c(i)))
                ratio=c(i)/bih;
                c(i)=0.0;
                b(i+1)=qih/bih;
                bih=b(i)-ratio*qih;
                qih=a(i);
            else
                b(i+1)=b(i)/c(i);
                c(i)=a(i)/c(i);
                bih1=qih-bih*b(i+1);
                qih=-bih*c(i);
                bih=bih1;
            end
        end
    otherwise
        return;
    end
    if(abs(bih)>=abs(c(1)))
        q2=qih/bih;
        bih=b(1)-c(1)/bih*qih;
        b(1)=r/bih;
        b(2)=-q2*b(1);
    else
        ratio=bih/c(1);
        bih=qih-ratio*b(1);
        rih=-ratio*r;
        b1=rih/bih;
        b(2)=(r-b(1)*b1)/c(1);
        b(1)=b1;
    end
    if(n-3>=0)
        for i=3:n
            b(i)=-b(i)*b(i-1)-c(i-1)*b(i-2);
        end
    end
end

function output=lfpt(n,m,theta,cp)



    lfptout=0.0;
    if(m>n)
        output=lfptout;
        return;
    end
    if((n<=0)&&(m<=0))
        lfptout=sqrt(0.5);
        output=lfptout;
        return;
    end
    cdt=cos(2*theta);
    sdt=sin(2*theta);
    if(mod(n,2)<=0)
        ct=1.0;
        st=0.0;
        if(mod(m,2)<=0)
            kdo=n/2+1;
            lfptout=0.5*cp(1,m+1);
            for k=2:kdo
                cth=cdt*ct-sdt*st;
                st=sdt*ct+cdt*st;
                ct=cth;
                lfptout=lfptout+cp(k,m+1)*ct;
            end
        else
            kdo=n/2;
            for k=1:kdo
                cth=cdt*ct-sdt*st;
                st=sdt*ct+cdt*st;
                ct=cth;
                lfptout=lfptout+cp(k,m+1)*st;
            end
        end
    else
        kdo=(n+1)/2;
        ct=cos(theta);
        st=-sin(theta);
        if(mod(m,2)<=0)
            for k=1:kdo
                cth=cdt*ct-sdt*st;
                st=sdt*ct+cdt*st;
                ct=cth;
                lfptout=lfptout+cp(k,m+1)*ct;
            end
        else
            for k=1:kdo
                cth=cdt*ct-sdt*st;
                st=sdt*ct+cdt*st;
                ct=cth;
                lfptout=lfptout+cp(k,m+1)*st;
            end
        end
    end
    output=lfptout;
end


function output=alfk(n,m,cp)



    output=cp;

    if m>n
        output(1,m)=0;
        return;
    end
    if n<=0
        output(1,m)=sqrt(2);
    end
    if n==1
        if(m==0)
            output(1,m)=sqrt(1.5);
        else

            output(1,m)=sqrt(0.75);

            return;
        end
    end
    if(mod(n+m,2)==0)
        nmms2=(n-m)/2;
        fnum=(n+m+1);
        fnmh=(n-m+1);
        pm1=1.0;
    else
        nmms2=(n-m-1)/2;
        fnum=(n+m+2);
        fnmh=(n-m+2);
        pm1=-1.0;
    end
    t1=1.0;
    t2=1.0;
    if(nmms2>=1)
        fden=2.0;
        for i=1:nmms2
            t1=fnum*t1/fden;
            fnum=fnum+2.0;
            fden=fden+2.0;
        end
    end
    if(m~=0)
        for i=1:m
            t2=fnmh*t2/(fnmh+pm1);
            fnmh=fnmh+2.0;
        end
    end
    if(floor(mod((m/2),2))~=0)
        t1=-t1;
    end
    cp2=t1*sqrt((n+0.5)*t2)/(2.0^(n-1));
    fnnp1=(n*(n+1));
    fnmsq=fnnp1-2.0*(m*m);
    l=floor((n+1)/2);
    if(mod(n,2)==0&&mod(m,2)==0)
        l=l+1;
    end
    output(l,m+1)=cp2;
    if(l<=1)
        return;
    end
    fk=(n);
    a1=(fk-2.0)*(fk-1.0)-fnnp1;
    b1=2*(fk*fk-fnmsq);
    output(l-1,m+1)=b1*output(l,m+1)/a1;
    l=l-1;
    while(l>1)
        fk=fk-2;
        a1=(fk-2)*(fk-1)-fnnp1;
        b1=-2*(fk*fk-fnmsq);
        c1=(fk+1)*(fk+2)-fnnp1;
        output(l-1,m+1)=-(b1*output(l,m+1)+c1*output(l+1,m+1))/a1;
        l=l-1;
    end
end
