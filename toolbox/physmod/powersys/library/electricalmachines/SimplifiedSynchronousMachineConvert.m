function[nom,mecpu,Zpu,initpu]=SimplifiedSynchronousMachineConvert(nom,mec,Z,InitialConditions)








    Pn=nom(1);
    Vn=nom(2);
    fn=nom(3);
    wen=fn*2*pi;
    ib=sqrt(2/3)*Pn/Vn;


    Zb=Vn^2/Pn;

    Lb=Zb/wen;


    p=mec(3);
    mecpu=[(wen/p)^2*mec(1)/(2*Pn),mec(2),p];


    Zpu=[Z(1)/Zb,Z(2)/Lb];


    switch length(InitialConditions)
    case 8
        initpu=[InitialConditions(1),InitialConditions(2),InitialConditions(3:5)/ib,InitialConditions(6:8)];
    case 9
        initpu=[InitialConditions(1),InitialConditions(2),InitialConditions(3:5)/ib,InitialConditions(6:9)];
    end
    iounits='on';%#ok