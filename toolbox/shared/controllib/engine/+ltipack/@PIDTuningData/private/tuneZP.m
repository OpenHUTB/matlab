function[zC,pC,kC,zC2,pC2,kC2,PMopt,Fopt]=tuneZP(Gdata,wc,PMreq,get2DOF)

































    design=Gdata.DesignFocus;

    Ts=Gdata.Ts;
    mu_wc=Gdata.mu0;
    wG=Gdata.Frequency;
    magG=Gdata.Magnitude;
    phG=Gdata.Phase;


    DesignReqs=Gdata.Requirements;
    ConstraintFcn=DesignReqs.ConstraintFcn;


    TuningParams=DesignReqs.InitFcn(wc,Ts,DesignReqs);
    ALPHAMIN=TuningParams.ALPHAMIN;
    BETAMAX=TuningParams.BETAMAX;
    MAXPHASELEAD=BETAMAX-ALPHAMIN;
    PHASEINC=TuningParams.PHASEINC;


    idxc=find(wG==wc);
    mag_wc=magG(idxc);
    ph_wc=phG(idxc);
    if isempty(mag_wc)||mag_wc==0||isinf(mag_wc)
        kC=1;zC=zeros(0,1);pC=zeros(0,1);PMopt=0;Fopt=Inf;
        zC2=zC;pC2=pC;kC2=kC;return
    end
    kC0=1/mag_wc;
    magG=kC0*magG;


    nu=wG/wc;
    Tmax=1./max(1,nu/1.5);
    Tmin=1./max(1,1.5*nu);
    if Ts>0
        wcTs=wc*Ts;
        wTs=wG*Ts;sinwTs=sin(wTs);coswTs=cos(wTs);
        gam2=4*sin(wTs/2).^2;
    else
        wcTs=0;sinwTs=[];coswTs=[];
        gam2=nu.^2-1;
    end


    PhaseLead=(2*mu_wc-1)*pi+PMreq-ph_wc;
    if PhaseLead>=MAXPHASELEAD

        npts=1;
        PhiLs=MAXPHASELEAD;
    else

        lb=max(0,PhaseLead);
        npts=max(2,round((MAXPHASELEAD-lb)/PHASEINC));
        PhiLs=linspace(lb,MAXPHASELEAD,npts);
    end

    PhaseLead0=PhiLs(1);
    dcgainC0=cos(PhaseLead0/2)*cos(PhaseLead0/2);

    Lroll0=min(1./nu,1/0.01);
    Lroll0(nu>=1/1.5)=0;
    [~,C1]=optControllerParamrs(PhaseLead0,ALPHAMIN,BETAMAX,0,0,'ZP');
    [magC1,~]=getC(C1(1),C1(2),nu,Ts,gam2,wcTs,sinwTs,coswTs);
    magOL1=magG.*magC1;
    Lroll=max(max(magOL1,1./nu),0.05);
    Lroll(nu<=1.5)=inf;

    Fopt=Inf;PMopt=0;PhiL=[];Theta=[];
    MIDPOINT=(ALPHAMIN+BETAMAX)/2;
    k=1;f=inf(1,9);
    for ct=1:npts
        phi=PhiLs(ct);

        thmax=min(phi,MAXPHASELEAD-phi);
        n=ceil(thmax/PHASEINC);
        aux=linspace(0,thmax,n+1);
        Thetas=zeros(2*n+1,1);
        Thetas(3:2:2*n+1,1)=aux(2:n+1);
        Thetas(2:2:2*n+1,1)=-aux(2:n+1);
        for j=1:2*n+1

            th=Thetas(j);
            alpha=MIDPOINT+(th-phi)/2;
            beta=MIDPOINT+(th+phi)/2;
            if isempty(ConstraintFcn)||ConstraintFcn(0,alpha,beta,wc,Ts,DesignReqs)

                if isempty(PhiL)

                    PhiL=phi;Theta=th;
                end

                [magC,phC]=getC(alpha,beta,nu,Ts,gam2,wcTs,sinwTs,coswTs);

                magOL=magG.*magC;phOL=phG+phC;
                PM=checkOL(wG,magOL,phOL,wc,ph_wc+beta-alpha,mu_wc);
                if PM>=.99*PMreq

                    dcgainC=magC(1);
                    magS=1./sqrt(1+magOL.^2+2*magOL.*cos(phOL));
                    magT=magOL.*magS;
                    magST=sqrt(1+magOL.^2-2*magOL.*cos(phOL)).*magS;

                    if design==0
                        F=max([magT-Tmax;Tmin-magT;magS-2]);
                        if F<Fopt
                            Fopt=F;PMopt=PM;PhiL=phi;Theta=th;
                        end
                        if F<=0.05,
                            break;
                        end
                    else
                        f(k,:)=getF(dcgainC0,dcgainC,PMreq,nu,magOL,magT,magST,Lroll0,Lroll,PM,0,alpha,beta);
                        k=k+1;
                    end
                end
            end
        end
        if design==0

            if Fopt<Inf
                break
            end
        end
    end
    if design~=0
        [Fopt,PMopt,~,alpha,beta]=getOptimalDesign(f,design);
        if isempty(alpha)

            alpha=MIDPOINT+(Theta-PhiL)/2;
            beta=MIDPOINT+(Theta+PhiL)/2;
        end
    else

        alpha=MIDPOINT+(Theta-PhiL)/2;
        beta=MIDPOINT+(Theta+PhiL)/2;
    end



    [zC,pC,kC]=getZPKData(alpha,beta,kC0,Ts,wc,wcTs);
    F2opt=inf;beta2=[];

    if get2DOF





        gammas=linspace(ALPHAMIN,pi/4,40);
        gammas=[ALPHAMIN,atan(tan(beta-wcTs/2).*tan(gammas))+wcTs/2];

        [magC,phC]=getC(alpha,beta,nu,Ts,gam2,wcTs,sinwTs,coswTs);
        magOL=magG.*magC;phOL=phG+phC;
        magT=magOL./sqrt(1+magOL.^2+2*magOL.*cos(phOL));



        wn=1/3;
        Tupp=1.01./sqrt((1-(nu/wn).^2).^2+(2*0.2*(nu/wn)).^2);
        Tupp(nu>0.1)=inf;
        Tlow=(1./sqrt(1+(2*nu).^2)).^2;
        Tlow(nu>0.1)=0;
        Tmax=max(magT(nu>0.1));
        for i=1:length(gammas)
            gamma=gammas(i);
            if gamma>=alpha
                [magT2,kC2]=getC2Data(gamma,alpha,kC0,nu,magC,magT,Ts,gam2,wcTs,sinwTs,coswTs);
                F2=getF2(magT2,Tupp,Tlow,Tmax);
                if F2<F2opt
                    F2opt=F2;
                    beta2=gamma;kC2opt=kC2;



                end
            end
        end
        if~isempty(beta2)
            [zC2,pC2,kC2]=getZPKData(alpha,beta2,kC2opt,Ts,wc,wcTs);
        else
            zC2=zC;pC2=pC;kC2=kC;
        end
    else
        zC2=zC;pC2=pC;kC2=kC;
    end

    function[zC,pC,kC]=getZPKData(alpha,beta,kC,Ts,wc,wcTs)

        zC=zeros(0,1);
        pC=zeros(0,1);
        if isempty(alpha)
            kC=NaN;
        elseif beta~=alpha
            if Ts==0
                zC=-wc/tan(beta);
                pC=-wc/tan(alpha);
                kC=kC*(sin(beta)/sin(alpha));
            else
                sinBeta=sin(beta);sinAlpha=sin(alpha);
                zC=sin(beta-wcTs)/sinBeta;
                pC=sin(alpha-wcTs)/sinAlpha;
                kC=kC*(sinBeta/sinAlpha);
            end
        end

        function[magC,phC]=getC(alpha,beta,nu,Ts,gam2,wcTs,sinwTs,coswTs)

            if Ts==0
                magC=sqrt((1+sin(beta)^2*gam2)./(1+sin(alpha)^2*gam2));
                phC=atan(tan(beta)*nu)-atan(tan(alpha)*nu);
            else
                atau1=sin(alpha);atau2=sin(alpha-wcTs);
                btau1=sin(beta);btau2=sin(beta-wcTs);
                magC=sqrt(((btau1-btau2)^2+(btau1*btau2)*gam2)./...
                ((atau1-atau2)^2+(atau1*atau2)*gam2));
                phC=atan2(btau2*sinwTs,btau1-btau2*coswTs)-...
                atan2(atau2*sinwTs,atau1-atau2*coswTs);
            end

            function[magT2,kC2]=getC2Data(gamma,alpha,kC,nu,magC,magT,Ts,gam2,wcTs,sinwTs,coswTs)

                [magC2,~]=getC(alpha,gamma,nu,Ts,gam2,wcTs,sinwTs,coswTs);
                K0=magC(1)/magC2(1);
                magC2=magC2*K0;
                kC2=kC*K0;
                magC2byC=magC2./magC;
                magT2=magT.*magC2byC;