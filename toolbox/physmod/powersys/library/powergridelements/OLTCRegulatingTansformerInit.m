function[varargout]=OLTCRegulatingTansformerInit(InitialTap,TapMinMax,PnomFnom,Winding1,Winding1Connection,Winding2,Winding2Connection,Regulator,Iw2_init,TapOnWinding,dU,WindingTap)


    if~(InitialTap>=TapMinMax(1)&&InitialTap<=TapMinMax(2)&&(ceil(InitialTap)-InitialTap)==0)
        error(message('physmod:powersys:common:IntegerOption','Initial tap position',num2str(TapMinMax(1)),num2str(TapMinMax(2))));
    end

    Pnom=PnomFnom(1);
    varargout{32}=Pnom;
    Fnom=PnomFnom(2);
    varargout{33}=Fnom;
    w=2*pi*Fnom;
    varargout{27}=w;
    Vnom1=Winding1(1);
    varargout{28}=Vnom1;
    Vnom2=Winding2(1);
    varargout{29}=Vnom2;
    Ibase1=Pnom/Vnom1/sqrt(3)*sqrt(2);
    varargout{30}=Ibase1;
    Ibase2=Pnom/Vnom2/sqrt(3)*sqrt(2);
    varargout{31}=Ibase2;
    j=sqrt(-1);
    a=exp(j*2*pi/3);


    varargout{1}=a;

    Z1pu=Winding1(2)+j*Winding1(3);
    varargout{2}=Z1pu;
    Z2pu=Winding2(2)+j*Winding2(3);
    varargout{3}=Z2pu;
    Ztpu=WindingTap(1)+j*WindingTap(2);
    varargout{4}=Ztpu;


    Nmax=max(abs(TapMinMax));
    varargout{26}=Nmax;


    psi=0;




    ks=1;kr=1;
    if strcmp(Winding1Connection,'Delta (D1)')
        psi=psi+30;
        ks=0;
    elseif strcmp(Winding1Connection,'Delta (D11)')
        psi=psi-30;
        ks=0;
    elseif strcmp(Winding1Connection,'Y')
        ks=0;
        kr=0;
    end
    if strcmp(Winding2Connection,'Delta (D1)')
        psi=psi-30;
        kr=0;
    elseif strcmp(Winding2Connection,'Delta (D11)')
        psi=psi+30;
        kr=0;
    elseif strcmp(Winding2Connection,'Y')
        ks=0;
        kr=0;
    end

    varargout{5}=psi;
    varargout{6}=ks;
    varargout{7}=kr;

    RegulatorVref=Regulator(1);
    varargout{8}=RegulatorVref;
    RegulatorDeadBand=Regulator(2);
    varargout{9}=RegulatorDeadBand;
    RegulatorDelay=Regulator(3);
    varargout{10}=RegulatorDelay;


    Iw2_init_mag=Iw2_init(1);
    Iw2_init_pha=Iw2_init(2);

    Iw2A_init_mag=Iw2_init_mag*Ibase2;
    varargout{11}=Iw2A_init_mag;
    Iw2B_init_mag=Iw2_init_mag*Ibase2;
    varargout{12}=Iw2B_init_mag;
    Iw2C_init_mag=Iw2_init_mag*Ibase2;
    varargout{13}=Iw2C_init_mag;
    Iw2A_init_pha=Iw2_init_pha;
    varargout{14}=Iw2A_init_pha;
    Iw2B_init_pha=Iw2_init_pha-120;
    varargout{15}=Iw2B_init_pha;
    Iw2C_init_pha=Iw2_init_pha+120;
    varargout{16}=Iw2C_init_pha;

    if TapOnWinding==1
        N2_N1=1/(1+InitialTap*dU);
    else
        N2_N1=1+InitialTap*dU;
    end

    varargout{17}=N2_N1;


    Iw1A_init_mag=Iw2A_init_mag*N2_N1*Vnom2/Vnom1;
    varargout{18}=Iw1A_init_mag;
    Iw1B_init_mag=Iw2B_init_mag*N2_N1*Vnom2/Vnom1;
    varargout{19}=Iw1B_init_mag;
    Iw1C_init_mag=Iw2C_init_mag*N2_N1*Vnom2/Vnom1;
    varargout{20}=Iw1C_init_mag;
    Iw1A_init_pha=Iw2A_init_pha-psi;
    varargout{21}=Iw1A_init_pha;
    Iw1B_init_pha=Iw2B_init_pha-psi;
    varargout{22}=Iw1B_init_pha;
    Iw1C_init_pha=Iw2C_init_pha-psi;
    varargout{23}=Iw1C_init_pha;


    I21_init_real=Iw2_init_mag*cos(Iw2_init_pha*pi/180);
    I21_init_imag=Iw2_init_mag*sin(Iw2_init_pha*pi/180);


    varargout{24}=I21_init_real;
    varargout{25}=I21_init_imag;


