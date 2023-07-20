function[WantBlockChoice,Ts,sps]=LeadLagFilterInit(block,T1,T2,V_Init,Ts)




    [WantBlockChoice,Ts,~,Init]=DetermineBlockChoice(block,Ts,0,0);



    nfilt=length(T1);
    nInput=length(V_Init);

    sps.A=[];
    sps.B=[];
    sps.C=[];
    sps.D=eye(nfilt,nfilt);
    sps.x0=0;

    if~Init
        return
    end

    BK=strrep(block,char(10),char(32));

    if length(T2)~=length(T1)
        error(message('physmod:powersys:common:InequalSize','Time constant T1(s)','Time constant T2(s)'));
    end

    if length(V_Init)~=length(T1)&&length(V_Init)~=1&&length(T1)~=1
        error(message('physmod:powersys:common:InequalSize','DC initial input and output','Time constant T1(s)'));
    end

    if any(T1<0)
        error(message('physmod:powersys:common:GreaterThanOrEqualTo',BK,'Time constant T1(s)','0'));
    end

    if any(T2<0)
        error(message('physmod:powersys:common:GreaterThanOrEqualTo',BK,'Time constant T2(s)','0'));
    end

    if any(T1>0&T2==0)
        error(message('physmod:powersys:library:LLFilterInvalidTimeConstants',BK));
    end



    Ac=[];
    Bc=[];
    Cc=[];
    Dc=[];

    nstates=0;
    for ifilt=1:nfilt
        numc=[T1(ifilt),1];
        denc=[T2(ifilt),1];
        [a,b,c,d]=tf2ss(numc,denc);
        if~isempty(a)
            nstates=nstates+1;
            Ac(nstates,nstates)=a;
            Bc(nstates,ifilt)=b;
            Cc(ifilt,nstates)=c;
            Dc(ifilt,ifilt)=d;
        else
            if nstates>0
                Bc(nstates,ifilt)=0;
            end
            if nstates>0
                Cc(ifilt,nstates)=0;
            end
            Dc(ifilt,ifilt)=d;
        end
    end
    sps.A=Ac;
    sps.B=Bc;
    sps.C=Cc;
    sps.D=Dc;

    if nstates==0
        sps.A=zeros(0,0);
        sps.B=zeros(0,nfilt);
        sps.C=zeros(nfilt,0);
        sps.D=eye(nfilt,nfilt);
    end


    if nstates>0
        switch WantBlockChoice
        case 'Discrete'

            invexp=inv(eye(nstates)-(Ts/2)*Ac);
            Ad=invexp*(eye(nstates)+(Ts/2)*Ac);
            Bd=invexp*Bc;
            Cd=Cc*invexp*Ts;
            Dd=Cc*invexp*Bc*(Ts/2)+Dc;








            sps.A=Ad;
            sps.B=Bd;
            sps.C=Cd;
            sps.D=Dd;
        end
    else



        sps.A=0;
        sps.B=0;
        sps.C=0;
    end


    if nstates>0
        for ifilt=1:nfilt
            if length(V_Init)==1
                ifilt2=1;
            else
                ifilt2=ifilt;
            end
            u(ifilt,1)=V_Init(ifilt2)*exp(1i*90*pi/180);
        end

        u0=imag(u);
        I=eye(size(Ac));
        sps.x0=inv(-Ac)*Bc*u0;




        if nfilt==1&&nInput>1
            for iInput=1:nInput
                u=V_Init(iInput)*exp(1i*90*pi/180);
                u0=imag(u);
                sps.x0(iInput)=inv(-Ac)*Bc*u0;
            end
        end

        switch WantBlockChoice

        case 'Discrete'
            sps.x0=(I-Ac*Ts/2)*sps.x0/Ts-Bc/2*u0;
        end
    else
        sps.x0=0;
    end