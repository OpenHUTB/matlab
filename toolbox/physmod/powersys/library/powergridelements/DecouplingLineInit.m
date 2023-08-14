function[Ti,Tau,h,Z,Zmode,Zc,Rt4,V1_init,I1_init,I3_init,Ts]=DecouplingLineInit(block,Nphases,long,f,R,L,C,VsMag0,VsAngle0,IhsMag0,IhsAngle0)






    PowerguiInfo=getPowerguiInfo(bdroot(block),block);
    Ts=PowerguiInfo.Ts;
    if Ts==0
        Ts=50e-6;
    end

    blocinit(block,{Nphases,f,R,L,C,long});

    [Zmode,Rmode,Smode,Ti]=blmodlin(Nphases,f,R,L,C);

    Zimp=zeros(Nphases,Nphases);
    for iphase=1:Nphases
        Zimp(iphase,iphase)=Zmode(iphase)+0.25*Rmode(iphase)*long;
    end
    Yphase=Ti*inv(Zimp)*(Ti');

    Tau=long./Smode;
    Rt4=Rmode*long/4;
    Z=Zmode+Rt4;
    h=(Zmode-Rt4)./(Zmode+Rt4);


    Zc=zeros(Nphases,Nphases);
    for jj=1:Nphases
        Zc(jj,jj)=1/sum(Yphase(jj,:));
        for k=jj+1:Nphases
            Zc(jj,k)=-1/Yphase(jj,k);
            Zc(k,jj)=-1/Yphase(jj,k);
        end
    end

    VsModes0=Ti'*(VsMag0.*exp(1i*VsAngle0*pi/180)).';
    VsModesMag0=abs(VsModes0);
    VsModesAngle0=angle(VsModes0);

    IhsModes0=inv(Ti)*(IhsMag0.*exp(1i*IhsAngle0*pi/180)).';
    IhsModesMag0=abs(IhsModes0);
    IhsModesAngle0=angle(IhsModes0);


    Tmax=Ts*ceil(max(Tau/Ts));
    t=-Tmax:Ts:-Ts;

    I3_init=zeros(1,Nphases);

    w=2*pi*f;

    for imode=1:Nphases


        V1_init(:,imode)=VsModesMag0(imode)*sin(w*t+VsModesAngle0(imode));
        I1_init(:,imode)=IhsModesMag0(imode)*h(imode)*sin(w*t+IhsModesAngle0(imode));



        Vinit=VsModesMag0(imode)*sin(w*(-Ts-Tau(imode)+Ts)+VsModesAngle0(imode));


        Iinit=IhsModesMag0(imode)*h(imode)*sin(w*(-Ts-Tau(imode)+Ts)+IhsModesAngle0(imode));


        I3_init(imode)=Vinit*(1+h(imode))/(Zmode(imode)+Rt4(imode))-Iinit;

    end

    DecouplingLinePorts(block)

    switch get_param(block,'ShowPorts')
    case 'off'
        ConnectorID=get_param(block,'ConnectorID');
        switch ConnectorID(end)
        case 'S'

            set_param([block,'/send'],'GotoTag',ConnectorID,'TagVisibility','Global');
            ConnectorID(end)='R';
            set_param([block,'/receive'],'GotoTag',ConnectorID,'TagVisibility','Global');
        case 'R'

            set_param([block,'/send'],'GotoTag',ConnectorID,'TagVisibility','Global');
            ConnectorID(end)='S';
            set_param([block,'/receive'],'GotoTag',ConnectorID,'TagVisibility','Global');
        end
    end