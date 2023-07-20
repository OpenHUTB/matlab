function[MainWindingStator,MainWindingRotor,MutualInductance,AuxiliaryWinding,Mechanical,CapacitorStart,CapacitorRun]...
    =SinglePhaseAsynchronousMachineConvert(block,UNITS)









    NominalParameters=getSPSmaskvalues(block,{'NominalParameters'},0,1);
    MainWindingStator=getSPSmaskvalues(block,{'MainWindingStator'},0,1);
    MainWindingRotor=getSPSmaskvalues(block,{'MainWindingRotor'},0,1);
    MutualInductance=getSPSmaskvalues(block,{'MutualInductance'},0,1);
    AuxiliaryWinding=getSPSmaskvalues(block,{'AuxiliaryWinding'},0,1);
    Mechanical=getSPSmaskvalues(block,{'Mechanical'},0,1);
    CapacitorStart=getSPSmaskvalues(block,{'CapacitorStart'},0,1);
    CapacitorRun=getSPSmaskvalues(block,{'CapacitorRun'},0,1);

    Pn=NominalParameters(1);
    Vn=NominalParameters(2);
    freq=NominalParameters(3);
    p=Mechanical(3);


    web_psb=2*pi*freq;
    wmb=web_psb/p;
    Tn=Pn/wmb;
    Vb=sqrt(2)*Vn;
    ib=sqrt(2)*Pn/Vn;
    phib=Vb/web_psb;
    Zb=Vn^2/Pn;
    Lb=Zb/web_psb;
    Cb=1/(Zb*web_psb);

    if strcmp(UNITS,'pu')

        MainWindingStator=[MainWindingStator(1)/Zb,MainWindingStator(2)/Lb];
        MainWindingRotor=[MainWindingRotor(1)/Zb,MainWindingRotor(2)/Lb];
        MutualInductance=MutualInductance/Lb;
        AuxiliaryWinding=[AuxiliaryWinding(1)/Zb,AuxiliaryWinding(2)/Lb];
        J=Mechanical(1);
        F=Mechanical(2);
        p=Mechanical(3);
        N=Mechanical(4);
        H=J*wmb^2/(2*Pn);
        F=F/(Pn/wmb^2);
        Mechanical=[H,F,p,N];
        CapacitorStart=[CapacitorStart(1)/Zb,CapacitorStart(2)/Cb];
        CapacitorRun=[CapacitorRun(1)/Zb,CapacitorRun(2)/Cb];
    end

    if strcmp(UNITS,'SI')

        MainWindingStator=[MainWindingStator(1)*Zb,MainWindingStator(2)*Lb];
        MainWindingRotor=[MainWindingRotor(1)*Zb,MainWindingRotor(2)*Lb];
        MutualInductance=MutualInductance*Lb;
        AuxiliaryWinding=[AuxiliaryWinding(1)*Zb,AuxiliaryWinding(2)*Lb];
        H=Mechanical(1);
        F=Mechanical(2);
        p=Mechanical(3);
        N=Mechanical(4);
        J=(H*2*Pn)/wmb^2;
        F=F*(Pn/wmb^2);
        Mechanical=[J,F,p,N];
        CapacitorStart=[CapacitorStart(1)*Zb,CapacitorStart(2)*Cb];
        CapacitorRun=[CapacitorRun(1)*Zb,CapacitorRun(2)*Cb];
    end