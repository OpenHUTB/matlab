function SM=SynchronousMachineParam(MechanicalLoad,NominalParameters,Stator,Field,Dampers,...
    Mechanical,PolePairs,InitialConditions,SetSaturation,Saturation,DisplayVfd,Units,excAxis,RotorType,IterativeModel,LoadFlowFrequency,LC)







    if nargin==9
        excAxis=1;
    end


    Pn=NominalParameters(1);
    Vn=NominalParameters(2);
    MachineFrequency=NominalParameters(3);
    SM.j=1i;
    SM.Rs=Stator(1);
    SM.Ll=Stator(2);
    SM.Lmd=Stator(3);
    SM.Lmq=Stator(4);
    SM.Rf=Field(1);
    SM.Llfd=Field(2);
    SM.Rkd=Dampers(1);
    SM.Rkq1=Dampers(3);
    SM.Rkq2=Dampers(5);
    SM.Llkd=Dampers(2);
    SM.Llkq1=Dampers(4);
    SM.Llkq2=Dampers(6);
    SM.H=Mechanical(1);
    SM.F=Mechanical(2);
    SM.LC=LC;

    if~exist('LoadFlowFrequency','var')
        SM.LoadFlowFrequency=MachineFrequency;
    else
        if isnan(LoadFlowFrequency)
            SM.LoadFlowFrequency=MachineFrequency;
        else
            SM.LoadFlowFrequency=LoadFlowFrequency;
        end
    end


    switch MechanicalLoad
    case 'Mechanical power Pm'
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

    SM.dwo=InitialConditions(1)/100;
    SM.tho=InitialConditions(2)*pi/180;
    iao=InitialConditions(3);
    ibo=InitialConditions(4);
    ico=InitialConditions(5);
    phao=InitialConditions(6);
    phbo=InitialConditions(7);
    phco=InitialConditions(8);



    Ld=SM.Ll+SM.Lmd;
    Lq=SM.Ll+SM.Lmq;


    Lf1d=SM.LC+SM.Lmd;
    Lfd=SM.Llfd+Lf1d;
    Lnew=(SM.Llfd*SM.Llkd)/(SM.Llfd+SM.Llkd)+SM.LC;
    invLad=1/SM.Lmd+1/SM.Ll+1/(Lnew);
    SM.Lad=1/invLad;
    invLaq=1/SM.Lmq+1/SM.Ll+1/SM.Llkq1+1/SM.Llkq2;
    SM.Laq=1/invLaq;



    SM.Vb=sqrt(2/3)*Vn;
    SM.Ib=sqrt(2/3)*Pn/Vn;
    SM.Pn=Pn;



    switch Units

    case{'per unit fundamental parameters','per unit standard parameters'}

        Vfopu=InitialConditions(9);
        SM.Ib2=1;
        SM.Vb2=1;
        SM.Pb=1;
        SM.Nb=1;
        SM.phib=1;
        Ifn=0;

    otherwise



        SM.Pb=Pn;
        SM.Nb=2*pi*MachineFrequency/SM.p;
        SM.phib=SM.Vb/(MachineFrequency*2*pi);
        SM.Ib2=SM.Ib;
        SM.Vb2=SM.Vb;

        if length(NominalParameters)<4
            Ifn=0;
        elseif NominalParameters(4)==0
            Ifn=0;
        else
            Ifn=NominalParameters(4);
            Ifb=Ifn*SM.Lmd;
        end

    end



    if SetSaturation
        ifsat=Saturation(1,:);
        vtpu=Saturation(2,:);
        slope=vtpu(1)/ifsat(1);
        iagpu=1/slope;
    end



    switch Units

    case{'per unit fundamental parameters','per unit standard parameters'}


        SM.Vfnp=SM.Rf/SM.Lmd;

        if SetSaturation==0


            Vfo=Vfopu*SM.Vfnp;
            SM.N2=SM.Lmd;

        else


            SM.N2=SM.Lmd*iagpu;
            Vfo=Vfopu*SM.Vfnp/iagpu;
            SM.Vfnp=SM.Vfnp/iagpu;


        end

    otherwise

        if Ifn==0



            SM.Vfnp=1/SM.Vb;
            SM.N2=SM.Ib;
            Vfo=InitialConditions(9)*SM.Rf/SM.Lmd;

        else



            SM.Vfnp=Ifb/SM.Ib;

            if SetSaturation==0



                SM.N2=Ifb;
                SM.Vfnp=2/3*SM.Vfnp/SM.Vb;
                Vfopu=InitialConditions(9);

            else



                SM.N2=Ifb*iagpu;
                SM.Vfnp=Ifb/Pn/iagpu;
                Vfopu=InitialConditions(9)/iagpu;

            end


            Vfo=Vfopu*SM.Rf/SM.Lmd;

        end
    end



    [~,iao]=pol2cart(phao*pi/180,iao);
    [~,ibo]=pol2cart(phbo*pi/180,ibo);
    [~,ico]=pol2cart(phco*pi/180,ico);



    ifdo=Vfo/SM.Rf;
    i2=[iao,ibo,ico]';dpt=2*pi/3;
    iqo=2/3*[cos(SM.tho),cos(SM.tho-dpt),cos(SM.tho+dpt)]*i2;
    ido=2/3*[sin(SM.tho),sin(SM.tho-dpt),sin(SM.tho+dpt)]*i2;



    switch excAxis

    case 1

        SM.phiqo=-Lq*iqo;
        SM.phikq1o=-SM.Lmq*iqo;
        SM.phikq2o=SM.phikq1o;
        SM.phido=(-Ld*ido+SM.Lmd*ifdo);

        SM.phikdo=(-SM.Lmd*ido+(Lf1d)*ifdo);
        SM.phifdo=(Lfd*ifdo+SM.Lmd*(-ido));

    case 2

        Vkq1o=InitialConditions(9);
        ikq1o=Vkq1o/SM.Rkq1;

        SM.phiqo=SM.Lmq*ikq1o;
        SM.phikq1o=ikq1o*(SM.Lmq+SM.Llkq1);
        SM.phikq2o=SM.phiqo;
        SM.phido=0;
        SM.phikdo=0;
        SM.phifdo=0;

    end



    if Ifn==0

        SM.vfn=SM.Rf*SM.Vb/SM.Lmd;
    else

        SM.vfn=SM.Rf/SM.Lmd/SM.Vfnp;
    end

    if SetSaturation

        vfn=SM.Rf/SM.Lmd/SM.Vfnp/iagpu;
    else
        vfn=SM.vfn;
    end

    if DisplayVfd








        if Ifn==0

            ifn_prime=SM.Ib/SM.Lmd;

            str1=sprintf('Field current producing 1 pu stator voltage:\n        ifn'' = %.4g A\n\n',ifn_prime);
            str1=[str1,sprintf('Field voltage producing 1 pu stator voltage:\n        Vfdn'' = %.4g V,',vfn)];
            if SetSaturation
                str1=[str1,sprintf('viewed from stator, including saturation.\n\n')];
            else
                str1=[str1,sprintf('viewed from stator.\n\n')];
            end
            str1=[str1,sprintf('Field resistance:\n        Rf = %.4g pu\n\nLeakage inductance:\n        Llfd = %.4g pu\n\n',SM.Rf,SM.Llfd)];

            msgbox(str1,gcb);

        else


            Ns_Nf=2/3*Ifb/SM.Ib;
            efdb=SM.Pn/Ifb;
            Zfb=efdb/Ifb;
            wb=MachineFrequency*2*pi;
            Rf_SI=SM.Rf*Zfb;
            Llfd_SI=SM.Llfd*Zfb/wb;

            str1=sprintf('Field current producing 1 pu stator voltage:\n        ifn = %.4g A\n\n',Ifn);
            str1=[str1,sprintf('Field voltage producing 1 pu stator voltage:\n        Vfdn = %.4g V, ',vfn)];
            if SetSaturation
                str1=[str1,sprintf('viewed from rotor, including saturation.\n\n')];
            else
                str1=[str1,sprintf('viewed from rotor.\n\n')];
            end
            str1=[str1,sprintf('Stator_winding/Field_winding transformation ratio:\n        Ns/Nf = %.4g\n\n',Ns_Nf)];

            str1=[str1,sprintf('Field resistance:\n        Rf = %.4g ohm  (%.4g pu)\n\nLeakage inductance:\n        Llfd = %.4g H  (%.4g pu)\n\n',Rf_SI,SM.Rf,Llfd_SI,SM.Llfd)];

            msgbox(str1,gcb);

        end
    end




    SM.excAxis=excAxis;
    SM.N=SM.Vfnp;
    SM.ib=SM.Ib;

    switch Units
    case 'SI fundamental parameters'
        SM.Gain1=SM.Pb;
    otherwise
        SM.Gain1=1;
    end

    SM.web=MachineFrequency*2*pi;
    SM.one_third=1/3;
    SM.sqrt3=sqrt(3);







    SM.Lsecd=SM.Ll+1/(1/SM.Lmd+1/Lnew);

    SM.Lsecq=SM.Ll+1/(1/SM.Lmq+1/SM.Llkq1+1/SM.Llkq2);


    SM.L2_pu=2*(SM.Lsecd*SM.Lsecq/(SM.Lsecd+SM.Lsecq));


    SM.Idqo=iao*exp(sqrt(-1)*(phao-InitialConditions(2))*pi/180);

    SM.Ido=real(SM.Idqo);
    SM.Iqo=imag(SM.Idqo);



    Lkd=SM.Llkd+SM.Lmd+SM.LC;
    Lkq1=SM.Llkq1+SM.Lmq;
    Lkq2=SM.Llkq2+SM.Lmq;

    switch RotorType

    case 'Salient-pole'



        SM.nState=5;
        SM.nSelectPhiq=[1,5];

        SM.R=...
        [SM.Rs,0,0,0,0
        0,SM.Rs,0,0,0
        0,0,SM.Rf,0,0
        0,0,0,SM.Rkd,0
        0,0,0,0,SM.Rkq1
        ];


        L=...
        [Lq,0,0,0,SM.Lmq
        0,Ld,SM.Lmd,SM.Lmd,0
        0,SM.Lmd,Lfd,Lf1d,0
        0,SM.Lmd,Lf1d,Lkd,0
        SM.Lmq,0,0,0,Lkq1
        ];



        SM.Llqd=...
        [SM.Ll,0,0,0,0
        0,SM.Ll,0,0,0
        0,0,SM.Llfd+LC,LC,0
        0,0,LC,SM.Llkd+LC,0
        0,0,0,0,SM.Llkq1
        ];

        SM.One_Llq=[1/SM.Ll,1/SM.Llkq1];
        SM.phiqd0=[SM.phiqo,SM.phido,SM.phifdo,SM.phikdo,SM.phikq1o]';
        SM.IqdSign=[-1,-1,1,1,1];

    case 'Round'



        SM.nState=6;
        SM.nSelectPhiq=[1,5,6];

        SM.R=...
        [SM.Rs,0,0,0,0,0
        0,SM.Rs,0,0,0,0
        0,0,SM.Rf,0,0,0
        0,0,0,SM.Rkd,0,0
        0,0,0,0,SM.Rkq1,0
        0,0,0,0,0,SM.Rkq2
        ];

        L=...
        [Lq,0,0,0,SM.Lmq,SM.Lmq
        0,Ld,SM.Lmd,SM.Lmd,0,0
        0,SM.Lmd,Lfd,Lf1d,0,0
        0,SM.Lmd,Lf1d,Lkd,0,0
        SM.Lmq,0,0,0,Lkq1,SM.Lmq
        SM.Lmq,0,0,0,SM.Lmq,Lkq2
        ];

        SM.Llqd=...
        [SM.Ll,0,0,0,0,0
        0,SM.Ll,0,0,0,0
        0,0,SM.Llfd+LC,LC,0,0
        0,0,LC,SM.Llkd+LC,0,0
        0,0,0,0,SM.Llkq1,0
        0,0,0,0,0,SM.Llkq2
        ];

        SM.One_Llq=[1/SM.Ll,1/SM.Llkq1,1/SM.Llkq2];
        SM.phiqd0=[SM.phiqo,SM.phido,SM.phifdo,SM.phikdo,SM.phikq1o,SM.phikq2o]';
        SM.IqdSign=[-1,-1,1,1,1,1];

    end

    switch IterativeModel
    case 'Trapezoidal iterative (alg. loop)'
        SM.Iterative=SM.nState;
    case 'Trapezoidal non iterative'
        SM.Iterative=0;
    end

    SM.Linv=inv(L);
    SM.RLinv=SM.R*SM.Linv;
    SM.iqd0=SM.Linv*SM.phiqd0.*SM.IqdSign';



    SM.Teo=SM.phido*SM.Iqo-SM.phiqo*SM.Ido;


    if SetSaturation

        SM.Sat=1;
        Isat=Saturation(1,:);
        Phisat=Saturation(2,:);

        for i=2:length(Isat)

            if(Phisat(i)-Phisat(i-1))<0||(Isat(i)-Isat(i-1))<0


                Phisat=[0,1];
                Isat=[0,1];

                block=gcb;

                block=strrep(block,newline,char(32));

                message=['In mask of ''',block,''' block:',newline,newline...
                ,'The Saturation parameters does not correspond to a monotonically increasing saturation characteristic.',...
                'A problem has been detected with the pair no.',num2str(i)];

                erreur.message=message;
                erreur.identifier='SpecializedPowerSystems:BlockParameterError';


                psberror(erreur)

            end
        end






        Lm_unsat=Phisat(1)/Isat(1);
        Lmsatq=Phisat./Isat*SM.Lmq/Lm_unsat;
        Lmsatd=Phisat./Isat*SM.Lmd/Lm_unsat;



        SM.Phisat=[0,Phisat];
        SM.Lmsatq=[Lmsatq(1),Lmsatq];
        SM.Lmsatd=[Lmsatd(1),Lmsatd];



        switch Units
        case{'per unit fundamental parameters','per unit standard parameters'}
            SM.Lmdsat_cor=Saturation(1,1)/Saturation(2,1);
        otherwise

            SM.Lmdsat_cor=1.0;
        end


    else

        SM.Sat=0;
        SM.Phisat=[0,1];
        SM.Lmsatq=[SM.Lmq,SM.Lmq];
        SM.Lmsatd=[SM.Lmd,SM.Lmd];

    end