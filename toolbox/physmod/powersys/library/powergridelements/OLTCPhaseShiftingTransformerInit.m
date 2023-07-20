function[Vnom,Pnom,Fnom,w,a,Z1pu,Zmpu,I2A_init_mag,I2B_init_mag,I2C_init_mag,I2A_init_pha,I2B_init_pha,I2C_init_pha,I1A_init_mag,I1B_init_mag,I1C_init_mag,I1A_init_pha,I1B_init_pha,I1C_init_pha,TapMinMax,I21_init_real,I21_init_imag,Ibase]=OLTCPhaseShiftingTransformerInit(NominalParameters,NumberOfTaps,InitialTap,Iout_init,RXpu,RXm)
    if abs(InitialTap)>NumberOfTaps
        error(message('physmod:powersys:common:IntegerOption','Initial tap',num2str(-NumberOfTaps),num2str(NumberOfTaps)));
    end
    Vnom=NominalParameters(1);
    Pnom=NominalParameters(2);
    Fnom=NominalParameters(3);
    w=2*pi*Fnom;
    Ibase=Pnom/Vnom/sqrt(3)*sqrt(2);

    TapMinMax=[-NumberOfTaps,NumberOfTaps];

    j=sqrt(-1);
    a=exp(j*2*pi/3);
    Z1pu=RXpu(1)+j*RXpu(2);
    Zmpu=(RXm(1)*j*RXm(2))/(RXm(1)+j*RXm(2));

    I2_init_mag=Iout_init(1);
    I2_init_pha=Iout_init(2);
    I2A_init_mag=I2_init_mag*Ibase;
    I2B_init_mag=I2_init_mag*Ibase;
    I2C_init_mag=I2_init_mag*Ibase;
    I2A_init_pha=I2_init_pha;
    I2B_init_pha=I2_init_pha-120;
    I2C_init_pha=I2_init_pha+120;

    psi=2*atan(-InitialTap/NumberOfTaps/sqrt(3))*180/pi;

    I1A_init_mag=I2A_init_mag;
    I1B_init_mag=I2B_init_mag;
    I1C_init_mag=I2C_init_mag;
    I1A_init_pha=I2A_init_pha-psi;
    I1B_init_pha=I2B_init_pha-psi;
    I1C_init_pha=I2C_init_pha-psi;


    [I21_init_real,I21_init_imag]=pol2cart(I2_init_pha*pi/180,I2_init_mag);
    power_initmask();


