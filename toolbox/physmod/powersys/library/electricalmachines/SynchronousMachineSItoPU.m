function[NominalParameters,Stator,Field,Dampers,Mechanical,InitialConditions,Saturation,Xc]=SynchronousMachineSItoPU(block,NominalParameters,Stator,Field,Dampers,Mechanical,InitialConditions,SetSaturation,Saturation,PolePairs)






    Pn=NominalParameters(1);
    Vn=NominalParameters(2);
    fn=NominalParameters(3);
    wen=2*pi*fn;


    Zb=Vn*Vn/Pn;

    Lb=Zb/wen;


    Ib=sqrt(2/3)*Pn/Vn;
    iopu=InitialConditions(3:5)/Ib;

    Rs=Stator(1)/Zb;
    Ll=Stator(2)/Lb;
    Lmd=Stator(3)/Lb;
    Lmq=Stator(4)/Lb;

    if length(Stator)==5
        Xc=Stator(5)/Lb;
    else
        Xc=0;
    end


    Rf=Field(1)/Zb;
    Llfd=Field(2)/Lb;

    Rkd=Dampers(1)/Zb;
    Llkd=Dampers(2)/Lb;
    Rkq1=Dampers(3)/Zb;
    Llkq1=Dampers(4)/Lb;
    Rkq2=Dampers(5)/Zb;
    Llkq2=Dampers(6)/Lb;

    if size(Mechanical,2)==3





        if size(Mechanical,2)==3
            PolePairs=Mechanical(3);
        end

        wmn=wen/PolePairs;
        Mechanical=[...
        Mechanical(1)*wmn^2/2/Pn,...
        Mechanical(2)*wmn^2/Pn,...
        PolePairs];
    end

    if length(NominalParameters)<4||NominalParameters(4)==0


        Vb=sqrt(2/3)*Vn;
        Ifn=0;

        Vfns=Rf*Vb/Lmd;

        Vfopu=InitialConditions(9)/Vfns;



        if SetSaturation
            if~isempty(Saturation)
                Saturation=[Saturation(1,:)/Saturation(1,1);Saturation(2,:)/Vn];
            end
        end

    else


        Ifn=NominalParameters(4);

        Vfnr=Rf*Pn/(Ifn*Lmd^2);

        Vfopu=InitialConditions(9)/Vfnr;
        if SetSaturation
            if~isempty(Saturation)
                Saturation=[Saturation(1,:)/Ifn;Saturation(2,:)/Vn];
            end
        end

    end

    switch length(InitialConditions)
    case 9
        InitialConditions=[InitialConditions(1:2),iopu,InitialConditions(6:8),Vfopu];
    case 10
        InitialConditions=[InitialConditions(1:2),iopu,InitialConditions(6:8),Vfopu,InitialConditions(10)];
    end

    if SetSaturation&&Ifn==0
        if isequal('initializing',get_param(bdroot(block),'SimulationStatus'))
            Txt=['Field current value (Ifn parameter) must be different from zero when the Simulate saturation parameter is checked in block:',...
            newline,newline,strrep(block,newline,char(32))];
            Erreur.message=Txt;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur)
        end
    end

    if length(Stator)==5
        Stator=[Rs,Ll,Lmd,Lmq,Xc];
    else
        Stator=[Rs,Ll,Lmd,Lmq];
    end
    Field=[Rf,Llfd];
    Dampers=[Rkd,Llkd,Rkq1,Llkq1,Rkq2,Llkq2];

    if any([Stator(1:4),Field,Dampers]<0)

        warning(message('physmod:powersys:library:InconsistentReactancesTimeConstants',block));
    end
