function[NominalParameters,Stator,Rotor,Cage1,Cage2,Lm,Mechanical,InitialConditions,Saturation]=AsynchronousMachineConvert(MechanicalLoad,NominalParameters,Stator,Rotor,Cage1,Cage2,Lm,Mechanical,PolePairs,InitialConditions,SimulateSaturation,Saturation)









    Pn=NominalParameters(1);
    Vn=NominalParameters(2);
    fn=NominalParameters(3);
    wen=fn*2*pi;
    ib=sqrt(2/3)*Pn/Vn;
    Zb=Vn^2/Pn;
    Lb=Zb/wen;


    switch MechanicalLoad
    case 'Torque Tm'
        if size(Mechanical,2)==3
            p=Mechanical(3);
        else
            p=PolePairs;
        end
    case 'Speed w'
        p=PolePairs;
    case 'Mechanical rotational port'
        if size(Mechanical,2)==3
            p=Mechanical(3);
        else
            p=PolePairs;
        end

    end

    Mechanical=[(wen/p)^2*Mechanical(1)/(2*Pn),Mechanical(2)*(wen/p)^2/Pn,p];


    Stator=Stator./[Zb,Lb];
    Rotor=Rotor./[Zb,Lb];
    Cage1=Cage1./[Zb,Lb];
    Cage2=Cage2./[Zb,Lb];
    Lm=Lm/Lb;


    if SimulateSaturation
        Currents=Saturation(1,:)*sqrt(2);
        Saturation=[Currents./ib;(Saturation(2,:))./Vn];
    end


    switch length(InitialConditions)
    case 8
        InitialConditions=InitialConditions./[1,1,ib,ib,ib,1,1,1];
    case 9
        InitialConditions=InitialConditions./[1,1,ib,ib,ib,1,1,1,1];
    case 14
        InitialConditions=InitialConditions./[1,1,ib,ib,ib,1,1,1,ib,ib,ib,1,1,1];
    case 15
        InitialConditions=InitialConditions./[1,1,ib,ib,ib,1,1,1,ib,ib,ib,1,1,1,1];
    end
