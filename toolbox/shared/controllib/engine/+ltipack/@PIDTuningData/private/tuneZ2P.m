function[zC,pC,kC,zC2,pC2,kC2,PMopt,Fopt]=tuneZ2P(Gdata,wc,PMreq,get2DOF)


































    design=Gdata.DesignFocus;

    Ts=Gdata.Ts;
    mu_wc=Gdata.mu0;
    wG=Gdata.Frequency;
    magG=Gdata.Magnitude;
    phG=Gdata.Phase;


    DesignReqs=Gdata.Requirements;
    DTStd=(Ts>0&&DesignReqs.Form=='S');
    if DTStd
        TanConstr=(DesignReqs.IFormula=='B'&&DesignReqs.DFormula~='B');
    end
    ConstraintFcn=DesignReqs.ConstraintFcn;


    TuningParams=DesignReqs.InitFcn(wc,Ts,DesignReqs);
    PHIZMIN=TuningParams.PHIZMIN;
    PHIZMAX=TuningParams.PHIZMAX;
    ALPHAMIN=TuningParams.ALPHAMIN;
    BETAMAX=TuningParams.BETAMAX;
    PHASEINC=TuningParams.PHASEINC;
    MAXPHASELEAD=PHIZMAX+BETAMAX-ALPHAMIN;


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


    PMreqGrid=PMreq+[0,1,2]*PHASEINC;
    PMreqGrid(PMreqGrid>pi/2)=[];
    PhaseLead=(2*mu_wc-1)*pi+PMreqGrid-ph_wc;
    PhaseLead(PhaseLead>MAXPHASELEAD)=[];

    MIDPOINT=(ALPHAMIN+BETAMAX)/2;
    if isempty(PhaseLead)

        Alphas=ALPHAMIN;Betas=BETAMAX;
        delPhis=MAXPHASELEAD;
        PhaseLead=MAXPHASELEAD;
    else

        [Alphas,Betas,delPhis]=ndgrid(linspace(ALPHAMIN,MIDPOINT,10),...
        linspace(MIDPOINT,BETAMAX,10),PhaseLead);

        [~,is]=sort(Betas(:)-Alphas(:));
        Alphas=Alphas(is);Betas=Betas(is);delPhis=delPhis(is);
    end
    N=length(Alphas);


    PhaseLead0=max(PHIZMIN,min(PhaseLead));
    dcgainC0=cos(PhaseLead0/2)*cos(PhaseLead0/2);

    Lroll0=min(1./nu,1/0.01);
    Lroll0(nu>=1/1.5)=0;
    [~,C1]=optControllerParamrs(PhaseLead0,ALPHAMIN,BETAMAX,PHIZMIN,PHIZMAX,'Z2P');
    [magC1,~]=getC(C1(1),C1(2),C1(3),nu,Ts,gam2,wcTs,sinwTs,coswTs,sinwcTs,wTs);
    magOL1=magG.*magC1;
    Lroll=max(max(magOL1,1./nu),0.05);
    Lroll(nu<=1.5)=inf;

    Fopt=Inf;PMopt=0;Angles=[];
    f=inf(N,9);
    for ct=1:numel(Alphas)
        alpha=Alphas(ct);
        beta=Betas(ct);
        delPhi=delPhis(ct);

        phi=max(PHIZMIN,delPhi+alpha-beta);
        if DTStd

            if alpha<beta
                phi=max(phi,alpha);
            elseif TanConstr
                phi=max(phi,1.01*wcTs);
            end
        end

        if phi<=1.001*PHIZMAX&&...
            (isempty(ConstraintFcn)||ConstraintFcn(phi,alpha,beta,wc,Ts,DesignReqs))

            if isempty(Angles)

                Angles=[phi,alpha,beta];
            end

            [magC,phC]=getC(alpha,beta,phi,nu,Ts,gam2,wcTs,sinwTs,coswTs,sinwcTs,wTs);


            magOL=magG.*magC;phOL=phG+phC;
            PM=checkOL(wG,magOL,phOL,wc,ph_wc+phi+beta-alpha,mu_wc);
            if PM>=.99*PMreq

                dcgainC=magC(1);
                magS=1./sqrt(1+magOL.^2+2*magOL.*cos(phOL));
                magT=magOL.*magS;
                magST=sqrt(1+magOL.^2-2*magOL.*cos(phOL)).*magS;

                if design==0
                    if delPhi==min(PhaseLead)
                        F=max([magT-Tmax;Tmin-magT;magS-2]);
                        if F<Fopt
                            Fopt=F;PMopt=PM;Angles=[phi,alpha,beta];
                        end
                        if F<=0.05
                            break;
                        end
                    end
                else
                    f(ct,:)=getF(dcgainC0,dcgainC,PMreq,nu,magOL,magT,magST,Lroll0,Lroll,PM,phi,alpha,beta);
                end
            end
        end
    end

    if design~=0
        [Fopt,PMopt,phiOpt,alphaOpt,betaOpt]=getOptimalDesign(f,design);
        if~isempty(phiOpt)
            Angles=[phiOpt,alphaOpt,betaOpt];
        end
    end

    [zC,pC,kC]=getZPKData(Angles,kC0,Ts,wc,wcTs,sinwcTs);
    F2opt=inf;Angles2=[];

    if get2DOF





        alpha=Angles(2);
        beta=Angles(3);
        phi=Angles(1);



        gamma0=max(beta,phi)-wcTs/2;
        gammaG0=[linspace(1,45,20),linspace(45,85,20)]*pi/180;
        gammaG=[PHIZMIN,atan(tan(gammaG0)*tan(gamma0))+wcTs/2];
        gammaG(gammaG>BETAMAX)=[];



        psi0=min(beta,phi)-wcTs/2;
        psiG=linspace(PHIZMIN,pi/4,40);
        psiG=[PHIZMIN,atan(tan(psi0).*tan(psiG))+wcTs/2];



        [gammas,psis,alphas]=ndgrid(gammaG,psiG,alpha);

        gammas=gammas(:);psis=psis(:);alphas=alphas(:);
        alphas(gammas==PHIZMIN&psis==PHIZMIN)=PHIZMIN;

        [magC,phC]=getC(alpha,beta,phi,nu,Ts,gam2,wcTs,sinwTs,coswTs,sinwcTs,wTs);
        magOL=magG.*magC;phOL=phG+phC;
        magT=magOL./sqrt(1+magOL.^2+2*magOL.*cos(phOL));



        wn=1/3;
        Tupp=1.01./sqrt((1-(nu/wn).^2).^2+(2*0.2*(nu/wn)).^2);
        Tupp(nu>0.1)=max(magT(nu>0.1));
        Tlow=(1./sqrt(1+(2*nu).^2)).^2;
        Tlow(nu>0.1)=0;
        Tmax=max(magT(nu>0.1));
        for i=1:length(gammas)
            gamma=gammas(i);
            psi=psis(i);
            alpha=alphas(i);
            if gamma>=psi&&sum(sign([phi,beta]-alpha))==sum(sign([psi,gamma]-alpha))


                [magT2,kC2]=getC2Data(gamma,psi,alpha,kC0,nu,magC,magT,Ts,gam2,wcTs,sinwTs,coswTs,sinwcTs,wTs);
                F2=getF2(magT2,Tupp,Tlow,Tmax);
                if F2<F2opt
                    F2opt=F2;
                    Angles2=[psi,alpha,gamma];kC2opt=kC2;



                end
            end
        end
        if~isempty(Angles2)
            [zC2,pC2,kC2]=getZPKData(Angles2,kC2opt,Ts,wc,wcTs,sinwcTs);
        else
            zC2=zC;pC2=pC;kC2=kC;
        end
    else
        zC2=zC;pC2=pC;kC2=kC;
    end

    function[magC,phC]=getC(alpha,beta,phi,nu,Ts,gam2,wcTs,sinwTs,coswTs,sinwcTs,wTs)

        if Ts==0
            magC=sqrt((1+sin(phi)^2*gam2).*(1+sin(beta)^2*gam2)./...
            (1+sin(alpha)^2*gam2));
            phC=atan(tan(phi)*nu)+atan(tan(beta)*nu)-atan(tan(alpha)*nu);

        else
            tau1=sin(phi);tau2=sin(phi-wcTs);
            atau1=sin(alpha);atau2=sin(alpha-wcTs);
            btau1=sin(beta);btau2=sin(beta-wcTs);
            magC=sqrt(max(0,(tau1-tau2)^2+(tau1*tau2)*gam2).*...
            max(0,(btau1-btau2)^2+(btau1*btau2)*gam2)./...
            max(0,(atau1-atau2)^2+(atau1*atau2)*gam2))/sinwcTs;
            if tau2<-tau1
                phC=-pi/2+atan2(tau1*coswTs-tau2,-tau1*sinwTs);
            else
                phC=wTs+atan2(tau2*sinwTs,tau1-tau2*coswTs);
            end
            phC=phC+atan2(btau2*sinwTs,btau1-btau2*coswTs)-...
            atan2(atau2*sinwTs,atau1-atau2*coswTs);
        end

        function[magT2,kC2]=getC2Data(gamma,psi,alpha,kC,nu,magC,magT,Ts,gam2,wcTs,sinwTs,coswTs,sinwcTs,wTs)

            [magC2,~]=getC(alpha,gamma,psi,nu,Ts,gam2,wcTs,sinwTs,coswTs,sinwcTs,wTs);
            K0=magC(1)/magC2(1);
            magC2=magC2*K0;
            kC2=kC*K0;
            magC2byC=magC2./magC;
            magT2=magT.*magC2byC;




            function[zC,pC,kC]=getZPKData(Angles,kC,Ts,wc,wcTs,sinwcTs)

                zC=zeros(0,1);
                pC=zeros(0,1);
                if isempty(Angles)
                    kC=NaN;
                else

                    Phiz=Angles(1);
                    alpha=Angles(2);
                    beta=Angles(3);

                    if alpha==Phiz
                        tmp=Phiz;Phiz=beta;beta=tmp;
                    end
                    if Phiz>0
                        if Ts==0
                            zC=[zC;-wc/tan(Phiz)];
                            kC=kC*(sin(Phiz)/wc);
                        else
                            sinPhiz=sin(Phiz);
                            zC=[zC;sin(Phiz-wcTs)/sinPhiz];
                            kC=kC*(sinPhiz/sinwcTs);
                        end
                    end
                    if beta~=alpha
                        if Ts==0
                            zC=[zC;-wc/tan(beta)];
                            pC=[pC;-wc/tan(alpha)];
                            kC=kC*(sin(beta)/sin(alpha));
                        else
                            sinBeta=sin(beta);sinAlpha=sin(alpha);
                            zC=[zC;sin(beta-wcTs)/sinBeta];
                            pC=[pC;sin(alpha-wcTs)/sinAlpha];
                            kC=kC*(sinBeta/sinAlpha);
                        end
                    end
                end