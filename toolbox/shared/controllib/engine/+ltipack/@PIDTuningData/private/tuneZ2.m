function[zC,pC,kC,zC2,pC2,kC2,PMopt,Fopt]=tuneZ2(Gdata,wc,PMreq,get2DOF)
































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
    MINPHASELEAD=2*PHIZMIN;
    MAXPHASELEAD=2*PHIZMAX;


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

        lb=max(MINPHASELEAD,PhaseLead);
        PhiLs=linspace(lb,MAXPHASELEAD,max(2,round((MAXPHASELEAD-lb)/PHASEINC)));
    end


    PhaseLead0=PhiLs(1);
    dcgainC0=cos(PhaseLead0/2)*cos(PhaseLead0/2);

    Lroll0=min(1./nu,1/0.01);
    Lroll0(nu>=1/1.5)=0;
    [~,C1]=optControllerParamrs(PhaseLead0,0,0,PHIZMIN,PHIZMAX,'Z2');
    [magC1,~]=getC(C1(2),C1(3),nu,Ts,gam2,wcTs,sinwTs,coswTs,sinwcTs,wTs);
    magOL1=magG.*magC1;
    Lroll=max(max(magOL1,1./nu),0.05);
    Lroll(nu<=1.5)=inf;

    Fopt=Inf;PMopt=0;Phiz1=[];Phiz2=[];
    k=1;f=inf(1,9);
    for ct=1:numel(PhiLs)
        phiX=PhiLs(ct)/2;


        thmax=min(phiX-PHIZMIN,PHIZMAX-phiX);
        if thmax==0
            Thetas=0;
        else
            Thetas=linspace(0,thmax,max(2,ceil(thmax/PHASEINC)));
        end
        for j=1:numel(Thetas)

            th=Thetas(j);
            phi1=phiX-th;phi2=phiX+th;
            if isempty(ConstraintFcn)||ConstraintFcn(phi1,0,phi2,wc,Ts,DesignReqs)

                if isempty(Phiz1)

                    Phiz1=phi1;Phiz2=phi2;
                end

                [magC,phC]=getC(phi1,phi2,nu,Ts,gam2,wcTs,sinwTs,coswTs,sinwcTs,wTs);

                magOL=magG.*magC;phOL=phG+phC;
                PM=checkOL(wG,magOL,phOL,wc,ph_wc+2*phiX,mu_wc);
                if PM>=.99*PMreq

                    dcgainC=magC(1);
                    magS=1./sqrt(1+magOL.^2+2*magOL.*cos(phOL));
                    magT=magOL.*magS;
                    magST=sqrt(1+magOL.^2-2*magOL.*cos(phOL)).*magS;

                    if design==0
                        F=max([magT-Tmax;Tmin-magT;magS-2]);
                        if F<Fopt
                            Fopt=F;PMopt=PM;Phiz1=phi1;Phiz2=phi2;
                        end
                        if F<=0.05,
                            break;
                        end
                    else
                        f(k,:)=getF(dcgainC0,dcgainC,PMreq,nu,magOL,magT,magST,Lroll0,Lroll,PM,phi1,0,phi2);
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
        [Fopt,PMopt,phiz1Opt,~,phiz2Opt]=getOptimalDesign(f,design);
        if~isempty(phiz1Opt)
            Phiz1=phiz1Opt;
            Phiz2=phiz2Opt;
        end
    end




    [zC,pC,kC]=getZPKData(Phiz1,Phiz2,kC0,Ts,wc,wcTs,sinwcTs);
    F2opt=inf;Phiz12=[];

    if get2DOF






        gamma0=max(Phiz1,Phiz2)-wcTs/2;
        gammaG0=[linspace(1,45,20),linspace(45,85,20)]*pi/180;
        gammaG=[PHIZMIN,atan(tan(gammaG0)*tan(gamma0))+wcTs/2];
        gammaG(gammaG>PHIZMAX)=[];



        psi0=min(Phiz1,Phiz2)-wcTs/2;
        psiG=linspace(PHIZMIN,pi/4,40);
        psiG=[PHIZMIN,atan(tan(psi0).*tan(psiG))+wcTs/2];

        [gammas,psis]=ndgrid(gammaG,psiG);

        gammas=gammas(:);psis=psis(:);
        [magC,phC]=getC(Phiz1,Phiz2,nu,Ts,gam2,wcTs,sinwTs,coswTs,sinwcTs,wTs);
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
            psi=psis(i);
            if gamma>=psi
                [magT2,kC2]=getC2Data(gamma,psi,kC0,nu,magC,magT,Ts,gam2,wcTs,sinwTs,coswTs,sinwcTs,wTs);
                F2=getF2(magT2,Tupp,Tlow,Tmax);
                if F2<F2opt
                    F2opt=F2;
                    Phiz12=gamma;Phiz22=psi;kC2opt=kC2;



                end
            end
        end
        if~isempty(Phiz12)
            [zC2,pC2,kC2]=getZPKData(Phiz12,Phiz22,kC2opt,Ts,wc,wcTs,sinwcTs);
        else
            zC2=zC;pC2=pC;kC2=kC;
        end
    else
        zC2=zC;pC2=pC;kC2=kC;
    end

    function[magC,phC]=getC(phi1,phi2,nu,Ts,gam2,wcTs,sinwTs,coswTs,sinwcTs,wTs)

        if Ts==0
            magC=sqrt((1+sin(phi1)^2*gam2).*(1+sin(phi2)^2*gam2));
            phC=atan(tan(phi1)*nu)+atan(tan(phi2)*nu);
        else
            tau1=[sin(phi1),sin(phi1-wcTs)];
            tau2=[sin(phi2),sin(phi2-wcTs)];
            magC=sqrt(((tau1(1)-tau1(2))^2+(tau1(1)*tau1(2))*gam2).*...
            ((tau2(1)-tau2(2))^2+(tau2(1)*tau2(2))*gam2))/sinwcTs^2;
            if tau1(2)<-tau1(1)
                phC=-pi/2+atan2(tau1(1)*coswTs-tau1(2),-tau1(1)*sinwTs);
            else
                phC=wTs+atan2(tau1(2)*sinwTs,tau1(1)-tau1(2)*coswTs);
            end
            if tau2(2)<-tau2(1)
                phC=phC+atan2(tau2(1)*coswTs-tau2(2),-tau2(1)*sinwTs)-pi/2;
            else
                phC=phC+wTs+atan2(tau2(2)*sinwTs,tau2(1)-tau2(2)*coswTs);
            end
        end

        function[zC,pC,kC]=getZPKData(Phiz1,Phiz2,kC,Ts,wc,wcTs,sinwcTs)

            zC=zeros(0,1);
            pC=zeros(0,1);
            if isempty(Phiz1)
                kC=NaN;
            else
                if Phiz1>0
                    if Ts==0
                        zC=[zC;-wc/tan(Phiz1)];
                        kC=kC*(sin(Phiz1)/wc);
                    else
                        sinPhiz1=sin(Phiz1);
                        zC=[zC;sin(Phiz1-wcTs)/sinPhiz1];
                        kC=kC*(sinPhiz1/sinwcTs);
                    end
                end
                if Phiz2>0
                    if Ts==0
                        zC=[zC;-wc/tan(Phiz2)];
                        kC=kC*(sin(Phiz2)/wc);
                    else
                        sinPhiz2=sin(Phiz2);
                        zC=[zC;sin(Phiz2-wcTs)/sinPhiz2];
                        kC=kC*(sinPhiz2/sinwcTs);
                    end
                end
            end

            function[magT2,kC2]=getC2Data(gamma,psi,kC,nu,magC,magT,Ts,gam2,wcTs,sinwTs,coswTs,sinwcTs,wTs)

                [magC2,~]=getC(gamma,psi,nu,Ts,gam2,wcTs,sinwTs,coswTs,sinwcTs,wTs);
                K0=magC(1)/magC2(1);
                magC2=magC2*K0;
                kC2=kC*K0;
                magC2byC=magC2./magC;
                magT2=magT.*magC2byC;

