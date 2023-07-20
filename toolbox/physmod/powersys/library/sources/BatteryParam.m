function[Batt,BT,WantBlockChoice,Ts]=BatteryParam(NomV,NomQ,MaxQ,MinV,FullV,Dis_rate,R,Normal_OP,expZone,block,DisplayPlot)















    if license('test','Optimization_Toolbox')&&~isempty(ver('optim'))
        OptimizationToolbox=1;
    else
        OptimizationToolbox=0;
    end

    StoppedSimulation=isequal('stopped',get_param(bdroot(block),'SimulationStatus'));
    PreDeterminedDischarge=strcmp(get_param(block,'PresetModel'),'on');
    SimulateTemperature=strcmp(get_param(block,'ShowTempParam'),'on')&&strcmp(get_param(block,'BatType'),'Lithium-Ion');
    SimulateAging=strcmp(get_param(block,'ShowAgeParam'),'on')&&strcmp(get_param(block,'BatType'),'Lithium-Ion');


    if~StoppedSimulation

        if FullV<expZone(1)
            error(message('physmod:powersys:common:GreaterThan',block,'Fully charged voltage','Exponential zone voltage'));
        end
        if expZone(1)<NomV
            error(message('physmod:powersys:common:GreaterThan',block,'Exponential zone voltage','Nominal voltage'));
        end
    end



    Batt.solutionFound=0;
    Batt.alpha=0;
    Batt.beta=0;
    Batt.dE_dT=0;
    Batt.dQ_dT=0;

    UseThermalPreset=0;

    if SimulateTemperature

        ThermalPreset=get_param(block,'ThermalPreset');

        switch ThermalPreset

        case '3.3V  2.3Ah  (LiFePO4)'

            PreDeterminedDischarge=0;

            NomV=3.3;
            NomQ=2.3;
            MaxQ=2.3;
            MinV=NomV*0.75;
            FullV=3.748;
            Dis_rate=2.3;
            R=1.40E-02;
            Normal_OP=2.25;
            expZone=[3.4788,0.113];
            NomT=25;
            T2=0;
            MaxQ2=2.208;
            FullV2=3.45;
            Normal_OP2=2.85;
            ExpZone2=[3.22,0.015];
            Rca=0.6;
            ti=1000;
            Dp=0;
            E0x=3.4265;
            dE_dTx=1.1927e-05;
            Kx=6.4489e-04;
            Ax=0.3802;
            alphax=1.9019e+03;
            betax=9.0587e+03;

        case '3.6V  2050mAh   (LiCoO2)'

            PreDeterminedDischarge=0;

            NomV=3.35;
            NomQ=2.05;
            MaxQ=2;
            MinV=NomV*0.75;
            FullV=4.2;
            Dis_rate=1.95;
            R=1.65E-02;
            Normal_OP=1.81;
            expZone=[3.71,0.6];
            NomT=25;
            T2=0;
            MaxQ2=1.78;
            FullV2=4;
            Normal_OP2=3.11;
            ExpZone2=[3.8,0.2];
            Rca=0.06;
            ti=1000;
            Dp=0;
            E0x=3.9274;
            dE_dTx=0.0032;
            Kx=6.2943e-04;
            Ax=0.2653;
            alphax=8.7840e+03;
            betax=1.3252e+03;

        case '3.6V  2.0Ah'

            PreDeterminedDischarge=0;

            NomV=3.5;
            NomQ=2;
            MaxQ=2.05;
            MinV=NomV*0.75;
            FullV=4.1;
            Dis_rate=0.4;
            R=1.70E-02;
            Normal_OP=1.8087;
            expZone=[3.88,0.2];

            NomT=115;
            T2=0;
            MaxQ2=1.65;
            FullV2=4;
            Normal_OP2=3.25;
            ExpZone2=[3.8,0.2];
            Rca=0.06;
            ti=1000;
            Dp=0;

            E0x=3.9538;
            dE_dTx=6.1832e-04;
            Kx=0.0032;
            Ax=0.1440;
            alphax=1.8552e+03;
            betax=109.9940;

        case '3.6V  3.6Ah  (LiNiO2)'

            PreDeterminedDischarge=0;

            NomV=3.1;
            NomQ=3.6;
            MaxQ=3.2;
            MinV=NomV*0.75;
            FullV=3.75;
            Dis_rate=0.72;
            R=8.89E-03;
            Normal_OP=2.8;
            expZone=[3.5,0.5];

            NomT=20;
            T2=0;
            MaxQ2=2.7;

            FullV2=3.5;
            Normal_OP2=2.94;
            ExpZone2=[3.25,0.5];
            Rca=0.6;
            ti=1000;
            Dp=0;

            E0x=3.6199;
            dE_dTx=0.0059;
            Kx=0.0030;
            Ax=0.1220;
            alphax=6.5258e+03;
            betax=7.5948e+03;

        case '3.6V  4.5Ah'

            PreDeterminedDischarge=0;

            NomV=3.3;
            NomQ=4.5;
            MaxQ=4.8;
            MinV=NomV*0.75;
            FullV=4.1;
            Dis_rate=0.9;
            R=7.56E-03;
            Normal_OP=4.0696;
            expZone=[3.88,0.5];

            NomT=115;
            T2=0;
            MaxQ2=4.2;
            FullV2=4;
            Normal_OP2=3.1;
            ExpZone2=[3.8,0.25];
            Rca=0.06;
            ti=1000;
            Dp=0;

            E0x=3.9998;
            dE_dTx=1.2609e-05;
            Kx=0.0017;
            Ax=0.0727;
            alphax=1.9743e+03;
            betax=1.9478e+03;

        case '3.6V  48Ah  (LiNiO2)'

            PreDeterminedDischarge=0;

            NomV=3.4;
            NomQ=48;
            MaxQ=50;
            MinV=NomV*0.75;
            FullV=4;
            Dis_rate=24;
            R=6.88E-04;
            Normal_OP=44.5;
            expZone=[3.9,3.8];

            NomT=20;
            T2=0;
            MaxQ2=45;
            FullV2=3.9;
            Normal_OP2=3.24;
            ExpZone2=[3.78,5];
            Rca=0.6;
            ti=500;
            Dp=0;

            E0x=3.9400;
            dE_dTx=2.3793e-05;
            Kx=0.0015;
            Ax=0.0609;
            alphax=1.1103e+03;
            betax=8.0766e+03;

        case '3.7V  4.4Ah'

            PreDeterminedDischarge=0;

            NomV=3.4;
            NomQ=4.4;
            MaxQ=4.5;
            MinV=NomV*0.75;
            FullV=4.125;
            Dis_rate=0.9;
            R=8.18E-03;
            Normal_OP=4;
            expZone=[4,0.5];

            NomT=20;
            T2=-30;
            MaxQ2=3.8;
            FullV2=3.38;
            Normal_OP2=2.75;
            ExpZone2=[3.25,0.5];
            Rca=0.06;
            ti=1000;
            Dp=0;

            E0x=4.1053;
            dE_dTx=0.0142;
            Kx=9.6025e-04;
            Ax=0.0161;
            alphax=1.5774e+03;
            betax=1.9992e+03;

        case '7.4V  5.4Ah  (LiCoO2)'

            PreDeterminedDischarge=0;

            NomV=7;
            NomQ=5.4;
            MaxQ=5.6;
            MinV=NomV*0.75;
            FullV=8.3807;
            Dis_rate=1.1;
            R=1.33E-02;
            Normal_OP=5.2;
            expZone=[7.9,1];

            NomT=20;
            T2=-30;
            MaxQ2=4.8;
            FullV2=7.1;
            Normal_OP2=5.655;
            ExpZone2=[6.58,1];
            Rca=0.6;
            ti=2000;
            Dp=0;

            E0x=8.0258;
            dE_dTx=0.0276;
            Kx=0.0018;
            Ax=0.3592;
            alphax=1.0099e+03;
            betax=647.1063;

        case '11.1V  6600mAh  (LiCoO2)'

            PreDeterminedDischarge=0;

            NomV=11;
            NomQ=6.6;
            MaxQ=6.7;
            MinV=NomV*0.75;
            FullV=12.1;
            Dis_rate=1.32;
            R=1.59E-02;
            Normal_OP=5.5;
            expZone=[11.85,0.5];

            NomT=21;
            T2=-10;
            MaxQ2=6.48;
            FullV2=11.28;
            Normal_OP2=9.37;
            ExpZone2=[11,0.07];
            Rca=1.2;
            ti=1000;
            Dp=0;

            E0x=11.6237;
            dE_dTx=0.0294;
            Kx=0.0095;
            Ax=0.4803;
            alphax=3.3430e+03;
            betax=1.4968e+03;

        case '12.8V  40Ah  (LiFeMgPO4)'

            PreDeterminedDischarge=0;

            NomV=12.6;
            NomQ=40;
            MaxQ=40;
            MinV=10.5;
            FullV=13.8;
            Dis_rate=20;
            R=0.015;
            Normal_OP=30.14;
            expZone=[13.1,0.5];

            NomT=20;
            T2=0;
            MaxQ2=36;
            FullV2=13;
            Normal_OP2=11.7;
            ExpZone2=[12.67,4];
            Rca=0.6411;
            ti=4880;
            Dp=0;

            E0x=13.4448;
            dE_dTx=1.3420e-04;
            Kx=0.0041;
            Ax=0.3564;
            alphax=1.5463e+03;
            betax=3.0971e+03;

        end

        switch ThermalPreset
        case 'no'
            if OptimizationToolbox==0


                SimulateTemperature=0;

                warndlg('The Optimization Toolbox appears to not be installed. Therefore, you need to use a preset battery if you want to model temperature effects .');
            end

        otherwise

            UseThermalPreset=1;



            set_param(block,'NomV',num2str(NomV))
            set_param(block,'NomQ',num2str(NomQ))

            set_param(block,'PresetModel','off')

            set_param(block,'MaxQ',num2str(MaxQ))
            set_param(block,'MinV',num2str(MinV))
            set_param(block,'FullV',num2str(FullV))
            set_param(block,'Dis_rate',num2str(Dis_rate))
            set_param(block,'R',num2str(R))
            set_param(block,'Normal_OP',num2str(Normal_OP))
            set_param(block,'expZone',['[',num2str(expZone),']'])

            set_param(block,'NomT',num2str(NomT))
            set_param(block,'T2',num2str(T2))
            set_param(block,'MaxQ2',num2str(MaxQ2))
            set_param(block,'FullV2',num2str(FullV2))
            set_param(block,'Normal_OP2',num2str(Normal_OP2))
            set_param(block,'ExpZone2',['[',num2str(ExpZone2),']'])
            set_param(block,'Rca',num2str(Rca))
            set_param(block,'ti',num2str(ti))
            set_param(block,'Dp',num2str(Dp))



            set_param(block,'NomV',num2str(NomV))
            set_param(block,'NomQ',num2str(NomQ))

            set_param(block,'PresetModel','off')

            set_param(block,'MaxQ',num2str(MaxQ))
            set_param(block,'MinV',num2str(MinV))
            set_param(block,'FullV',num2str(FullV))
            set_param(block,'Dis_rate',num2str(Dis_rate))
            set_param(block,'R',num2str(R))
            set_param(block,'Normal_OP',num2str(Normal_OP))
            set_param(block,'expZone',['[',num2str(expZone),']'])

            set_param(block,'NomT',num2str(NomT))
            set_param(block,'T2',num2str(T2))
            set_param(block,'MaxQ2',num2str(MaxQ2))
            set_param(block,'FullV2',num2str(FullV2))
            set_param(block,'Normal_OP2',num2str(Normal_OP2))
            set_param(block,'ExpZone2',['[',num2str(ExpZone2),']'])
            set_param(block,'Rca',num2str(Rca))
            set_param(block,'ti',num2str(ti))
            set_param(block,'Dp',num2str(Dp))
        end

    end

    if SimulateTemperature
        Batt.sel_T=1;
    else
        Batt.sel_T=0;
    end

    if SimulateAging
        Batt.sel_A=1;
    else
        Batt.sel_A=0;
    end

    BatteryCback(block,1,PreDeterminedDischarge);



    if PreDeterminedDischarge

        switch get_param(block,'BatType')

        case 'Lead-Acid'
            MaxQ=NomQ*7.5/7.2;
            FullV_def=13.24/12.16*100;
            Dis_rate_def=20;
            Normal_OP_def=2.234/7.2*100;
            expZone_def=[12.38/12.16,0.024/7.2]*100;
            R=NomV/(NomQ*100);

        case 'Lithium-Ion'
            MaxQ=NomQ;
            FullV_def=3.62/3.11*100;
            Dis_rate_def=1/2.3*100;
            Normal_OP_def=2.08/2.3*100;
            expZone_def=[3.36/3.11,0.113/2.3]*100;
            R=NomV/(NomQ*100);

        case 'Nickel-Cadmium'
            MaxQ=NomQ*5/4.4;
            FullV_def=1.365/1.193*100;
            Dis_rate_def=20;
            Normal_OP_def=4.23/4.4*100;
            expZone_def=[1.273/1.193,1.23/4.4]*100;
            R=NomV/(NomQ*100);

        case 'Nickel-Metal-Hydride'
            MaxQ=NomQ*7/6.5;
            FullV_def=1.39/1.18*100;
            Dis_rate_def=20;
            Normal_OP_def=6.25/6.5*100;
            expZone_def=[1.28/1.18*100,1.3/6.5*100];
            R=NomV/(NomQ*100);

        end

        FullV=FullV_def*NomV/100;
        MinV=NomV*0.75;
        Dis_rate=Dis_rate_def*NomQ/100;
        Normal_OP=Normal_OP_def*NomQ/100;
        expZone=expZone_def.*[NomV,NomQ]/100;

        if isequal('stopped',get_param(bdroot(block),'SimulationStatus'))
            set_param(block,'MaxQ',num2str(MaxQ))
            set_param(block,'FullV',num2str(FullV))
            set_param(block,'MinV',num2str(MinV))
            set_param(block,'Dis_rate',num2str(Dis_rate))
            set_param(block,'R',num2str(R))
            set_param(block,'Normal_OP',num2str(Normal_OP))
            set_param(block,'expZone',['[',num2str(expZone),']'])
        end

    end

    if isequal('stopped',get_param(bdroot(block),'SimulationStatus'))
        MinVc=getSPSmaskvalues(block,{'MinV'});
        if MinVc<NomV*0.5
            set_param(block,'MinV',num2str(NomV*0.75))

        end
    end




    Va=FullV;
    Vb=expZone(1);
    Vc=NomV;
    Qb=expZone(2);
    Qc=Normal_OP;
    i=Dis_rate;

    Batt.B=3/Qb;
    V=[Va;Vb;Vc];
    Vcutoff=MinV;

    [E0,K,A,lambda,tol]=batteryparameters(V,Qb,Qc,MaxQ,i,R,Batt.B,Vcutoff);

    Batt.E0=E0;
    Batt.K=K;
    Batt.A=A;
    Batt.R=R;
    Batt.C=0;
    Batt.lambda=lambda;
    Batt.tol=tol;
    Batt.Q=MaxQ*lambda;


    if SimulateAging

        Batt.Neq0=getSPSmaskvalues(block,{'Neq0'});
        Batt.Tsim=getSPSmaskvalues(block,{'Tsim'});
        Batt.Tref=getSPSmaskvalues(block,{'Ta1'})+273.15;
        Batt.Qeol=getSPSmaskvalues(block,{'Qeol'});
        Batt.Reol=getSPSmaskvalues(block,{'Reol'});
        Char_age=getSPSmaskvalues(block,{'Char_age'});
        Dis_age=getSPSmaskvalues(block,{'Dis_age'});
        Batt.N1=getSPSmaskvalues(block,{'N1'});
        N2=getSPSmaskvalues(block,{'N2'});
        N3=getSPSmaskvalues(block,{'N3'});
        N4=getSPSmaskvalues(block,{'N4'});
        N5=getSPSmaskvalues(block,{'N5'});
        Ta2=getSPSmaskvalues(block,{'Ta2'});


        if~StoppedSimulation



            if any(size(Char_age)~=[1,2])
                error(message('physmod:powersys:common:InvalidVectorParameter','Charge current (nominal, maximum)',block,1,2));
            end
            if any(size(Dis_age)~=[1,2])
                error(message('physmod:powersys:common:InvalidVectorParameter','Discharge current (nominal, maximum)',block,1,2));
            end



            if Batt.Neq0<0
                error(message('physmod:powersys:common:GreaterThanOrEqualTo',block,'Initial battery age (Equivalent full cycles)','0'));
            end

            if Batt.Tsim<=0
                error(message('physmod:powersys:common:GreaterThan',block,'Aging model sampling time','0'));
            end

            if Batt.Qeol<=0
                error(message('physmod:powersys:common:GreaterThan',block,'Capacity at EOL','0'));
            end

            if Char_age(2)<=Char_age(1)
                error(message('physmod:powersys:common:GreaterThan',block,'Maximum charge current Icmax','Nominal charge current Ic'));
            end

            if Dis_age(2)<=Dis_age(1)
                error(message('physmod:powersys:common:GreaterThan',block,'Maximum discharge current Idmax','Nominal discharge current Id'));
            end

            if Batt.N1<0
                error(message('physmod:powersys:common:GreaterThanOrEqualTo',block,'Cycle life at 100 % DOD, Ic and Id','0'));
            end

            if N2<0
                error(message('physmod:powersys:common:GreaterThanOrEqualTo',block,'Cycle life at 25 % DOD, Ic and Id','0'));
            end

            if N3<0
                error(message('physmod:powersys:common:GreaterThanOrEqualTo',block,'Cycle life at 100 % DOD, Ic and Idmax','0'));
            end

            if N4<0
                error(message('physmod:powersys:common:GreaterThanOrEqualTo',block,'Cycle life at 100 % DOD, Icmax and Id','0'));
            end

            if N2<=Batt.N1
                error(message('physmod:powersys:common:GreaterThan',block,'Cycle life at 25 % DOD, Ic and Id','Cycle life at 100 % DOD, Ic and Id'));
            end

        end

        Ta2=Ta2+273.15;
        Icnom=Char_age(1);
        Icmax=Char_age(2);
        Idnom=Dis_age(1);
        Idmax=Dis_age(2);



        zeta=-(log(N2/Batt.N1))/log(0.25);
        phi=log(N5/Batt.N1)/((1/Ta2)-(1/Batt.Tref));
        gamma1=-(log(N3/Batt.N1))/log(Idmax/Idnom);
        gamma2=-(log(N4/Batt.N1))/log(Icmax/Icnom);
        H=Batt.N1/(Idnom^(-gamma1)*Icnom^(-gamma2));

        Epsi0=0;
        for j=1:1:Batt.Neq0
            Epsi0=Epsi0+(1/Batt.N1);
        end

        Batt.zeta=zeta;
        Batt.phi=phi;
        Batt.gamma1=gamma1;
        Batt.gamma2=gamma2;
        Batt.H=H;
        Batt.Epsi0=Epsi0;
    end


    if~SimulateAging
        Batt.Tsim=1e6;
    end




    Va2=getSPSmaskvalues(block,{'FullV2'});

    NomT=getSPSmaskvalues(block,{'NomT'});
    Batt.NomT=NomT+273.15;

    T2=getSPSmaskvalues(block,{'T2'});
    Batt.T2=T2+273.15;
    Batt.Ta=Batt.NomT-273.15;

    Batt.Rth=getSPSmaskvalues(block,{'Rca'});
    Batt.tc=getSPSmaskvalues(block,{'ti'});
    Batt.Tci=getSPSmaskvalues(block,{'Tci'})+273.15;
    Batt.DeltaP=getSPSmaskvalues(block,{'Dp'});
    Batt.Va=Va;
    Batt.Qmax=Batt.Q;




    if SimulateTemperature

        MaxQ2=getSPSmaskvalues(block,{'MaxQ2'});
        Vc2=getSPSmaskvalues(block,{'Normal_OP2'});
        expZone2=getSPSmaskvalues(block,{'expZone2'});

        i2=i;
        Qc2=MaxQ2*0.9;
        Vb2=expZone2(1);
        Qb2=expZone2(2);

        Batt.dQ_dT=(MaxQ2-MaxQ)/(Batt.T2-Batt.NomT);



        t11=Qb*3600/i;
        t12=Qc*3600/i;
        t21=Qb2*3600/i2;
        t22=Qc2*3600/i2;

        Batt.p=(Vb-Vc)/(Qb-Qc);

        if(Batt.p<=-0.125)

            Batt.C=abs(Batt.p);
        end


        E00=max(Va,Batt.E0);
        dE_dT0=max(1e-3,(Va2-Va)/(Batt.T2-Batt.NomT));
        K0=max(1e-3,Batt.K);
        A0=max(1e-3,Batt.A);
        alpha0=1000;
        beta0=1000;
        Batt.Qmax=max(NomQ,Batt.Q);

        Qmax=[MaxQ,MaxQ2]*Batt.lambda;
        Vx=[Va,Vb,Vc,Va2,Vb2,Vc2];
        Qx=[Qb,Qc,Qb2,Qc2];
        timeT=[t11,t12,t21,t22];
        I=[i,i2];
        Tamb=[Batt.NomT,Batt.T2];

        Tol=1e-1;
        maxNbIter=100;
        stopIfFound=true;

        X0=[E00,dE_dT0,K0,A0,alpha0,beta0];
        lb=X0/1000;
        ub=X0*1000;
        x0=X0;


        SolFound=false;
        minMaxError=1;
        bestParams=zeros(1,6);

        if OptimizationToolbox

            for k=1:maxNbIter

                f=@(x)optim(x,Vx,Qx,timeT,R,I,Qmax,Batt.Rth,Batt.tc,Tamb,Batt.C,MaxQ2,Vcutoff);
                options=optimset('LargeScale','on','Display','off','MaxFunEvals',1000,'MaxIter',100);

                [x,~,Residual,exitflag]=lsqnonlin(f,x0,lb,ub,options);

                Res=abs(Residual);

                E0x=x(1);
                dE_dTx=x(2);
                Kx=x(3);
                Ax=x(4);
                alphax=x(5);
                betax=x(6);
                maxRes=max(Res);

                if((exitflag>0)&&(maxRes<Tol))
                    MaxError=maxRes;
                    SolFound=true;
                    if stopIfFound==1
                        break
                    else
                        if maxRes<minMaxError
                            minMaxError=maxRes;
                            bestParams=[E0x,dE_dTx,Kx,Ax,alphax,betax];
                        end
                    end
                else
                    if maxRes<minMaxError
                        minMaxError=maxRes;
                        bestParams=[E0x,dE_dTx,Kx,Ax,alphax,betax];
                    end
                end
            end




            Batt.solutionFound=SolFound;

            if SolFound&&stopIfFound==1
                Batt.E0x=E0x;
                Batt.dE_dTx=dE_dTx;
                Batt.Kx=Kx;
                Batt.Ax=Ax;
                Batt.alphax=alphax;
                Batt.betax=betax;
                Batt.maxError=MaxError;
            else
                Batt.E0x=bestParams(1);
                Batt.dE_dTx=bestParams(2);
                Batt.Kx=bestParams(3);
                Batt.Ax=bestParams(4);
                Batt.alphax=bestParams(5);
                Batt.betax=bestParams(6);
                Batt.maxError=minMaxError;
            end
        end

        if UseThermalPreset
            Batt.E0=E0x;
            Batt.dE_dT=dE_dTx;
            Batt.K=Kx;
            Batt.A=Ax;
            Batt.alpha=alphax;
            Batt.beta=betax;
        else
            Batt.E0=Batt.E0x;
            Batt.dE_dT=Batt.dE_dTx;
            Batt.K=Batt.Kx;
            Batt.A=Batt.Ax;
            Batt.alpha=Batt.alphax;
            Batt.beta=Batt.betax;
        end

    else

        Batt.E0x=Batt.E0;
        Batt.dE_dTx=(Va2-Va)/(Batt.T2-Batt.NomT);
        Batt.Kx=Batt.K;
        Batt.Ax=Batt.A;
        Batt.alphax=100;
        Batt.betax=100;
        Batt.maxError=[];

    end

    switch get_param(block,'BatType')
    case 'Lead-Acid'
        Batt.kc=0.1;
        Batt.kcsat=0.1;
    case 'Lithium-Ion'
        Batt.kc=0.1;
        Batt.kcsat=0.1;
    case 'Nickel-Cadmium'
        Batt.kc=0.1;
        Batt.kcsat=inf;
    case 'Nickel-Metal-Hydride'
        Batt.kc=0.1;
        Batt.kcsat=inf;
    end



    if DisplayPlot&&StoppedSimulation

        Exp_V=expZone(1);
        Exp_Q=expZone(2);
        i=Dis_rate;

        M1=Batt.Q*0.999;
        M2=Normal_OP;
        M3=Exp_Q;

        Units=get_param(block,'Units');

        if strcmp(Units,'Ampere-hour')
            scale_x=1;
            label='Ampere-hour (Ah)';
        else
            if M1*1/i>1.05
                scale_x=1/i;
                label='Time (hours)';
            else
                scale_x=1/i*60;
                label='Time (Minutes)';
            end
        end

        hfig=findobj('Name','Battery Discharge Characteristic');

        if isempty(hfig)
            figure('Name','Battery Discharge Characteristic');
        end
        subplot(2,1,1);


        Ah1=0:M1/100:M1;
        E=Batt.E0-Batt.K*(i+Ah1).*Batt.Q./(Batt.Q-Ah1)-Batt.R*i+Batt.A*exp(-Batt.B*Ah1);
        plot(Ah1*scale_x,E);
        hold on


        Ah2=0:M2/100:M2;
        E=Batt.E0-Batt.K*(i+Ah2)*Batt.Q./(Batt.Q-Ah2)-Batt.R*i+Batt.A*exp(-Batt.B*Ah2);
        fill([0,Ah2*scale_x,M2*scale_x],[0,E,0],[1,1,1]*200/255,'FaceAlpha',0.5);


        if Exp_Q~=0
            Ah3=0:M3/100:M3;
            E=Batt.E0-Batt.K*(i+Ah3)*Batt.Q./(Batt.Q-Ah3)-Batt.R*i+Batt.A*exp(-Batt.B*Ah3);
            fill([0,Ah3*scale_x,M3*scale_x],[Exp_V,E,Exp_V],[1,1,0],'FaceAlpha',0.5);
        end

        axis([0,max(Ah1*scale_x)*1.5,NomV*0.7,max(E)*1.1]);
        title(['Nominal Current Discharge Characteristic at ',num2str(Dis_rate/NomQ),'C (',num2str(i),'A)']);
        xlabel(label);
        ylabel('Voltage');
        grid on
        hold off
        legend('Discharge curve','Nominal area','Exponential area');

        subplot(2,1,2)

        current=getSPSmaskvalues(block,{'current'});

        legend_str=cell(1,length(current));
        scale_x=ones(1,length(current));

        for idx=1:length(current)
            i=current(idx);
            legend_str{idx}=[num2str(i),' A'];
            if strcmp(Units,'Ampere-hour')
                scale_x(idx)=1;
                label='Ampere-hour (Ah)';
            else
                if M1*max(1./current)>1.2
                    scale_x(idx)=1/i;
                    label='Time (hours)';
                else
                    scale_x(idx)=1/i*60;
                    label='Time (Minutes)';
                end
            end
            Ah=0:M1/100:M1;
            E(idx,:)=Batt.E0-Batt.K*(i+Ah)*Batt.Q./(Batt.Q-Ah)-Batt.R*i+Batt.A*exp(-Batt.B*Ah);
        end

        plot(Ah'*scale_x,E');
        legend(legend_str);
        axis([0,M1*max(scale_x)*1.5,min(E(:,1))*0.7,max(max(E))*1.1]);
        title(['E0 = ',num2str(Batt.E0),', R = ',num2str(Batt.R),', K = ',num2str(Batt.K),', A = ',num2str(Batt.A),', B = ',num2str(Batt.B)]);
        xlabel(label);
        ylabel('Voltage');
        grid on
        hold off

    end



    BT.X=[-70,30];
    BT.bas=-60;
    BT.haut=40;
    BT.dim_Xsin=BT.X(1):1:BT.X(2);
    BT.dim_sin=0:pi/2/((-BT.X(1)+BT.X(2))/2):2*pi/2;
    BT.TopX=[-30,-10];
    BT.dim_Xtop=BT.TopX(1):1:BT.TopX(2);
    BT.dim_top=0:pi/2/((-BT.TopX(1)+BT.TopX(2))/2):2*pi/2;

    [X1,X1m,X2,X2m,X3,X4,Y1,Y1m,Y2,Y2m,Y3,Y4,BT.color1,BT.color2]=spsdrivelogo;

    scale=160;
    BT.dx=0.6;
    BT.dy=0.7;
    BT.X1=(X1-BT.dx)*scale;
    BT.X1m=(X1m-BT.dx)*scale;
    BT.X2=(X2-BT.dx)*scale;
    BT.X2m=(X2m-BT.dx)*scale;
    BT.X3=(X3-BT.dx)*scale;
    BT.X4=(X4-BT.dx)*scale;
    BT.Y1=(Y1-BT.dy)*scale;
    BT.Y1m=(Y1m-BT.dy)*scale;
    BT.Y2=(Y2-BT.dy)*scale;
    BT.Y2m=(Y2m-BT.dy)*scale;
    BT.Y3=(Y3-BT.dy)*scale;
    BT.Y4=(Y4-BT.dy)*scale;


    sys=bdroot(block);
    PowerguiInfo=powericon('getPowerguiInfo',sys,block);
    Ts=PowerguiInfo.Ts;
    WantDiscreteModel=PowerguiInfo.Discrete;
    if WantDiscreteModel
        WantBlockChoice='Discrete';
    else
        WantBlockChoice='Continuous';
    end
    if SimulateTemperature
        WantBlockChoice=[WantBlockChoice,' thermal'];
    end
    if SimulateAging
        WantBlockChoice=[WantBlockChoice,' aging'];
    end
    NotAllowedForPhasorSimulation(PowerguiInfo.Phasor||PowerguiInfo.DiscretePhasor,block,'Battery');

    function F=optim(x,V,Q,timeT,R,I,Qmax,Rth,thau,Tamb,C,Q23,V23)

        E0x=x(1);
        dE_dTx=x(2);
        Kx=max(x(3),1e-4);
        Ax=x(4);
        alphax=x(5);
        betax=x(6);
        V01=V(1);
        V11=V(2);
        V12=V(3);
        V02=V(4);
        V21=V(5);
        V22=V(6);
        i1=I(1);
        i2=I(2);
        Qmax1=Qmax(1);
        Qmax2=Qmax(2);
        Q11=Q(1);
        Q12=Q(2);
        Q21=Q(3);
        Q22=Q(4);
        B=3/Q11;

        t11=timeT(1);
        t12=timeT(2);
        t21=timeT(3);
        t22=timeT(4);
        t23=Q23*3600/i1;
        Tamb1=Tamb(1);
        Tamb2=Tamb(2);
        Tc01=Tamb1;
        Tc02=Tamb2;



        Tc11=max(Tamb1,(((E0x-dE_dTx*Tamb1-V11)*i1*Rth+Tamb1)*(1-exp((-1/thau)*t11))+Tc01*exp((-1/thau)*t11))/(1-2*(1-exp((-1/thau)*t11))*dE_dTx*i1*Rth));
        Tc12=max(Tc11,(((E0x-dE_dTx*Tamb1-V12)*i1*Rth+Tamb1)*(1-exp((-1/thau)*t12))+Tc01*exp((-1/thau)*t12))/(1-2*(1-exp((-1/thau)*t12))*dE_dTx*i1*Rth));
        Tc21=max(Tamb2,(((E0x-dE_dTx*Tamb1-V21)*i2*Rth+Tamb2)*(1-exp((-1/thau)*t21))+Tc02*exp((-1/thau)*t21))/(1-2*(1-exp((-1/thau)*t21))*dE_dTx*i2*Rth));
        Tc22=max(Tc21,(((E0x-dE_dTx*Tamb1-V22)*i2*Rth+Tamb2)*(1-exp((-1/thau)*t22))+Tc02*exp((-1/thau)*t22))/(1-2*(1-exp((-1/thau)*t22))*dE_dTx*i2*Rth));
        Tc23=max(Tc22,(((E0x-dE_dTx*Tamb1-V23)*i2*Rth+Tamb2)*(1-exp((-1/thau)*t23))+Tc02*exp((-1/thau)*t23))/(1-2*(1-exp((-1/thau)*t23))*dE_dTx*i2*Rth));

        V01_est=E0x+Ax;
        V11_est=E0x+dE_dTx*(Tc11-Tamb1)-R*exp(betax*((1/Tc11)-(1/Tamb1)))*i1-Kx*exp(alphax*((1/Tc11)-(1/Tamb1)))*(i1+Q11)*Qmax1/(Qmax1-Q11)+Ax*exp(-B*Q11)-C*Q11;
        V12_est=E0x+dE_dTx*(Tc12-Tamb1)-R*exp(betax*((1/Tc12)-(1/Tamb1)))*i1-Kx*exp(alphax*((1/Tc12)-(1/Tamb1)))*(i1+Q12)*Qmax1/(Qmax1-Q12)+Ax*exp(-B*Q12)-C*Q12;
        V21_est=E0x+dE_dTx*(Tc21-Tamb1)-R*exp(betax*((1/Tc21)-(1/Tamb1)))*i2-Kx*exp(alphax*((1/Tc21)-(1/Tamb1)))*(i2+Q21)*Qmax2/(Qmax2-Q21)+Ax*exp(-B*Q21)-C*Q21;
        V22_est=E0x+dE_dTx*(Tc22-Tamb1)-R*exp(betax*((1/Tc22)-(1/Tamb1)))*i2-Kx*exp(alphax*((1/Tc22)-(1/Tamb1)))*(i2+Q22)*Qmax2/(Qmax2-Q22)+Ax*exp(-B*Q22)-C*Q22;
        V23_est=E0x+dE_dTx*(Tc23-Tamb1)-R*exp(betax*((1/Tc23)-(1/Tamb1)))*i2-Kx*exp(alphax*((1/Tc23)-(1/Tamb1)))*(i2+Q23)*Qmax2/(Qmax2-Q23)+Ax*exp(-B*Q23)-C*Q23;

        F=[(V01_est-V01)/V01,(V11_est-V11)/V11,(V12_est-V12)/V12,(V21_est-V21)/V21,(V22_est-V22)/V22,(V23_est-V23)/V23,];


        function[E0,K,A,lambda,tol]=batteryparameters(V,Qb,Qc,Q,idis,R,B,Vcutoff)

            lambda=1.01;
            max_iteration=100;
            for i=1:max_iteration

                M=[1,0,1;1,-(idis+Qb)*lambda*Q/(lambda*Q-Qb),exp(-B*Qb);1,-(idis+Qc)*lambda*Q/(lambda*Q-Qc),exp(-B*Qc)];
                X=M\(V+R*idis);
                E0=X(1);
                K=X(2);
                A=X(3);
                Vend=E0-R*idis-K*(idis+Q)*lambda*Q/(lambda*Q-Q)+A*exp(-B*Q);
                tol=Vcutoff-Vend;
                if(abs(tol)<=0.01||Vend>Vcutoff)
                    break;
                else
                    lambda=lambda+0.001;
                end
            end

            function NotAllowedForPhasorSimulation(Mode,BlockName,Type)





                if Mode
                    message=['The following block is not supported in Phasor simulation method:',...
                    newline,...
                    'Block : ',strrep(BlockName,newline,' '),...
                    newline,...
                    'Type  : ',Type];
                    Erreur.message=char(message);
                    Erreur.identifier='SpecializedPowerSystems:NotAllowedForPhasorSimulation';
                    psberror(Erreur);
                end