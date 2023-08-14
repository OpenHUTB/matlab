function s=convertSynchronousFundamental2Standard_Perfect(f,wElectrical)%#codegen





    coder.allowpcode('plain');

    s=ee.internal.machines.createEmptySynchronousStandard();


    Lad=f.Lad;
    Laq=f.Laq;
    Ll=f.Ll;
    Lfd=f.Lfd;
    Rfd=f.Rfd;
    L1d=f.L1d;
    R1d=f.R1d;
    num_q_dampers=f.num_q_dampers;
    L1q=f.L1q;
    R1q=f.R1q;
    L2q=f.L2q;
    R2q=f.R2q;

    if isnan(f.Ld)&&isnan(f.Lq)
        f=ee.internal.machines.updateSynchronousFundamental(f);
    end
    Ld=f.Ld;
    Lq=f.Lq;
    Xd=Ld;
    Xq=Lq;





    T01=(L1d+Lad)/R1d/wElectrical;
    T02=(Lfd+Lad)/Rfd/wElectrical;
    k12=det([Lad+L1d,Lad;Lad,Lad+Lfd])/(Lad+L1d)/(Lad+Lfd);
    A0=T01+T02;
    B0=k12*T01*T02;
    sol_Td0=sort(abs(roots([1,A0,B0])));
    Td0d=sol_Td0(2);
    Td0dd=sol_Td0(1);


    Lds=Lad*Ll/(Lad+Ll);
    T1=(L1d+Lds)/R1d/wElectrical;
    T2=(Lfd+Lds)/Rfd/wElectrical;
    k12=det([Lds+L1d,Lds;Lds,Lds+Lfd])/(Lds+L1d)/(Lds+Lfd);
    A=T1+T2;
    B=k12*T1*T2;
    sol_Td=sort(abs(roots([1,A,B])));
    Tdd=sol_Td(2);
    Tddd=sol_Td(1);


    Xdd=Xd/(1-(Tdd-Td0d)*(Tdd-Td0dd)/(Tdd)/(Tdd-Tddd));
    Xddd=Xd*Tdd*Tddd/Td0d/Td0dd;


    switch num_q_dampers
    case 1


        T01=(L1q+Laq)/R1q/wElectrical;
        Tq0dd=T01;

        Lqs=Laq*Ll/(Laq+Ll);
        T1=(L1q+Lqs)/R1q/wElectrical;
        Tqdd=T1;


        Xqdd=Xq*Tqdd/Tq0dd;
    case 2


        T01=(L1q+Laq)/R1q/wElectrical;
        T02=(L2q+Laq)/R2q/wElectrical;
        k12=det([Laq+L1q,Laq;Laq,Laq+L2q])/(Laq+L1q)/(Laq+L2q);
        A0=T01+T02;
        B0=k12*T01*T02;
        sol_Tq0=sort(abs(roots([1,A0,B0])));
        Tq0d=sol_Tq0(2);
        Tq0dd=sol_Tq0(1);


        Lqs=Laq*Ll/(Laq+Ll);
        T1=(L1q+Lqs)/R1q/wElectrical;
        T2=(L2q+Lqs)/R2q/wElectrical;
        k12=det([Lqs+L1q,Lqs;Lqs,Lqs+L2q])/(Lqs+L1q)/(Lqs+L2q);
        A=T1+T2;
        B=k12*T1*T2;
        sol_Tq=sort(abs(roots([1,A,B])));
        Tqd=sol_Tq(2);
        Tqdd=sol_Tq(1);


        Xqd=Xq/(1-(Tqd-Tq0d)*(Tqd-Tq0dd)/(Tqd)/(Tqd-Tqdd));
        Xqdd=Xq*Tqd*Tqdd/Tq0d/Tq0dd;
    otherwise
        pm_error('physmod:ee:library:IntegerOption',getString(message('physmod:ee:library:comments:utils:machines:convertSynchronousFundamental2Standard_Perfect:error_NumberOfQaxisDamperCircuits')),'1','2');
    end



    s.Ra=f.Ra;
    s.Xl=f.Ll;
    s.X0=f.L0;
    s.Xd=Ld;
    s.Xq=Lq;
    s.saturation_option=f.saturation_option;
    s.axes_param=f.axes_param;
    s.saturation=f.saturation;


    s.Td0d=Td0d;
    s.Tdd=Tdd;
    s.Td0dd=Td0dd;
    s.Tddd=Tddd;
    s.Xdd=Xdd;
    s.Xddd=Xddd;


    s.num_q_dampers=num_q_dampers;
    switch num_q_dampers
    case 1
        s.Tq0dd=Tq0dd;
        s.Tqdd=Tqdd;
        s.Xqdd=Xqdd;
    case 2
        s.Tq0d=Tq0d;
        s.Tqd=Tqd;
        s.Tq0dd=Tq0dd;
        s.Tqdd=Tqdd;
        s.Xqd=Xqd;
        s.Xqdd=Xqdd;
    otherwise
        pm_error('physmod:ee:library:IntegerOption',getString(message('physmod:ee:library:comments:utils:machines:convertSynchronousFundamental2Standard_Perfect:error_NumberOfQaxisDamperCircuits')),'1','2');
    end


    s=ee.internal.machines.updateSynchronousStandard(s);

end