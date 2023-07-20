function SSM=SimplifiedSynchronousMachineParam(nom,mec,Z,InitialConditions,Units,LoadFlowFrequency)








    Pn=nom(1);
    SSM.Pn=Pn;
    Vn=nom(2);
    MachineFrequency=nom(3);
    SSM.Kd=mec(2);
    SSM.R=Z(1);
    SSM.L=Z(2);
    SSM.p=mec(3);
    SSM.web=MachineFrequency*2*pi;
    wmn=SSM.web/SSM.p;
    SSM.pi23=2*pi/3;
    SSM.Vb=sqrt(2/3)*Vn;
    SSM.ib=sqrt(2/3)*Pn/Vn;

    SSM.dwo=InitialConditions(1)/100;
    SSM.tho=InitialConditions(2)*pi/180;
    SSM.H=mec(1);

    if~exist('LoadFlowFrequency','var')
        SSM.LoadFlowFrequency=MachineFrequency;
    else
        if isnan(LoadFlowFrequency)
            SSM.LoadFlowFrequency=MachineFrequency;
        else
            SSM.LoadFlowFrequency=LoadFlowFrequency;
        end
    end

    switch Units
    case 'SI'
        SSM.Pb=Pn;
        SSM.Nb=wmn;
        SSM.Vb2=Vn;
        SSM.Vb3=SSM.Vb;
        SSM.ib2=SSM.ib;
    case 'pu'
        SSM.Pb=1;
        SSM.Nb=1;
        SSM.Vb2=1;
        SSM.Vb3=1;
        SSM.ib2=1;
    end

    d2r=pi/180;
    iao=InitialConditions(3);
    ibo=InitialConditions(4);
    ico=InitialConditions(5);
    phao=InitialConditions(6)*d2r;
    phbo=InitialConditions(7)*d2r;
    phco=InitialConditions(8)*d2r;
    [scrap,iao]=pol2cart(phao,iao);%#ok
    [scrap,ibo]=pol2cart(phbo,ibo);%#ok
    [scrap,ico]=pol2cart(phco,ico);%#ok
    SSM.io=[iao,ibo,ico];