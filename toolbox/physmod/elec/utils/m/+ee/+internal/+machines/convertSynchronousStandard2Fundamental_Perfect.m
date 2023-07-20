function[f,DeltaLessThanZero]=convertSynchronousStandard2Fundamental_Perfect(s,wElectrical)%#codegen





    coder.allowpcode('plain');

    f=ee.internal.machines.createEmptySynchronousFundamental();
    DeltaLessThanZero=0;


    Xl=s.Xl;
    Xd=s.Xd;
    Xq=s.Xq;
    Xdd=s.Xdd;
    Xqd=s.Xqd;
    Xddd=s.Xddd;
    Xqdd=s.Xqdd;


    Tdd=s.Tdd;
    Td0d=s.Td0d;
    Tddd=s.Tddd;
    Td0dd=s.Td0dd;


    Tqd=s.Tqd;
    Tq0d=s.Tq0d;
    Tqdd=s.Tqdd;
    Tq0dd=s.Tq0dd;





    switch s.d_option
    case 1


        A0=Td0d+Td0dd;
        B0=Td0d*Td0dd;
        CoeA=Xd^2*Xddd;
        CoeB=-A0*Xd*Xdd*Xddd;
        CoeC=Xddd*(Xd*Xdd-Xd*Xddd+Xdd*Xddd)*B0;
        Delta=CoeB^2-4*CoeA*CoeC;
        if Delta<0
            DeltaLessThanZero=1;
        end
        Tdd=(-CoeB+sqrt(Delta))/(2*CoeA);
        Tddd=Xddd*B0/Xd/Tdd;
    case 2


        A0=Xd/Xdd*Tdd+(Xd/Xddd-Xd/Xdd+1)*Tddd;
        B0=Tdd*Tddd*Xd/Xddd;
        CoeA=1;
        CoeB=A0;
        CoeC=B0;
        Delta=CoeB^2-4*CoeA*CoeC;
        if Delta<0
            DeltaLessThanZero=1;
        end
        Td0d=-(-CoeB-sqrt(Delta))/(2*CoeA);
        Td0dd=-(-CoeB+sqrt(Delta))/(2*CoeA);
    otherwise

    end




    Xe=-Xl;
    A=Tdd+Tddd;
    B=Tdd*Tddd;
    A0=Td0d+Td0dd;
    B0=Td0d*Td0dd;

    Xde=Xd+Xe;
    Ae=(Xd*A+Xe*A0)/Xde;
    Be=(Xd*B+Xe*B0)/Xde;

    TE=sort(abs(roots([1,Ae,Be])));
    Tdedd=TE(1);
    Tded=TE(2);

    Xded=Xde/(1-(Tded-Td0d)*(Tded-Td0dd)/Tded/(Tded-Tdedd));
    Xdedd=Xddd+Xe;

    X12d=[Xded*Xdedd/(Xded-Xdedd),Xde*Xded/(Xde-Xded)];
    R12d=X12d./[Tdedd,Tded]/wElectrical;


    [R12d,Index]=sort(R12d);
    X12d=X12d(Index);
    R1d=R12d(2);
    Rfd=R12d(1);
    L1d=X12d(2);
    Lfd=X12d(1);
    Lad=Xd-Xl;
    Ll=Xl;




    switch s.num_q_dampers
    case 1
        switch s.q_option
        case 1
            Tq0dd=s.Tq0dd;
            Tqdd=Tq0dd*Xqdd/Xq;
        case 2
            Tqdd=s.Tqdd;
            Tq0dd=Tqdd*Xq/Xqdd;
        otherwise

        end
    case 2
        switch s.q_option
        case 1

            A0=Tq0d+Tq0dd;
            B0=Tq0d*Tq0dd;
            CoeA=Xq^2*Xqdd;
            CoeB=-A0*Xq*Xqd*Xqdd;
            CoeC=Xqdd*(Xq*Xqd-Xq*Xqdd+Xqd*Xqdd)*B0;
            Delta=CoeB^2-4*CoeA*CoeC;
            if Delta<0
                DeltaLessThanZero=1;
            end
            Tqd=(-CoeB+sqrt(Delta))/(2*CoeA);
            Tqdd=Xqdd*B0/Xq/Tqd;

        case 2

            A0=Xq/Xqd*Tqd+(Xq/Xqdd-Xq/Xqd+1)*Tqdd;
            B0=Tqd*Tqdd*Xq/Xqdd;
            CoeA=1;
            CoeB=A0;
            CoeC=B0;
            Delta=CoeB^2-4*CoeA*CoeC;
            if Delta<0
                DeltaLessThanZero=1;
            end
            Tq0d=-(-CoeB-sqrt(Delta))/(2*CoeA);
            Tq0dd=-(-CoeB+sqrt(Delta))/(2*CoeA);
        otherwise

        end
    otherwise
        pm_error('physmod:ee:library:IntegerOption',getString(message('physmod:ee:library:comments:utils:machines:convertSynchronousStandard2Fundamental_Perfect:error_SpecifyQaxisDamperNumber')),'1','2');
    end


    Xaq=Xq-Xl;
    Laq=Xaq;
    L2q=nan;
    R2q=nan;
    switch s.num_q_dampers
    case 1

        X1q=(Xaq*Tqdd-(Xaq*Xl/(Xaq+Xl))*Tq0dd)/(Tq0dd-Tqdd);
        R1q=(Xaq+X1q)/(Tq0dd*wElectrical);
        L1q=X1q;

    case 2


        Xe=-Xl;
        A=Tqd+Tqdd;
        B=Tqd*Tqdd;
        A0=Tq0d+Tq0dd;
        B0=Tq0d*Tq0dd;

        Xqe=Xq+Xe;
        Ae=(Xq*A+Xe*A0)/Xqe;
        Be=(Xq*B+Xe*B0)/Xqe;

        TE=sort(abs(roots([1,Ae,Be])));
        Tqedd=TE(1);
        Tqed=TE(2);

        Xqed=Xqe/(1-(Tqed-Tq0d)*(Tqed-Tq0dd)/Tqed/(Tqed-Tqedd));
        Xqedd=Xqdd+Xe;

        X12q=[Xqed*Xqedd/(Xqed-Xqedd),Xqe*Xqed/(Xqe-Xqed)];
        R12q=X12q./[Tqedd,Tqed]/wElectrical;


        [R12q,Index]=sort(R12q);
        X12q=X12q(Index);
        R1q=R12q(2);
        R2q=R12q(1);
        L1q=X12q(2);
        L2q=X12q(1);
    otherwise
    end


    f.Ll=Ll;
    f.Lad=Lad;
    f.Laq=Laq;
    f.Lfd=Lfd;
    f.Rfd=Rfd;
    f.L1d=L1d;
    f.R1d=R1d;
    f.L1q=L1q;
    f.R1q=R1q;
    f.L2q=L2q;
    f.R2q=R2q;


    f.Ra=s.Ra;
    f.L0=s.X0;
    f.num_q_dampers=s.num_q_dampers;
    f.axes_param=s.axes_param;
    f.saturation_option=s.saturation_option;
    f.saturation=s.saturation;


    f=ee.internal.machines.updateSynchronousFundamental(f);

end