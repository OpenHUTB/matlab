function dw=aeroblkdwm07b(day,sec,alt,glat,glon,ap)


%#codegen


    coder.allowpcode('plain');
    coder.license('checkout','Aerospace_Toolbox');
    coder.license('checkout','Aerospace_Blockset');

    pi=3.141592653590;
    dtor=pi/180;
    sin_eps=0.39781868;


    kp=ap_to_kp(ap);



    [mlat,mlon,f1e,f1n,f2e,f2n]=gd2qd(glat,glon);


    ut=sec/3600.0;
    asun_glat=-asin(sin((day-80.0)*dtor)*sin_eps)/dtor;
    asun_glon=-ut*15.0;


    if(asun_glon<-180)
        asun_glon=asun_glon+360.0;
    end
    if(asun_glon>180)
        asun_glon=asun_glon-360.0;
    end


    [asun_mlat,asun_mlon,~,~,~,~]=gd2qd(asun_glat,asun_glon);
    mlt=(mlon-asun_mlon)/15.0;


    [mmpwind,mzpwind]=dwm07(mlt,mlat,kp);


    dwm_alt=dwm_altwgt(alt);


    dw=[((f2n*mmpwind+f1n*mzpwind)*dwm_alt);...
    ((f2e*mmpwind+f1e*mzpwind)*dwm_alt)];

end

function dwm_altwgt_out=dwm_altwgt(alt)
















    talt=125.0;
    twidth=5.0;

    dwm_altwgt_out=(1.0/(1+exp(-(alt-talt)/twidth)));

end

function[mmpwind,mzpwind]=dwm07(mlt,mlat,kp)


    S=coder.load('dwm07b_104i.mat');

    nterm=S.nterm;
    mmax=S.mmax;
    lmax=S.lmax;
    termarr=S.termarr;
    coeff=S.coeff;
    twidth=S.twidth;


    mltdeg=(15.0*mlt);
    vsh_terms=vsh_basis(mlat,mltdeg,mmax,lmax);


    kp_terms=dwm_kpspl3_calc(kp);


    latwgt_terms=dwm_latwgt2(mlat,mlt,kp,twidth);


    termval=zeros(2,nterm);
    termval_temp=[0;0];
    for iterm=1:nterm
        for k=1:2
            termval_temp(k)=1.0;
            if(termarr(iterm,1)~=999)
                termval_temp(k)=termval_temp(k)*vsh_terms(k,termarr(iterm,1)+1);
            end
            if(termarr(iterm,2)~=999)
                termval_temp(k)=termval_temp(k)*kp_terms(termarr(iterm,2)+1);
            end
            if(termarr(iterm,3)~=999)
                termval_temp(k)=termval_temp(k)*latwgt_terms;
            end
            termval(k,iterm)=termval_temp(k);
        end
    end

    accum_mmpwind=0.0;
    accum_mzpwind=0.0;
    for k=1:nterm
        accum_mmpwind=accum_mmpwind+coeff(k)*termval(1,k);
        accum_mzpwind=accum_mzpwind+coeff(k)*termval(2,k);
    end

    mmpwind=(accum_mmpwind);
    mzpwind=(accum_mzpwind);
end



function dwm_latwgt2_out=dwm_latwgt2(mlat,mlt,kp0,twidth)
























    coeff=[65.7633,-4.60256,-3.53915,-1.99971,-0.752193,0.972388];
    pi=3.141592653590;
    dtor=pi/180.0;

    mltrad=mlt*15.0*dtor;
    sinmlt=sin(mltrad);
    cosmlt=cos(mltrad);
    if(kp0>0)
        kp=kp0;
    else
        kp=0;
    end
    if(kp>8)
        kp=8;
    end
    tlat=coeff(1)+coeff(2)*cosmlt+coeff(3)*sinmlt+...
    kp*(coeff(4)+coeff(5)*cosmlt+coeff(6)*sinmlt);
    dwm_latwgt2_out=(1.0/(1+exp(-(abs((mlat))-tlat)/twidth)));
end

function dwm_kpspl3=dwm_kpspl3_calc(kp0)



















    dwm_kpspl3=zeros(3,1);
    node0=[-10.,-8.,0.,2.,5.,8.,18.,20.];

    if(kp0>0)
        kp=(kp0);
    else
        kp=0;
    end
    if(kp>8)
        kp=8;
    end
    kpspl=bspline_calc(8,kp,node0,2,0);

    dwm_kpspl3(1)=kpspl(1)+kpspl(2);
    dwm_kpspl3(2)=kpspl(3);
    dwm_kpspl3(3)=kpspl(4)+kpspl(5);

end

function bspline=bspline_calc(nnode0,x0,node0,order,periodic)
    perspan=0.0;
    perint=zeros(2,1);



    k=order+1;
    nnode=nnode0+periodic*order;
    nspl=nnode-k;
    x=x0;
    node=zeros(nnode,1);
    node1=zeros(nnode,1);
    bspline=zeros(nnode-1,1);
    bspline0=zeros(nnode-1,1);

    if(periodic==1)
        perint(1)=node0(1);
        perint(2)=node0(nnode0-1);
        perspan=perint(2)-perint(1);
        x=pershift(x,perint);
        node(1)=node0(1);
        for i=2:order+1
            node(i)=node0(i)+perspan;
        end
        for i=1:nnode0+order
            node1(i)=pershift(node(i),perint(1));
        end
    else
        for i=1:nnode
            node(i)=node0(i);
            node1(i)=node(i);
        end
    end

    for i=1:nnode-1
        bspline0(i)=0.0;
        if(node1(i+1)>node1(i))
            if((x>=node1(i))&&(x<node1(i+1)))
                bspline0(i)=1.0;
            end
        else
            if((x>=node1(i))||(x<node1(i+1)))
                bspline0(i)=1.0;
            end
        end
    end
    for j=2:k
        for i=1:nnode-j
            dx1=x-node1(i);
            dx2=node1(i+j)-x;
            if(periodic==1)
                if(dx1<0)
                    dx1=dx1+perspan;
                end
                if(dx2<0)
                    dx2=dx2+perspan;
                end
            end
            bspline0(i)=bspline0(i)*dx1/(node(i+j-1)-node(i))...
            +bspline0(i+1)*dx2/(node(i+j)-node(i+1));
        end
    end
    for i=1:nspl
        bspline(i)=bspline0(i);
    end

end

function pershift_out=pershift(x,perint)

















    offset=0.0;
    offset1=0.0;
    tol=1e-4;

    pershift_out=x;
    a=perint(1);
    span=perint(2)-perint(1);
    if(span~=0)
        offset=x-a;
        offset1=mod(offset,span);
        if(abs(offset1))<tol
            offset1=0;
        end
    end
    pershift_out=a+offset1;
    if((offset<0)&&(offset1~=0))
        pershift_out=pershift_out+span;
    end

end

function vsh_terms=vsh_basis(theta,phi,mmax,lmax)




























    fn_map0=zeros(2*2*(mmax+1)*(lmax+1)+1,4);
    fn_map1=zeros(2*2*(mmax+1)*(lmax+1)+1,4);


    ifn=0;
    for n=1:lmax+1
        for m=1:mmax+1
            if((m==1)&&(n==1))
                break;
            end
            if(m>n)
                break;
            end
            for j=1:2
                for i=1:2
                    if((m==1)&&(i==2))
                        break;
                    end
                    ifn=ifn+1;
                    fn_map0(ifn,1)=i-1;
                    fn_map0(ifn,2)=j-1;
                    fn_map0(ifn,3)=m-1;
                    fn_map0(ifn,4)=n-1;
                end
            end
        end
    end

    nvshfn=128;
    for ifn=1:nvshfn
        fn_map1(ifn,1)=fn_map0(ifn,1);
        fn_map1(ifn,2)=fn_map0(ifn,2);
        fn_map1(ifn,3)=fn_map0(ifn,3);
        fn_map1(ifn,4)=fn_map0(ifn,4);
    end




    A=zeros(mmax+1,lmax+1);
    B=zeros(mmax+1,lmax+1);
    anm=zeros(mmax+1,lmax+1);
    bnm=zeros(mmax+1,lmax+1);
    fnm=zeros(mmax+1,lmax+1);
    cm=zeros(mmax+1,1);
    cn=zeros(lmax+1,1);
    e0n=zeros(lmax+1,1);
    m_arr=zeros(mmax+1,1);
    n_arr=zeros(lmax+1,1);
    cosmz=zeros(mmax+1,1);
    sinmz=zeros(mmax+1,1);


    for m=1:mmax+1
        cm(m)=sqrt(1+0.5/(max(m-1,1)));
        m_arr(m)=(m-1);
    end
    for n=1:lmax+1
        n_arr(n)=(n-1);
        cn(n)=1/sqrt((max(n-1,1))*(n-1+1));
        e0n(n)=sqrt(((n-1)*(n-1+1))/2.0);
    end
    for m=1:mmax
        if(m==lmax)
            break;
        end
        for n=m+1:lmax
            anm(m,n)=sqrt(((2*n-1)*(2*n+1))/((n-m)*(n+m)));
            bnm(m,n)=sqrt(((2*n+1)*(n+m-1)*(n-m-1))/((n-m)*(n+m)*(2*n-3)));
            fnm(m,n)=sqrt(((n-m)*(n+m)*(2*n+1))/(2*n-1));
        end
    end


    pi=3.141592653590;
    dtor=pi/180.0;



    x=cos((90.-(theta))*dtor);
    y=sqrt(1-x*x);
    z=(phi)*dtor;


    if(mmax>=1)
        B(2,2)=sqrt((3.0));
    end
    for m=3:mmax+1
        B(m,m)=y*cm(m)*B(m-1,m-1);
    end
    for m=1:mmax
        for n=m+1:lmax
            B(m+1,n+1)=anm(m,n)*x*B(m+1,n)-bnm(m,n)*B(m+1,n-1);
        end
    end


    for m=1:mmax
        for n=m:lmax
            A(m+1,n+1)=n_arr(n+1)*x*B(m+1,n+1)-fnm(m,n)*B(m+1,n);
        end
    end
    for n=2:lmax+1
        A(1,n)=-e0n(n)*y*B(2,n);
    end


    for m=1:mmax+1
        if(m==1)
            norm_m=1.0/sqrt(2.0);
        else
            norm_m=0.5;
        end
        for n=m:lmax+1;
            B(m,n)=B(m,n)*m_arr(m)*cn(n)*norm_m;
            A(m,n)=A(m,n)*cn(n)*norm_m;
        end
    end



    for m=1:mmax+1
        mz=(m-1)*z;
        cosmz(m)=cos(mz);
        sinmz(m)=sin(mz);
    end

    vsh_terms=zeros(2,nvshfn);
    for ifn=1:nvshfn
        m=fn_map1(ifn,3)+1;
        n=fn_map1(ifn,4)+1;
        fn_id=fn_map1(ifn,1)+2*fn_map1(ifn,2);
        switch(fn_id)
        case 0
            vsh_terms(1,ifn)=(-A(m,n)*cosmz(m));
            vsh_terms(2,ifn)=(-B(m,n)*sinmz(m));
        case 1
            vsh_terms(1,ifn)=(A(m,n)*sinmz(m));
            vsh_terms(2,ifn)=(-B(m,n)*cosmz(m));
        case 2
            vsh_terms(1,ifn)=(B(m,n)*sinmz(m));
            vsh_terms(2,ifn)=(-A(m,n)*cosmz(m));
        case 3
            vsh_terms(1,ifn)=(B(m,n)*cosmz(m));
            vsh_terms(2,ifn)=(A(m,n)*sinmz(m));
        end
    end

end

function[qdlat,qdlon,f1e,f1n,f2e,f2n]=gd2qd(glat,glon)

    alt=250.0;
    hr=0.0;



    [qdlon,qdlat,f1,f2,ist]=aeroblkapex(glat,glon,alt,hr);

    if(ist>0)
        return;
    end

    f1e=f1(1);
    f1n=f1(2);
    f2e=f2(1);
    f2n=f2(2);

end

function kp=ap_to_kp(ap)









    apgrid=[0.,2.,3.,4.,5.,6.,7.,9.,12.,15.,18.,22.,27.,32.,...
    39.,48.,56.,67.,80.,94.,111.,132.,154.,179.,207.,236.,300.,400.];
    kpgrid=[0.,1./3.0,2./3.0,3./3.0,4./3.0,5./3.0,6./3.0,...
    7./3.0,8./3.0,9./3.0,10./3.0,11./3.0,12./3.0,13./3.0,14./3.0,15./3.0,...
    16./3.0,17./3.0,18./3.0,19./3.0,20./3.0,21./3.0,22./3.0,23./3.0,24./3.0,...
    25./3.0,26./3.0,27./3.0];


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
        ap_to_kps=kpgrid(i);
    else
        ap_to_kps=kpgrid(i-1)+(ap-apgrid(i-1))/(3.0*(apgrid(i)-apgrid(i-1)));
    end

    kp=ap_to_kps;
end
