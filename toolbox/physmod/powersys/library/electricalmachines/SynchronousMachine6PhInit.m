function[Ts,SM6,WantBlockChoice,X,Y]=SynchronousMachine6PhInit(block,MechanicalLoad,...
    NominalParameters,Stator,Field,Dampers,Inertia,FrictionFactor,PolePairs,InitialConditions,TsBlock,Units)







    PowerguiInfo=getPowerguiInfo(bdroot(block),block);

    Ts=PowerguiInfo.Ts;
    if TsBlock~=-1
        Ts=TsBlock;
        PowerguiInfo.Discrete=1;
    end


    if PowerguiInfo.Discrete
        WantBlockChoice{1}='Discrete';
        WantBlockChoice{2}='Discrete';
    else
        WantBlockChoice{1}='Continuous';
        WantBlockChoice{2}='Continuous';
    end
    switch MechanicalLoad
    case 'Mechanical power Pm'
        WantBlockChoice{2}=[WantBlockChoice{2},' Pm input'];
    case 'Speed w'
        WantBlockChoice{2}=[WantBlockChoice{2},' w input'];
    end


    X.p1=-60;
    Y.p1=-10;
    X.p2=60;
    Y.p2=80;
    X.p3=[0,9,18,24,29,30,29,24,18,9,0,-9,-18,-24,-29,-30,-29,-24,-18,-9,0]*1.2;
    Y.p3=[30,29,24,18,9,0,-9,-18,-24,-29,-30,-29,-24,-18,-9,0,9,18,24,29,30]*1.1+15+15;
    X.p4=[25,48];
    Y.p4=[56,56];
    X.p5=[32,48];
    Y.p5=[56,56]-11;
    X.p6=[35,48];
    Y.p6=[56,56]-11*2;
    X.p7=[35,48];
    Y.p7=[56,56]-11*3;
    X.p8=[30,48];
    Y.p8=[56,56]-11*4;
    X.p9=[21,48];
    Y.p9=[56,56]-11*5;
    X.p10=[0,-9,-18,-24,-16,-16,-24,-18,-9,0,9,18,24,16,16,24,18,9,0];
    Y.p10=[-30,-29,-24,-18,-18,18,18,24,29,30,29,24,18,18,-18,-18,-24,-29,-30]*0.94+15+15;
    X.p11=[0,0,40];
    Y.p11=[65,70,70];
    X.p12=[-42,-35];
    Y.p12=[50,40];


    switch Units
    case{'SI fundamental parameters'}
        [NominalParameters,Stator,Field,Dampers,Inertia,FrictionFactor,InitialConditions]=...
        SynchronousMachine6PhConvert(NominalParameters,Stator,Field,Dampers,Inertia,FrictionFactor,PolePairs,InitialConditions);
    end


    SM6=SynchronousMachine6PhParam(NominalParameters,Stator,Field,Dampers,Inertia,FrictionFactor,PolePairs,InitialConditions,Units);


    [WantBlockChoice,SM6]=SPSrl('userblock','SynchronousMachine6Ph',bdroot(block),WantBlockChoice,SM6);
    power_initmask();


    MV=get_param(block,'MaskVisibilities');
    switch MechanicalLoad
    case 'Mechanical power Pm'
        SM6.PortLabel='Pm';
        MV{6}='on';
        MV{7}='on';
    otherwise
        SM6.PortLabel='w';
        MV{6}='off';
        MV{7}='off';
    end
    set_param(block,'MaskVisibilities',MV);

    function[NominalParameters,Stator,Field,Dampers,Inertia,FrictionFactor,InitialConditions]=...
        SynchronousMachine6PhConvert(NominalParameters,Stator,Field,Dampers,Inertia,FrictionFactor,PolePairs,InitialConditions)





        Pn=NominalParameters(1);
        Vn=NominalParameters(2);
        fn=NominalParameters(3);

        wen=2*pi*fn;

        wmn=wen/PolePairs;

        Vb=sqrt(2/3)*Vn;

        Ib=sqrt(2/3)*Pn/Vn;


        Zb=Vb/(Ib);

        Lb=Zb/wen;

        iopu=InitialConditions(3:8)/Ib;

        Rs=Stator(1)/Zb;
        Ll=Stator(2)/Lb;
        Lmd=Stator(3)/Lb;
        Lmq=Stator(4)/Lb;

        Rf=Field(1)/Zb;
        Llfd=Field(2)/Lb;

        Rkd=Dampers(1)/Zb;
        Llkd=Dampers(2)/Lb;
        Rkq1=Dampers(3)/Zb;
        Llkq1=Dampers(4)/Lb;

        Inertia=Inertia*wmn^2/2/Pn;
        FrictionFactor=FrictionFactor*wmn^2/Pn;


        Vfns=Rf*Vb/Lmd;


        Vfopu=InitialConditions(15)/Vfns;

        InitialConditions=[InitialConditions(1:2),iopu,InitialConditions(9:14),Vfopu];


        Stator=[Rs,Ll,Lmd,Lmq];
        Field=[Rf,Llfd];
        Dampers=[Rkd,Llkd,Rkq1,Llkq1];


        function SM6=SynchronousMachine6PhParam(NominalParameters,Stator,Field,Dampers,...
            Inertia,FrictionFactor,PolePairs,InitialConditions,Units)






















            Pn=NominalParameters(1);
            Vn=NominalParameters(2);
            MachineFrequency=NominalParameters(3);
            SM6.j=1i;
            SM6.Rs=Stator(1);
            SM6.Ll=Stator(2);
            SM6.Lmd=Stator(3);
            SM6.Lmq=Stator(4);
            SM6.Rf=Field(1);
            SM6.Llfd=Field(2);
            SM6.Rkd=Dampers(1);
            SM6.Rkq1=Dampers(3);
            SM6.Llkd=Dampers(2);
            SM6.Llkq1=Dampers(4);
            SM6.H=Inertia;
            SM6.F=FrictionFactor;
            SM6.p=PolePairs;

            SM6.dwo=InitialConditions(1)/100;
            SM6.tho=InitialConditions(2)*pi/180;
            iao=InitialConditions(3);
            ibo=InitialConditions(4);
            ico=InitialConditions(5);
            ixo=InitialConditions(6);
            iyo=InitialConditions(7);
            izo=InitialConditions(8);
            phao=InitialConditions(9);
            phbo=InitialConditions(10);
            phco=InitialConditions(11);
            phxo=InitialConditions(12);
            phyo=InitialConditions(13);
            phzo=InitialConditions(14);


            invLad=1/SM6.Lmd+2/SM6.Ll+1/SM6.Llkd+1/SM6.Llfd;
            SM6.Lad=1/invLad;
            invLaq=1/SM6.Lmq+2/SM6.Ll+1/SM6.Llkq1;
            SM6.Laq=1/invLaq;


            SM6.Disp=pi/6;


            SM6.Vb=sqrt(2/3)*Vn;
            SM6.ib=sqrt(2/3)*Pn/Vn;


            switch Units

            case{'per unit fundamental parameters'}

                Vfopu=InitialConditions(15);
                SM6.Ib2=2;
                SM6.Vb2=1;
                SM6.Pb=1;
                SM6.Nb=1;
                SM6.phib=1;

            otherwise



                SM6.Pb=Pn;
                SM6.Nb=2*pi*MachineFrequency/SM6.p;
                SM6.phib=SM6.Vb/(MachineFrequency*2*pi);
                SM6.Ib2=SM6.ib;
                SM6.Vb2=SM6.Vb;

            end



            switch Units

            case{'per unit fundamental parameters'}

                SM6.Vfnp=SM6.Rf/SM6.Lmd;


                Vfo=Vfopu*SM6.Vfnp;
                SM6.N2=SM6.Lmd;

            otherwise
                SM6.Vfnp=1/SM6.Vb;
                SM6.N2=SM6.ib;
                Vfo=InitialConditions(15)*SM6.Rf/SM6.Lmd;
            end


            [~,iao]=pol2cart(phao*pi/180,iao);
            [~,ibo]=pol2cart(phbo*pi/180,ibo);
            [~,ico]=pol2cart(phco*pi/180,ico);

            [~,ixo]=pol2cart(phxo*pi/180,ixo);
            [~,iyo]=pol2cart(phyo*pi/180,iyo);
            [~,izo]=pol2cart(phzo*pi/180,izo);


            ifdo=Vfo/SM6.Rf;
            is1=[iao,ibo,ico]';
            is2=[ixo,iyo,izo]';dpt=2*pi/3;

            iqo1=2/3*[cos(SM6.tho),cos(SM6.tho-dpt),cos(SM6.tho+dpt)]*is1;
            ido1=2/3*[sin(SM6.tho),sin(SM6.tho-dpt),sin(SM6.tho+dpt)]*is1;

            iqo2=2/3*[cos(SM6.tho-SM6.Disp),cos(SM6.tho-dpt-SM6.Disp),cos(SM6.tho+dpt-SM6.Disp)]*is2;
            ido2=2/3*[sin(SM6.tho-SM6.Disp),sin(SM6.tho-dpt-SM6.Disp),sin(SM6.tho+dpt-SM6.Disp)]*is2;




            SM6.phiqo1=-SM6.Ll*iqo1-SM6.Lmq*(iqo1+iqo2);
            SM6.phiqo2=-SM6.Ll*iqo2-SM6.Lmq*(iqo1+iqo2);
            SM6.phikq1o=-SM6.Lmq*(iqo1+iqo2);
            SM6.phido1=-SM6.Ll*ido1+SM6.Lmd*(-ido1-ido2+ifdo);
            SM6.phido2=-SM6.Ll*ido2+SM6.Lmd*(-ido1-ido2+ifdo);
            SM6.phikdo=(SM6.Lmd*(-ido1-ido2+ifdo));
            SM6.phifdo=(SM6.Llfd*ifdo+SM6.Lmd*(-ido1-ido2+ifdo));



            SM6.N=SM6.Vfnp;
            switch Units
            case 'SI fundamental parameters'
                SM6.Gain1=SM6.Pb;
            otherwise
                SM6.Gain1=1;
            end

            SM6.web=NominalParameters(3)*2*pi;
            SM6.one_third=1/3;
            SM6.sqrt3=sqrt(3);
