function[zC,pC,kC,zC2,pC2,kC2,PMopt,Fopt]=tuneZ(Gdata,wc,PMreq,get2DOF)




































    design=Gdata.DesignFocus;

    Ts=Gdata.Ts;
    mu_wc=Gdata.mu0;
    wG=Gdata.Frequency;
    magG=Gdata.Magnitude;
    phG=Gdata.Phase;


    DesignReqs=Gdata.Requirements;
    ConstraintFcn=DesignReqs.ConstraintFcn;


    TuningParams=DesignReqs.InitFcn(wc,Ts,DesignReqs);
    PHIZMIN=TuningParams.PHIZMIN;
    PHIZMAX=TuningParams.PHIZMAX;
    PHASEINC=TuningParams.PHASEINC;
    MAXPHASELEAD=PHIZMAX;


    idxc=find(wG==wc);
    mag_wc=magG(idxc);
    ph_wc=phG(idxc);
    if mag_wc==0||isinf(mag_wc)
        kC=1;zC=zeros(0,1);pC=zeros(0,1);PMopt=0;Fopt=Inf;
        zC2=zC;pC2=pC;kC2=kC;return
    end
    kC0=1/mag_wc;
    magG=kC0*magG;


    nu=wG/wc;
    Tmax=1./max(1,nu/1.5);
    Tmin=1./max(1,1.5*nu);
    if Ts>0
        wcTs=wc*Ts;sinwcTs=sin(wcTs);
        wTs=wG*Ts;sinwTs=sin(wTs);coswTs=cos(wTs);
        gam2=4*sin(wTs/2).^2;
    else
        wcTs=0;sinwTs=[];coswTs=[];sinwcTs=[];wTs=[];
        gam2=nu.^2-1;
    end


    PhaseLead=(2*mu_wc-1)*pi+PMreq-ph_wc;
    if PhaseLead>=MAXPHASELEAD

        PhiLs=MAXPHASELEAD;
    else

        lb=max(PHIZMIN,PhaseLead);
        PhiLs=linspace(lb,PHIZMAX,max(1,ceil((PHIZMAX-lb)/PHASEINC)));
    end


    PhaseLead0=PhiLs(1);
    dcgainC0=cos(PhaseLead0/2)*cos(PhaseLead0/2);

    Lroll0=min(1./nu,1/0.01);
    Lroll0(nu>=1/1.5)=0;
    [~,C1]=optControllerParamrs(PhaseLead0,0,0,PHIZMIN,PHIZMAX,'Z');
    [magC1,~]=getC(C1(3),nu,Ts,gam2,wcTs,sinwTs,coswTs,sinwcTs,wTs);
    magOL1=magG.*magC1;
    Lroll=max(max(magOL1,1./nu),0.05);
    Lroll(nu<=1.5)=inf;

    Fopt=Inf;PMopt=0;Phiz=[];
    f=inf;
    for ct=1:numel(PhiLs)
        phi=PhiLs(ct);
        if isempty(ConstraintFcn)||ConstraintFcn(phi,0,0,wc,Ts,DesignReqs)

            if isempty(Phiz)

                Phiz=phi;
            end

            [magC,phC]=getC(phi,nu,Ts,gam2,wcTs,sinwTs,coswTs,sinwcTs,wTs);

            magOL=magG.*magC;phOL=phG+phC;
            PM=checkOL(wG,magOL,phOL,wc,ph_wc+phi,mu_wc);
            if PM>=.99*PMreq


                dcgainC=magC(1);
                magS=1./sqrt(1+magOL.^2+2*magOL.*cos(phOL));
                magT=magOL.*magS;
                magST=sqrt(1+magOL.^2-2*magOL.*cos(phOL)).*magS;

                if design==0
                    Fopt=max([magT-Tmax;Tmin-magT;magS-2]);
                    Phiz=phi;PMopt=PM;
                    break;
                else
                    f=getF(dcgainC0,dcgainC,PMreq,nu,magOL,magT,magST,Lroll0,Lroll,PM,phi,0,0);
                    break;
                end
            end
        end
    end
    if design~=0
        [Fopt,PMopt,phizOpt,~,~]=getOptimalDesign(f,design);
        if~isempty(phizOpt)
            Phiz=phizOpt;
        end
    end



    [zC,pC,kC]=getZPKData(Phiz,kC0,Ts,wc,wcTs,sinwcTs);
    F2opt=inf;Phiz2=[];

    if get2DOF





        gammas=linspace(PHIZMIN,pi/4,40);
        gammas=[PHIZMIN,atan(tan(Phiz-wcTs/2).*tan(gammas))+wcTs/2];

        [magC,phC]=getC(Phiz,nu,Ts,gam2,wcTs,sinwTs,coswTs,sinwcTs,wTs);
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
            if gamma>wcTs/2
                [magT2,kC2]=getC2Data(gamma,kC0,nu,magC,magT,Ts,gam2,wcTs,sinwTs,coswTs,sinwcTs,wTs);
                F2=getF2(magT2,Tupp,Tlow,Tmax);
                if F2<F2opt
                    F2opt=F2;
                    Phiz2=gamma;kC2opt=kC2;



                end
            end
        end
        if~isempty(Phiz2)
            [zC2,pC2,kC2]=getZPKData(Phiz2,kC2opt,Ts,wc,wcTs,sinwcTs);
        else
            zC2=zC;pC2=pC;kC2=kC;
        end
    else
        zC2=zC;pC2=pC;kC2=kC;
    end

    function[magC,phC]=getC(phi,nu,Ts,gam2,wcTs,sinwTs,coswTs,sinwcTs,wTs)
        if Ts==0
            magC=sqrt(1+sin(phi)^2*gam2);
            phC=atan(tan(phi)*nu);
        else
            tau1=sin(phi);tau2=sin(phi-wcTs);
            magC=sqrt((tau1-tau2)^2+(tau1*tau2)*gam2)/sinwcTs;
            if tau2<-tau1
                phC=-pi/2+atan2(tau1*coswTs-tau2,-tau1*sinwTs);
            else
                phC=wTs+atan2(tau2*sinwTs,tau1-tau2*coswTs);
            end
        end

        function[zC,pC,kC]=getZPKData(Phiz,kC,Ts,wc,wcTs,sinwcTs)

            pC=zeros(0,1);
            zC=zeros(0,1);
            if isempty(Phiz)
                kC=NaN;
            elseif Phiz>0
                if Ts==0
                    zC=-wc/tan(Phiz);
                    kC=kC*(sin(Phiz)/wc);
                else
                    sinPhiz=sin(Phiz);
                    zC=sin(Phiz-wcTs)/sinPhiz;
                    kC=kC*(sinPhiz/sinwcTs);
                end
            end

            function[magT2,kC2]=getC2Data(gamma,kC,nu,magC,magT,Ts,gam2,wcTs,sinwTs,coswTs,sinwcTs,wTs)

                [magC2,~]=getC(gamma,nu,Ts,gam2,wcTs,sinwTs,coswTs,sinwcTs,wTs);
                K0=magC(1)/magC2(1);
                magC2=magC2*K0;
                kC2=kC*K0;
                magC2byC=magC2./magC;
                magT2=magT.*magC2byC;