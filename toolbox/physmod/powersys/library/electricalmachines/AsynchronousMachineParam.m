function SM=AsynchronousMachineParam(MechanicalLoad,RotorType,ReferenceFrame,NominalParameters,VoltageRatio,Stator,Rotor,Cage1,Cage2,Lm,Mechanical,PolePairs,InitialConditions,Units,SimulateSaturation,Saturation,IterativeModel,LoadFlowFrequency)










    Pn=NominalParameters(1);
    Vn=NominalParameters(2);
    MachineFrequency=NominalParameters(3);


    SM.j=1i;
    SM.H=Mechanical(1);
    SM.F=Mechanical(2);

    switch MechanicalLoad
    case 'Torque Tm'
        if size(Mechanical,2)==3
            SM.p=Mechanical(3);
        else
            SM.p=PolePairs;
        end
    case 'Speed w'
        SM.p=PolePairs;
    case 'Mechanical rotational port'
        if size(Mechanical,2)==3
            SM.p=Mechanical(3);
        else
            SM.p=PolePairs;
        end
    end

    SM.Pn=Pn;
    SM.Vb=sqrt(2/3)*Vn;
    SM.ib=sqrt(2/3)*Pn/Vn;
    SM.web=2*pi*MachineFrequency;
    wmb=SM.web/SM.p;
    Tb=Pn/wmb;


    SM.Rs=Stator(1);
    SM.Lls=Stator(2);


    SM.Rr=Rotor(1);
    SM.Llr=Rotor(2);


    SM.Rr1=Cage1(1);
    SM.Llr1=Cage1(2);
    SM.Rr2=Cage2(1);
    SM.Llr2=Cage2(2);

    SM.VoltageRatio=VoltageRatio;

    SM.ensat=SimulateSaturation;


    if SimulateSaturation

        isat=Saturation(1,:);
        SM.isat=isat;

        vsat=Saturation(2,:);
        SM.vsat=vsat;
        SM.Lm=vsat(1)/isat(1)-SM.Lls;
    else
        SM.Lm=Lm;
    end


    switch RotorType
    case 'Double squirrel-cage'
        SM.Laq=1/(1/SM.Lm+1/SM.Lls+1/SM.Llr1+1/SM.Llr2);
    otherwise
        SM.Laq=1/(1/SM.Lm+1/SM.Lls+1/SM.Llr);
    end
    SM.Lad=SM.Laq;


    slip=InitialConditions(1);



    if~exist('LoadFlowFrequency','var')
        LoadFlowFrequency=MachineFrequency;
    else
        if isnan(LoadFlowFrequency)
            LoadFlowFrequency=MachineFrequency;
        end
        if LoadFlowFrequency==0
            LoadFlowFrequency=MachineFrequency;
        end
    end

    SM.wmo=(1-slip)*LoadFlowFrequency/MachineFrequency;


    SM.tho=InitialConditions(2)*pi/180;




    isa=InitialConditions(3)*exp(1i*InitialConditions(6)*pi/180);
    isb=InitialConditions(4)*exp(1i*InitialConditions(7)*pi/180);
    isc=InitialConditions(5)*exp(1i*InitialConditions(8)*pi/180);


    isao=imag(isa);
    isbo=imag(isb);
    isco=imag(isc);


    isabc=[isao,isbo,isco]';dpt=2*pi/3;
    isqo=2/3*[cos(SM.tho),cos(SM.tho-dpt),cos(SM.tho+dpt)]*isabc;
    isdo=2/3*[sin(SM.tho),sin(SM.tho-dpt),sin(SM.tho+dpt)]*isabc;


    a=exp(-1i*2*pi/3);


    switch RotorType

    case 'Double squirrel-cage'


        Z1=SM.Rr1/slip+1i*SM.Llr1;
        Z2=SM.Rr2/slip+1i*SM.Llr2;
        Zm=1i*SM.Lm;
        Zparallel=1/(1/Zm+1/Z1+1/Z2);
        Vm=isa*Zparallel;
        ir1=-Vm/Z1;
        ir2=-Vm/Z2;


        irao1=imag(ir1);
        irbo1=imag(ir1*a);
        irco1=imag(ir1*a^2);
        irao2=imag(ir2);
        irbo2=imag(ir2*a);
        irco2=imag(ir2*a^2);


        irabc1=[irao1,irbo1,irco1]';
        irqo1=2/3*[1,-0.5,-0.5]*irabc1;
        irdo1=2/3*[0,-sqrt(3)/2,sqrt(3)/2]*irabc1;

        irabc2=[irao2,irbo2,irco2]';
        irqo2=2/3*[1,-0.5,-0.5]*irabc2;
        irdo2=2/3*[0,-sqrt(3)/2,sqrt(3)/2]*irabc2;


        SM.phisqo=(SM.Lls+SM.Lm)*isqo+SM.Lm*(irqo1+irqo2);
        SM.phisdo=(SM.Lls+SM.Lm)*isdo+SM.Lm*(irdo1+irdo2);
        SM.phirqo1=(SM.Llr1+SM.Lm)*irqo1+SM.Lm*(isqo+irqo2);
        SM.phirdo1=(SM.Llr1+SM.Lm)*irdo1+SM.Lm*(isdo+irdo2);
        SM.phirqo2=(SM.Llr2+SM.Lm)*irqo2+SM.Lm*(isqo+irqo1);
        SM.phirdo2=(SM.Llr2+SM.Lm)*irdo2+SM.Lm*(isdo+irdo1);

    otherwise


        switch length(InitialConditions)
        case{8,9}

            A=-1i*SM.Lm/(SM.Rr/slip+1i*(SM.Llr+SM.Lm));

            irao=imag(A*isa);
            irbo=imag(A*isa*a);
            irco=imag(A*isa*a^2);

        case{14,15}

            irao=imag(InitialConditions(9)*exp(1i*InitialConditions(12)*pi/180));
            irbo=imag(InitialConditions(10)*exp(1i*InitialConditions(13)*pi/180));
            irco=imag(InitialConditions(11)*exp(1i*InitialConditions(14)*pi/180));
        end


        irabc=[irao,irbo,irco]';
        irqo=2/3*[1,-0.5,-0.5]*irabc;
        irdo=2/3*[0,-sqrt(3)/2,sqrt(3)/2]*irabc;


        SM.phisqo=(SM.Lls+SM.Lm)*isqo+SM.Lm*irqo;
        SM.phisdo=(SM.Lls+SM.Lm)*isdo+SM.Lm*irdo;
        SM.phirqo=(SM.Llr+SM.Lm)*irqo+SM.Lm*isqo;
        SM.phirdo=(SM.Llr+SM.Lm)*irdo+SM.Lm*isdo;
    end

    switch Units

    case 'SI'

        SM.ib2=SM.ib;
        SM.Vb2=SM.Vb;
        SM.phib2=Vn*sqrt(2/3)/SM.web;
        SM.Nb2=wmb;
        SM.Tb2=Tb;

    case 'pu'

        SM.ib2=1;
        SM.Vb2=1;
        SM.phib2=1;
        SM.Nb2=1;
        SM.Tb2=1;

    end

    SM.ctrl=ReferenceFrame;
    SM.one_third=1/3;
    SM.sqrt3_3=sqrt(3)/3;
    SM.sqrt3=sqrt(3);

    switch RotorType
    case 'Wound'
        SM.selWidth=6;
        SM.elements1=3:6;
        SM.elements2=1:4;
    otherwise
        SM.selWidth=4;
        SM.elements1=1:4;
        SM.elements2=3:4;
    end



    switch RotorType
    case 'Double squirrel-cage'
        SM.R=[SM.Rs,0,0,0,0,0
        0,SM.Rs,0,0,0,0
        0,0,SM.Rr1,0,0,0
        0,0,0,SM.Rr1,0,0
        0,0,0,0,SM.Rr2,0
        0,0,0,0,0,SM.Rr2];

        Ls=SM.Lls+SM.Lm;
        Lr1=SM.Llr1+SM.Lm;
        Lr2=SM.Llr2+SM.Lm;

        L=[Ls,0,SM.Lm,0,SM.Lm,0
        0,Ls,0,SM.Lm,0,SM.Lm
        SM.Lm,0,Lr1,0,SM.Lm,0
        0,SM.Lm,0,Lr1,0,SM.Lm
        SM.Lm,0,SM.Lm,0,Lr2,0
        0,SM.Lm,0,SM.Lm,0,Lr2];

        SM.Linv=inv(L);
        SM.RLinv=SM.R*SM.Linv;

        SM.Ll=[SM.Lls,0,0,0,0,0
        0,SM.Lls,0,0,0,0
        0,0,SM.Llr1,0,0,0
        0,0,0,SM.Llr1,0,0
        0,0,0,0,SM.Llr2,0
        0,0,0,0,0,SM.Llr2];


        SM.phiqd0=[SM.phisqo,SM.phisdo,SM.phirqo1,SM.phirdo1,SM.phirqo2,SM.phirdo2]';


        SM.iqd0=SM.Linv*SM.phiqd0;

        switch IterativeModel
        case 'Trapezoidal iterative (alg. loop)'
            SM.Iterative=6;
        case{'Trapezoidal non iterative','Forward Euler'}
            SM.Iterative=0;
        end


    otherwise

        SM.R=[SM.Rs,0,0,0
        0,SM.Rs,0,0
        0,0,SM.Rr,0
        0,0,0,SM.Rr];

        Ls=SM.Lls+SM.Lm;
        Lr=SM.Llr+SM.Lm;

        L=[Ls,0,SM.Lm,0
        0,Ls,0,SM.Lm
        SM.Lm,0,Lr,0
        0,SM.Lm,0,Lr];

        SM.Linv=inv(L);
        SM.RLinv=SM.R*SM.Linv;

        SM.Ll=[SM.Lls,0,0,0
        0,SM.Lls,0,0
        0,0,SM.Llr,0
        0,0,0,SM.Llr];


        SM.phiqd0=[SM.phisqo,SM.phisdo,SM.phirqo,SM.phirdo]';


        SM.iqd0=SM.Linv*SM.phiqd0;

        switch IterativeModel
        case 'Trapezoidal iterative (alg. loop)'
            SM.Iterative=4;
        case 'Trapezoidal non iterative'
            SM.Iterative=0;
        end
    end



    SM.Teo=SM.phisdo*isqo-SM.phisqo*isdo;

    if SimulateSaturation

        if SM.vsat(1)==0&&SM.isat(1)==0
            n1=2;
        else
            n1=1;
        end
        Lmsat=SM.vsat(n1:end)./SM.isat(n1:end);
        Lmsat=Lmsat-SM.Lls;
        Phisat=SM.vsat(n1:end)-SM.Lls*SM.isat(n1:end);


        if n1==1
            SM.Lsat=[Lmsat(1),Lmsat];
            SM.Phisat=[0,Phisat];
        else
            SM.Lsat=Lmsat;
            SM.Phisat=Phisat;
        end



        for i=2:length(SM.vsat)

            slope=(Phisat(i)-Phisat(i-1))/(SM.isat(i)-SM.isat(i-1));


            Imax=(SM.vsat(i)-SM.vsat(i-1)+SM.Lls*SM.isat(i-1))/SM.Lls;

            if slope<0


                SM.Phisat=[0,1];
                SM.Lsat=[0,1];

                block=gcb;


                block=strrep(block,newline,char(32));
                error(message('physmod:powersys:library:ASMSaturaionFluxvsCurrent','[i(Arms);v(VLL rms)]',...
                block,num2str(i),num2str(Imax),num2str(Imax*SM.ib2/sqrt(2))));
            end
        end

    else

        SM.Phisat=[0,1];
        SM.Lsat=[0,1];

    end