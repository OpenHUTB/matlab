function[FC,WantBlockChoice,Ts]=FuelCellInit(block,Eoc,NomVI,EndVI,Nc,n,Top,AirFr,SuppPress,Comp,FlowRateH2,FlowRateAir)






    power_initmask();


    switch get_param(block,'PresetModel')

    case 'PEMFC - 1.26 kW - 24 Vdc'

        Eoc=[42,35];
        NomVI=[52,24.23];
        EndVI=[100,20];
        Nc=42;
        n=46;
        Top=55;
        AirFr=2400;
        SuppPress=[1.5,1];
        Comp=[99.95,21,1];

    case 'PEMFC - 6 kW - 45 Vdc'

        Eoc=[65,63];
        NomVI=[133.3,45];
        EndVI=[225,37];
        Nc=65;
        n=55;
        Top=65;
        AirFr=300;
        SuppPress=[1.5,1];
        Comp=[99.95,21,1];

    case 'PEMFC - 50 kW - 625 Vdc'

        Eoc=[900,895];
        NomVI=[80,625];
        EndVI=[280,430];
        Nc=900;
        n=55;
        Top=65;
        AirFr=2100;
        SuppPress=[1.5,1];
        Comp=[99.95,21,1];

    case 'AFC - 2.4 kW - 48 Vdc'

        Eoc=[64.6,64];
        NomVI=[50,48];
        EndVI=[62,46];
        Nc=68;
        n=56;
        Top=65;
        AirFr=300;
        SuppPress=[6,1];
        Comp=[99.95,21,1];

    case 'SOFC - 3 kW - 100 Vdc'

        Eoc=[141.34,133];
        NomVI=[30,106.5];
        EndVI=[33.2,104.86];
        Nc=119;
        n=52;
        Top=600;
        AirFr=635;
        SuppPress=[1.35,1];
        Comp=[50,21,3];

    case 'SOFC - 25 kW - 630 Vdc'

        Eoc=[1076,1000];
        NomVI=[40,630];
        EndVI=[44.7,604];
        Nc=900;
        n=42;
        Top=860;
        AirFr=8260;
        SuppPress=[1.2,1];
        Comp=[40,21,1];

    end



    FC.F=96485;
    FC.R=8.3145;
    FC.Dh0=241.83e3;
    FC.Dg0=237.3e3;
    FC.k=1.38e-23;
    FC.h=6.626e-34;
    FC.Tstd=273;
    FC.Pstd=101325;
    FC.z=2;
    FC.MaxCurRatio=0.99;
    FC.IlRatio=1.01;
    FC.Patm=101325;



    FC.Pnom=NomVI(1)*NomVI(2);
    FC.Vnom=NomVI(2);
    FC.Inom=NomVI(1);
    Vend=EndVI(2);
    Iend=EndVI(1);
    FC.Imax=Iend;
    FC.Vmin=Vend;
    FC.Il=Iend*FC.IlRatio;
    FC.Ksin=pi/(2*(1/FC.MaxCurRatio-1));
    Eoc0=Eoc(1);Eoc1=Eoc(2);
    FC.OCV=Eoc0;



    FC.NcAnom=((Eoc1-FC.Vnom)*(Iend-1)-(Eoc1-Vend)*(FC.Inom-1))/((log(FC.Inom)*(Iend-1))-(log(Iend)*(FC.Inom-1)));
    FC.Rohm=(Eoc1-FC.Vnom-FC.NcAnom*log(FC.Inom))/(FC.Inom-1);
    FC.i0nom=exp((Eoc1-Eoc0+FC.Rohm)/(FC.NcAnom));

    WantDetailedModel=strcmp(get_param(block,'Detailed'),'Detailed');

    if~WantDetailedModel

        FC.x=0;
        FC.y=0;
        FC.Uf_H2=0;
        FC.Uf_O2=0;
        FC.Tnom=0;
        FC.Patm=1;
        FC.Pf=0;
        FC.PAir=0;

    else

        n=n/100;
        FC.Nc=Nc;
        FC.x=Comp(1)/100;
        FC.y=Comp(2)/100;
        FC.xy=Comp(3)/100;
        FC.Pf=SuppPress(1);
        FC.PAir=SuppPress(2);
        FC.Tnom=Top+273;

        FC.Uf_H2=n*FC.Dh0*FC.Nc/(FC.z*FC.F*FC.Vnom);

        if FC.Uf_H2>0.9999
            error(message('physmod:powersys:drives:InvalidFuelCellUtilization',block,...
            ['The H2 utilization (Uf_H2 = ',num2str(FC.Uf_H2*100,4),'%)'],...
            '99.99%','Reduce the efficiency or increase the nominal voltage to get a smaller utilization.'));
        end

        FC.Uf_O2=60000*FC.R*FC.Tnom*FC.Nc*FC.Inom/(4*FC.F*FC.PAir*FC.Pstd*AirFr*FC.y);

        if FC.Uf_O2>0.9999
            error(message('physmod:powersys:drives:InvalidFuelCellUtilization',block,...
            ['The O2 utilization (Uf_O2 = ',num2str(FC.Uf_O2*100,4),'%)'],...
            '99.99%','Increase the nominal air flow rate to get a smaller utilization.'));
        end

        FC.FuelFr_Nom=60000*FC.R*FC.Tnom*FC.Nc*FC.Inom/(FC.z*FC.F*FC.Pf*FC.Pstd*FC.Uf_H2*FC.x);
        FC.AirFr_Nom=60000*FC.R*FC.Tnom*FC.Nc*FC.Inom/(4*FC.F*FC.PAir*FC.Pstd*FC.Uf_O2*FC.y);
        FC.FuelFr_Max=60000*FC.R*FC.Tnom*FC.Nc*Iend/(FC.z*FC.F*FC.Pf*FC.Pstd*FC.Uf_H2*FC.x);
        FC.AirFr_Max=60000*FC.R*FC.Tnom*FC.Nc*Iend/(4*FC.F*FC.PAir*FC.Pstd*FC.Uf_O2*FC.y);
        FC.Vslpm_Fuel=60000*FC.R*FC.Tstd*FC.Nc*FC.Inom/(FC.z*FC.F*FC.Pstd*FC.x);
        FC.Vslpm_Air=60000*FC.R*FC.Tstd*FC.Nc*FC.Inom/(4*FC.F*FC.Pstd*FC.y);

        Anom=FC.NcAnom/FC.Nc;
        FC.alpha=FC.R*FC.Tnom/(FC.z*Anom*FC.F);
        PH2in=FC.x*FC.Pf;
        PO2in=FC.y*FC.PAir;
        PH2=FC.x*(1-FC.Uf_H2)*FC.Pf;
        PO2=FC.y*(1-FC.Uf_O2)*FC.PAir;

        if Top<100
            PH2O=1;
        else
            PH2O=(FC.xy+2*FC.y*FC.Uf_O2)*FC.PAir;
        end

        Enomin=1.229+(FC.Tnom-298.15)*(-44.43/(FC.z*FC.F))+(FC.R*FC.Tnom/(FC.z*FC.F))*log(PH2in*sqrt(PO2in));
        Enom=1.229+(FC.Tnom-298.15)*(-44.43/(FC.z*FC.F))+(FC.R*FC.Tnom/(FC.z*FC.F))*log(PH2*sqrt(PO2)/PH2O);
        FC.Ennom=Enom;

        FC.K1=2*FC.F*FC.k*(PH2*FC.Pstd+PO2*FC.Pstd)/(FC.h*FC.R);
        FC.Dg=-FC.R*FC.Tnom*log(FC.i0nom/FC.K1);
        FC.Ki=Eoc0/Enomin;
        FC.Kc=Eoc0/Enom;

    end

    if strcmp(get_param(block,'FCDyn'),'on')


        FC.Tau=getSPSmaskvalues(block,{'FC_tau'})/3;
        FC.uv=getSPSmaskvalues(block,{'V_Under'});
        FC.ufO2max=getSPSmaskvalues(block,{'Peak_O2'})/100;

        if FC.ufO2max<FC.Uf_O2
            error(message('physmod:powersys:common:GreaterThan',block,...
            ['The Peak O2 utilization (%) (Uf_O2_peak = ',num2str(FC.ufO2max*100,4),'%)'],...
            ['the nominal O2 utilization (%) (Uf_O2 = ',num2str(FC.Uf_O2*100,4),'%)']));
        end

    else
        FC.Tau=0;
        FC.uv=0;
        FC.ufO2max=0;
    end

    if FlowRateH2
        FC.sel_UfH2=0;
    else
        FC.sel_UfH2=1;
    end

    if FlowRateAir
        FC.sel_UfO2=0;
    else
        FC.sel_UfO2=1;
        FC.AirFr_Max=0;
    end





    PowerguiInfo=powericon('getPowerguiInfo',bdroot(block),block);
    Ts=PowerguiInfo.Ts;

    WantDiscreteModel=PowerguiInfo.Discrete;

    if WantDetailedModel
        WantBlockDetailed='Detailed';
    else
        WantBlockDetailed='Simplified';
    end

    if WantDiscreteModel
        WantBlockChoice=['Discrete/',WantBlockDetailed];
    else
        WantBlockChoice=['Continuous/',WantBlockDetailed];
    end



    MV=get_param(block,'MaskValues');
    PS=cell(9,1);

    switch get_param(block,'PresetModel')

    case 'No (User-Defined)'

        PS=MV(4:12);

    case 'PEMFC - 1.26 kW - 24 Vdc'

        PS{1}='[42,35]';
        PS{2}='[52,24.23]';
        PS{3}='[100,20]';
        PS{4}='42';
        PS{5}='46';
        PS{6}='55';
        PS{7}='2400';
        PS{8}='[1.5,1]';
        PS{9}='[99.95,21,1]';

    case 'PEMFC - 6 kW - 45 Vdc'

        PS{1}='[65,63]';
        PS{2}='[133.3,45]';
        PS{3}='[225,37]';
        PS{4}='65';
        PS{5}='55';
        PS{6}='65';
        PS{7}='300';
        PS{8}='[1.5,1]';
        PS{9}='[99.95,21,1]';

    case 'PEMFC - 50 kW - 625 Vdc'

        PS{1}='[900,895]';
        PS{2}='[80,625]';
        PS{3}='[280,430]';
        PS{4}='900';
        PS{5}='55';
        PS{6}='65';
        PS{7}='2100';
        PS{8}='[1.5,1]';
        PS{9}='[99.95,21,1]';

    case 'AFC - 2.4 kW - 48 Vdc'

        PS{1}='[64.6,64]';
        PS{2}='[50,48]';
        PS{3}='[62,46]';
        PS{4}='68';
        PS{5}='56';
        PS{6}='65';
        PS{7}='300';
        PS{8}='[6,1]';
        PS{9}='[99.95,21,1]';

    case 'SOFC - 3 kW - 100 Vdc'

        PS{1}='[141.34,133]';
        PS{2}='[30,106.5]';
        PS{3}='[33.2,104.86]';
        PS{4}='119';
        PS{5}='52';
        PS{6}='600';
        PS{7}='635';
        PS{8}='[1.35,1]';
        PS{9}='[50,21,3]';

    case 'SOFC - 25 kW - 630 Vdc'

        PS{1}='[1076,1000]';
        PS{2}='[40,630]';
        PS{3}='[44.7,604]';
        PS{4}='900';
        PS{5}='42';
        PS{6}='860';
        PS{7}='8260';
        PS{8}='[1.2,1]';
        PS{9}='[40,21,1]';

    end

    if~isequal(PS,MV(4:12))










        set_param(block,'Eoc',PS{1})
        set_param(block,'NomVI',PS{2})
        set_param(block,'EndVI',PS{3})
        set_param(block,'Nc',PS{4})
        set_param(block,'n',PS{5})
        set_param(block,'TOp',PS{6})
        set_param(block,'AirFr',PS{7})
        set_param(block,'SuppPress',PS{8})
        set_param(block,'Comp',PS{9})

    end

