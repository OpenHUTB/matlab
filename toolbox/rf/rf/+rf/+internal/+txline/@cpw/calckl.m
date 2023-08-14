function[y,Z0_f,Ere_f]=calckl(h,varargin)






    if nargin==2
        freq=varargin{:};
    end


    c0=rf.physconst('LightSpeed');
    mu0=pi*4e-7;


    len=get(h,'LineLength');
    width=get(h,'ConductorWidth');
    slotwidth=get(h,'SlotWidth');
    height=get(h,'Height');
    thickness=get(h,'Thickness');
    Er=get(h,'EpsilonR');
    sigmacond=get(h,'SigmaCond');
    losstan=get(h,'LossTangent');





    a=width/2;
    b=width/2+slotwidth;

    k1=a/b;

    t1=sinh(pi*a/(2*height));
    t2=sinh(pi*b/(2*height));

    k2=t1/t2;

    t1=tanh(pi*a/(2*height));
    t2=tanh(pi*b/(2*height));
    k6=t1/t2;



    K_k1=ellipke(k1);
    K_k2=ellipke(k2);
    K_k6=ellipke(k6);


    kp1=sqrt(1-k1^2);
    Kp_k1=ellipke(kp1);


    kp2=sqrt(1-k2^2);
    Kp_k2=ellipke(kp2);

    kp6=sqrt(1-k6^2);
    Kp_k6=ellipke(kp6);

    if h.ConductorBacked
        q=(K_k6/Kp_k6)/((K_k1/Kp_k1)+(K_k6/Kp_k6));
    else

        q=0.5*K_k2/Kp_k2*Kp_k1/K_k1;
    end



    Ere_t=1+q*(Er-1);



    if thickness
        Ere=Ere_t-(0.7*(Ere_t-1)*(thickness/slotwidth))/(K_k1/Kp_k1+0.7...
        *(thickness/slotwidth));
    else
        Ere=Ere_t;
    end



    if nargin==2
        p=log(2*a/height);

        u=0.54-0.64*p+0.015*p^2;
        v=0.43-0.86*p+0.54*p^2;

        G=exp(u*log(2*a/(b-a))+v);



        fTE=c0/(4*height*sqrt(Er-1));




        Ere_f=(sqrt(Ere)+(sqrt(Er)-sqrt(Ere))./(1+G*(freq/fTE).^-1.8)).^2;
    else
        Ere_f=Ere;
    end




    delta=0;
    if thickness
        delta=1.25*thickness/pi*(1+log(4*pi*width/thickness));
    end

    we=width+delta;
    se=slotwidth-delta;

    k1e=we/(we+2*se);

    K_k1e=ellipke(k1e);





    kp=sqrt(1-k1e^2);
    Kp_k1e=ellipke(kp);

    ae=we/2;
    be=we/2+se;
    t1=tanh(pi*ae/(2*height));
    t2=tanh(pi*be/(2*height));
    k6e=t1/t2;
    K_k6e=ellipke(k6e);
    kp6e=sqrt(1-k6e^2);
    Kp_k6e=ellipke(kp6e);

    if h.ConductorBacked
        Z0_f=(60*pi./sqrt(Ere_f))./((K_k1e/Kp_k1e)+(K_k6e/Kp_k6e));
    else


        Z0_f=30*pi*Kp_k1e/K_k1e./sqrt(Ere_f);
    end

    if nargin==1
        y=[];
        return
    end


    lambda0=c0./freq;
    w=2*pi*freq;


    pv=c0./sqrt(Ere_f);
    beta=w./pv;




    Rs=sqrt(pi*freq*mu0./sigmacond);


    alpha_d=27.3*Er/(Er-1)*(Ere_f-1).*losstan./sqrt(Ere_f)./lambda0;



    tempA=(pi+log((8*pi*a*(1-k1))/(thickness*(1+k1))))/a;
    tempB=(pi+log((8*pi*b*(1-k1))/(thickness*(1+k1))))/b;
    alpha_c=8.68*Rs.*sqrt(Ere_f)./(480*pi*K_k1*Kp_k1*(1-k1^2))*...
    (tempA+tempB);

    alphadB=alpha_d+alpha_c;
    alphadB(alphadB==inf)=1/eps;
    alpha=log(10.^(alphadB/20));


    set(h,'PV',pv)
    set(h,'Loss',alphadB)

    k=alpha+1i*beta;
    y=exp(-len*k);
end
