function DATA=LineParameter(DATA)


























































































    w=2*pi*DATA.frequency;
    k_eps0=17.975109e6;




    Nwires=0;
    for no_bundle=1:DATA.Geometry.NPhaseBundle+DATA.Geometry.NGroundBundle
        CondType=DATA.Geometry.ConductorType(no_bundle);
        DeltaAngle=360/DATA.Conductors.Nconductors(CondType)*pi/180;
        AngleCond=DATA.Conductors.AngleConductor1(CondType)*pi/180;
        for no_wire=1:DATA.Conductors.Nconductors(CondType)
            Nwires=Nwires+1;
            X(Nwires)=DATA.Geometry.X(no_bundle)+DATA.Conductors.BundleDiameter(CondType)/2*cos(AngleCond);
            Y(Nwires)=(2*DATA.Geometry.Ymin(no_bundle)+DATA.Geometry.Ytower(no_bundle))/3+DATA.Conductors.BundleDiameter(CondType)/2*sin(AngleCond);
            AngleCond=AngleCond+DeltaAngle;
            ConductorType(Nwires)=DATA.Geometry.ConductorType(no_bundle);
            ConductorPhaseNumber(Nwires)=DATA.Geometry.PhaseNumber(no_bundle);
        end
    end


    [ConductorPhaseNumber,n]=sort(ConductorPhaseNumber);
    ConductorType=ConductorType(n);
    X=X(n);
    Y=Y(n);

    n=find(ConductorPhaseNumber==0);
    NGroundWires=length(n);
    n=[NGroundWires+1:Nwires,1:NGroundWires];
    ConductorPhaseNumber=ConductorPhaseNumber(n);
    ConductorType=ConductorType(n);
    X=X(n);
    Y=Y(n);



    Zseries=zeros(Nwires,Nwires);
    Pshunt=zeros(Nwires,Nwires);
    d=zeros(Nwires,Nwires);
    D=zeros(Nwires,Nwires);
    for i=1:Nwires
        Radius=DATA.Conductors.Diameter(ConductorType(i))/2;
        InternalRadius=Radius*(1-2*DATA.Conductors.ThickRatio(ConductorType(i)));
        r=DATA.Conductors.Res(ConductorType(i));
        mur=DATA.Conductors.Mur(ConductorType(i));
        [Rint,Xint]=skin(DATA.frequency,r/1000,mur,Radius,InternalRadius,DATA.Conductors.skinEffect);
        r=Rint*1000;
        for k=i:Nwires
            if i==k
                if DATA.evaluatedFromGMR
                    Zseries(i,i)=r+1i*w*2e-7*log(2*Y(i)/DATA.Conductors.GMR(ConductorType(i)))*1000;
                else
                    Zseries(i,i)=r+1i*(w*2e-7*log(2*Y(i)/Radius)+Xint)*1000;
                end
                if DATA.groundResistivity>0
                    [DR,DX]=carson(2*Y(i),0,DATA.frequency,DATA.groundResistivity);
                    Zseries(i,i)=Zseries(i,i)+DR+1i*DX;
                end
                Pshunt(i,i)=k_eps0*log(2*Y(i)/Radius);
            else

                d(i,k)=sqrt((X(i)-X(k))^2+(Y(i)-Y(k))^2);

                D(i,k)=sqrt((X(i)-X(k))^2+(Y(i)+Y(k))^2);
                Zseries(i,k)=1i*w*2e-7*log(D(i,k)/d(i,k))*1000;
                if DATA.groundResistivity>0
                    phi=acos((Y(i)+Y(k))/D(i,k));
                    [DR,DX]=carson(D(i,k),phi,DATA.frequency,DATA.groundResistivity);
                    Zseries(i,k)=Zseries(i,k)+DR+1i*DX;
                end
                Zseries(k,i)=Zseries(i,k);
                Pshunt(i,k)=k_eps0*log(D(i,k)/d(i,k));
                Pshunt(k,i)=Pshunt(i,k);
            end
        end

    end

    Yshunt=1i*w*inv(Pshunt);



    Yseries=inv(Zseries);
    Nphases=max(ConductorPhaseNumber);
    index_red=[];
    i=1;

    for no_phase=1:Nphases
        n=find(ConductorPhaseNumber==no_phase);
        if length(n)>1
            Yseries(i,:)=sum(Yseries(n,:),1);
            Yshunt(i,:)=sum(Yshunt(n,:),1);
        end
        index_red=[index_red,i];
        i=i+length(n);
    end

    i=1;
    for no_phase=1:Nphases
        n=find(ConductorPhaseNumber==no_phase);
        if length(n)>1
            Yseries(:,i)=sum(Yseries(:,n),2);
            Yshunt(:,i)=sum(Yshunt(:,n),2);
        end
        i=i+length(n);
    end

    Zred=inv(Yseries(index_red,index_red));
    Yred=Yshunt(index_red,index_red);


    Zred=(Zred+Zred.')/2;
    Yred=(Yred+Yred.')/2;

    DATA.Rred=real(Zred);
    DATA.Lred=imag(Zred)/w;
    DATA.Cred=imag(Yred)/w;


    a=exp(1i*2*pi/3);T=1/3*[1,1,1;1,a,a^2;1,a^2,a];
    if Nphases==3
        Zseq=T*Zred/(T);
        Yseq=T*Yred/(T);
        DATA.R10=real([Zseq(2,2),Zseq(1,1)]);
        DATA.L10=imag([Zseq(2,2),Zseq(1,1)])/w;
        DATA.C10=imag([Yseq(2,2),Yseq(1,1)])/w;
    elseif Nphases==6
        T2=[T,zeros(3,3);zeros(3,3),T];
        Zseq=T2*Zred/(T2);
        Yseq=T2*Yred/(T2);
        DATA.R10=real([Zseq(2,2),Zseq(1,1),Zseq(1,4),Zseq(5,5),Zseq(4,4)]);
        DATA.L10=imag([Zseq(2,2),Zseq(1,1),Zseq(1,4),Zseq(5,5),Zseq(4,4)])/w;
        DATA.C10=imag([Yseq(2,2),Yseq(1,1),Yseq(1,4),Yseq(5,5),Yseq(4,4)])/w;
    else
        DATA.R10=[];
        DATA.L10=[];
        DATA.C10=[];
    end

    function[DR,DX]=carson(D,phi,f,rho)























        w=2*pi*f;

        rho_cgs=rho*1e11;
        D_cgs=D*100;
        a=2*pi*sqrt(2)*D_cgs*sqrt(f/rho_cgs);

        if a<=0.25
            P=pi/8-1/3/sqrt(2)*a*cos(phi)+a^2/16*cos(2*phi)*(0.6728+log(2/a))+a^2/16*phi*sin(2*phi);
            Q=-0.0386+1/2*log(2/a)+1/3/sqrt(2)*a*cos(phi);

        elseif a>0.25&&a<5
            s2=0;s2p=0;
            s4=0;s4p=0;
            sig1=0;sig3=0;
            sig2=0;sig4=0;
            n=2;
            signe=+1;
            ksig1=1/3;
            ksig3=1/3^2/5;
            ksig2=1+1/2;
            ksig4=1+1/2+1/3;
            nterm=0;
            for i=2:4:18
                nterm=nterm+1;



                k2=1/(factorial(n-1)*factorial(n));
                s2=s2+signe*k2*(a/2)^i*cos(i*phi);
                s2p=s2p+signe*k2*(a/2)^i*sin(i*phi);

                k4=1/(factorial(n)*factorial(n+1));
                s4=s4+signe*k4*(a/2)^(i+2)*cos((i+2)*phi);
                s4p=s4p+signe*k4*(a/2)^(i+2)*sin((i+2)*phi);

                sig1=sig1+signe*ksig1*a^(i-1)*cos((i-1)*phi);
                sig3=sig3+signe*ksig3*a^(i+1)*cos((i+1)*phi);

                sig2=sig2+signe*(ksig2-1/(2*n))*k2*(a/2)^i*cos(i*phi);
                sig4=sig4+signe*(ksig4-1/(2*(n+1)))*k4*(a/2)^(i+2)*cos((i+2)*phi);

                ksig1=ksig1*1/((i+1)*(i+3)^2*(i+5));
                ksig3=ksig3*1/((i+3)*(i+5)^2*(i+7));
                n=n+2;
                ksig2=ksig2+1/(n-1)+1/n;
                ksig4=ksig4+1/(n)+1/(n+1);

                signe=-signe;
            end

            gamma=1.7811;
            P=pi/8*(1-s4)+1/2*log(2/(gamma*a))*s2+1/2*phi*s2p...
            -1/sqrt(2)*sig1+1/2*sig2+1/sqrt(2)*sig3;

            Q=1/4+1/2*log(2/(gamma*a))*(1-s4)-1/2*phi*s4p...
            +1/sqrt(2)*sig1-pi/8*s2+1/sqrt(2)*sig3-1/2*sig4;

        else
            P=cos(phi)/a-sqrt(2)*cos(2*phi)/a^2+cos(3*phi)/a^3+3*cos(5*phi)/a^5;
            Q=cos(phi)/a-cos(3*phi)/a^3+3*cos(5*phi)/a^5;
            P=P/sqrt(2);
            Q=Q/sqrt(2);
        end


        DR=4*w*P*1e-4;
        DX=4*w*Q*1e-4;