function[position,velocity]=propagate(tleStruct,time)%#codegen











    coder.allowpcode('plain');

    if isempty(coder.target)
        time.TimeZone='';
        tleStruct.Epoch.TimeZone='';
        [position,velocity]=matlabshared.orbit.internal.SDP4.cg_propagate(tleStruct,time);
        return
    end


    numSamples=numel(time);


    position=zeros(3,numSamples);
    velocity=zeros(3,numSamples);

    for idx=1:numSamples

        XMO=tleStruct.MeanAnomaly;
        XNODEO=tleStruct.RightAscensionOfAscendingNode;
        OMEGAO=tleStruct.ArgumentOfPeriapsis;
        EO=tleStruct.Eccentricity;

        if EO==0
            EO=eps;
        end
        XINCL=tleStruct.Inclination;

        if XINCL==0
            XINCL=eps;
        end
        XNO=tleStruct.MeanMotion*60;
        BSTAR=tleStruct.BStar;
        epochAsDateTime=tleStruct.Epoch;






        epochYear=epochAsDateTime.Year;
        epochMonth=epochAsDateTime.Month;
        epochDay=epochAsDateTime.Day;
        epochHour=epochAsDateTime.Hour;
        epochMinute=epochAsDateTime.Minute;
        epochSecond=epochAsDateTime.Second;


        epochDayNumber=hDayOfYear(epochYear,epochMonth,epochDay);


        epochSecondofday=(epochHour*3600)+(epochMinute*60)+epochSecond;
        totalSecondsInDay=24*3600;
        epochFractionalDay=epochSecondofday/totalSecondsInDay;


        epochDay=epochDayNumber+epochFractionalDay;


        EPOCH=(mod(epochYear,100)*1000)+epochDay;


        TSINCE=real(minutes(time(idx)-epochAsDateTime));


        E6A=1.0e-6;
        S=matlabshared.orbit.internal.GeneralPerturbations.pDensityFunctionParameter1;
        QOMS2T=matlabshared.orbit.internal.GeneralPerturbations.pDensityFunctionParameter2;
        TOTHRD=2/3;
        XKE=matlabshared.orbit.internal.GeneralPerturbations.pNormalizedStandardGravitationalParameter;
        XKMPER=matlabshared.orbit.internal.GeneralPerturbations.pEarthRadiusGP/1000;
        AE=1.0;
        PI=pi;
        XJ2=matlabshared.orbit.internal.GeneralPerturbations.pJ2;
        XJ3=matlabshared.orbit.internal.GeneralPerturbations.pJ3;
        XJ4=matlabshared.orbit.internal.GeneralPerturbations.pJ4;
        CK2=0.5*XJ2*(AE^2);
        CK4=-(0.375*XJ4*(AE^4));

        A1=(XKE/XNO)^TOTHRD;
        COSIO=cos(XINCL);
        THETA2=COSIO*COSIO;
        X3THM1=3*THETA2-1;
        EOSQ=EO*EO;
        BETAO2=1-EOSQ;
        BETAO=sqrt(BETAO2);
        DEL1=1.5*CK2*X3THM1/(A1*A1*BETAO*BETAO2);
        AO=A1*(1-DEL1*(0.5*TOTHRD+DEL1*(1+134/81*DEL1)));
        DELO=1.5*CK2*X3THM1/(AO*AO*BETAO*BETAO2);
        XNODP=XNO/(1+DELO);
        AODP=AO/(1-DELO);


        S4=S;
        QOMS24=QOMS2T;
        PERIGE=(AODP*(1-EO)-AE)*XKMPER;

        if(PERIGE<156)
            S4=PERIGE-78;
            if(PERIGE<=98.)
                S4=20;
            end
            QOMS24=((120-S4)*AE/XKMPER)^4;
            S4=S4/XKMPER+AE;
        end

        PINVSQ=1/(AODP*AODP*BETAO2*BETAO2);
        SING=sin(OMEGAO);
        COSG=cos(OMEGAO);
        TSI=1/(AODP-S4);
        ETA=AODP*EO*TSI;
        ETASQ=ETA*ETA;
        EETA=EO*ETA;
        PSISQ=abs(1-ETASQ);
        COEF=QOMS24*TSI^4;
        COEF1=COEF/PSISQ^3.5;
        C2=COEF1*XNODP*(AODP*(1+1.5*ETASQ+EETA*(4+ETASQ))+0.75*...
        CK2*TSI/PSISQ*X3THM1*(8+3*ETASQ*(8+ETASQ)));
        C1=BSTAR*C2;
        SINIO=sin(XINCL);
        A3OVK2=-XJ3/CK2*AE^3;
        X1MTH2=1-THETA2;
        C4=2*XNODP*COEF1*AODP*BETAO2*(ETA*...
        (2+0.5*ETASQ)+EO*(0.5+2*ETASQ)-2*CK2*TSI/...
        (AODP*PSISQ)*(-3*X3THM1*(1-2*EETA+ETASQ*...
        (1.5-0.5*EETA))+0.75*X1MTH2*(2*ETASQ-EETA*...
        (1+ETASQ))*cos(2*OMEGAO)));
        THETA4=THETA2*THETA2;
        TEMP1=3*CK2*PINVSQ*XNODP;
        TEMP2=TEMP1*CK2*PINVSQ;
        TEMP3=1.25*CK4*PINVSQ*PINVSQ*XNODP;
        XMDOT=XNODP+0.5*TEMP1*BETAO*X3THM1+0.0625*TEMP2*BETAO*...
        (13-78*THETA2+137*THETA4);
        X1M5TH=1-5*THETA2;
        OMGDOT=-0.5*TEMP1*X1M5TH+0.0625*TEMP2*(7-114.*THETA2+...
        395*THETA4)+TEMP3*(3-36*THETA2+49*THETA4);
        XHDOT1=-TEMP1*COSIO;
        XNODOT=XHDOT1+(0.5*TEMP2*(4-19*THETA2)+2*TEMP3*(3-...
        7*THETA2))*COSIO;
        XNODCF=3.5*BETAO2*XHDOT1*C1;
        T2COF=1.5*C1;
        XLCOF=0.125*A3OVK2*SINIO*(3+5*COSIO)/(1+COSIO);
        AYCOF=0.25*A3OVK2*SINIO;
        X7THM1=7*THETA2-1;


        ZNS=1.19459E-5;
        C1SS=2.9864797E-6;
        ZES=0.01675;
        ZNL=1.5835218E-4;
        C1L=4.7968065E-7;
        ZEL=0.05490;
        ZCOSIS=0.91744867;
        ZSINIS=0.39785416;
        ZSINGS=-0.98088458;
        ZCOSGS=0.1945905;
        Q22=1.7891679E-6;
        Q31=2.1460748E-6;
        Q33=2.2123015E-7;
        G22=5.7686396;
        G32=0.95240898;
        G44=1.8014998;
        G52=1.0508330;
        G54=4.4108898;
        ROOT22=1.7891679E-6;
        ROOT32=3.7393792E-7;
        ROOT44=7.3636953E-9;
        ROOT52=1.1428639E-7;
        ROOT54=2.1765803E-9;
        THDT=4.3752691E-3;

        EQSQ=EOSQ;
        SINIQ=SINIO;
        COSIQ=COSIO;
        RTEQSQ=BETAO;
        AO=AODP;
        COSQ2=THETA2;
        SINOMO=SING;
        COSOMO=COSG;
        BSQ=BETAO2;
        XLLDOT=XMDOT;
        OMGDT=OMGDOT;


        TWOPI=2*pi;
        YR=(EPOCH+2e-7)*1e-3;
        JY=floor(YR);
        YR=JY;
        D=EPOCH-YR*1E3;

        if(JY<10)
            JY=JY+80;
        end

        N=floor((JY-69)/4);

        if(JY<70)
            N=floor((JY-72)/4);
        end

        DS50=7305+365*(JY-70)+N+D;
        THETA=1.72944494+6.3003880987*DS50;
        TEMP=THETA/TWOPI;
        I=floor(TEMP);
        TEMP=I;
        THETAG=THETA-TEMP*TWOPI;

        if(THETAG<0)
            THETAG=THETAG+TWOPI;
        end

        THGR=THETAG;
        EQ=EO;
        XNQ=XNODP;
        AQNV=1/AO;
        XQNCL=XINCL;
        XMAO=XMO;
        XPIDOT=OMGDT+XNODOT;
        SINQ=sin(XNODEO);
        COSQ=cos(XNODEO);
        OMEGAQ=OMEGAO;


        DAY=DS50+18261.5;
        PREEP=0;

        ZCOSGL=0;
        ZSINGL=1;
        ZCOSIL=0;
        ZSINIL=1;
        ZCOSHL=0;
        ZSINHL=1;
        ZMOS=0;
        ZMOL=0;
        if(DAY~=PREEP)
            XNODCE=4.5236020-9.2422029E-4*DAY;
            STEM=sin(XNODCE);
            CTEM=cos(XNODCE);
            ZCOSIL=0.91375164-0.03568096*CTEM;
            ZSINIL=sqrt(1-ZCOSIL*ZCOSIL);
            ZSINHL=0.089683511*STEM/ZSINIL;
            ZCOSHL=sqrt(1-ZSINHL*ZSINHL);
            C=4.7199672+0.22997150*DAY;
            GAM=5.8351514+0.0019443680*DAY;
            ZMOL=mod(C-GAM,2*pi);
            ZX=0.39785416*STEM/ZSINIL;
            ZY=ZCOSHL*CTEM+0.91744867*ZSINHL*STEM;
            ZX=matlabshared.orbit.internal.GeneralPerturbations.arctan(ZX,ZY);
            ZX=GAM+ZX-XNODCE;
            ZCOSGL=cos(ZX);
            ZSINGL=sin(ZX);
            ZMOS=6.2565837+0.017201977*DAY;
            ZMOS=mod(ZMOS,2*pi);
        end


        SAVTSN=1e20;
        ZCOSG=ZCOSGS;
        ZSING=ZSINGS;
        ZCOSI=ZCOSIS;
        ZSINI=ZSINIS;
        ZCOSH=COSQ;
        ZSINH=SINQ;
        CC=C1SS;
        ZN=ZNS;
        ZE=ZES;
        XNOI=1/XNQ;
        A1=ZCOSG*ZCOSH+ZSING*ZCOSI*ZSINH;
        A3=-ZSING*ZCOSH+ZCOSG*ZCOSI*ZSINH;
        A7=-ZCOSG*ZSINH+ZSING*ZCOSI*ZCOSH;
        A8=ZSING*ZSINI;
        A9=ZSING*ZSINH+ZCOSG*ZCOSI*ZCOSH;
        A10=ZCOSG*ZSINI;
        A2=COSIQ*A7+SINIQ*A8;
        A4=COSIQ*A9+SINIQ*A10;
        A5=-SINIQ*A7+COSIQ*A8;
        A6=-SINIQ*A9+COSIQ*A10;

        X1=A1*COSOMO+A2*SINOMO;
        X2=A3*COSOMO+A4*SINOMO;
        X3=-A1*SINOMO+A2*COSOMO;
        X4=-A3*SINOMO+A4*COSOMO;
        X5=A5*SINOMO;
        X6=A6*SINOMO;
        X7=A5*COSOMO;
        X8=A6*COSOMO;
        Z31=12*X1*X1-3*X3*X3;
        Z32=24*X1*X2-6*X3*X4;
        Z33=12*X2*X2-3*X4*X4;
        Z1=3*(A1*A1+A2*A2)+Z31*EQSQ;
        Z2=6*(A1*A3+A2*A4)+Z32*EQSQ;
        Z3=3*(A3*A3+A4*A4)+Z33*EQSQ;
        Z11=-6*A1*A5+EQSQ*(-24*X1*X7-6*X3*X5);
        Z12=-6*(A1*A6+A3*A5)+EQSQ*(-24*(X2*X7+X1*X8)-6*(X3*X6+X4*X5));
        Z13=-6*A3*A6+EQSQ*(-24*X2*X8-6*X4*X6);
        Z21=6*A2*A5+EQSQ*(24*X1*X5-6*X3*X7);
        Z22=6*(A4*A5+A2*A6)+EQSQ*(24*(X2*X5+X1*X6)-6*(X4*X7+X3*X8));
        Z23=6*A4*A6+EQSQ*(24*X2*X6-6*X4*X8);
        Z1=Z1+Z1+BSQ*Z31;
        Z2=Z2+Z2+BSQ*Z32;
        Z3=Z3+Z3+BSQ*Z33;
        S3=CC*XNOI;
        S2=-0.5*S3/RTEQSQ;
        S4=S3*RTEQSQ;
        S1=-15*EQ*S4;
        S5=X1*X3+X2*X4;
        S6=X2*X3+X1*X4;
        S7=X2*X4-X1*X3;
        SE=S1*ZN*S5;
        SI=S2*ZN*(Z11+Z13);
        SL=-ZN*S3*(Z1+Z3-14-6*EQSQ);
        SGH=S4*ZN*(Z31+Z33-6);
        SH=-ZN*S2*(Z21+Z23);

        if(XQNCL<5.2359877E-2)
            SH=0.0;
        end

        EE2=2*S1*S6;
        E3=2*S1*S7;
        XI2=2*S2*Z12;
        XI3=2*S2*(Z13-Z11);
        XL2=-2*S3*Z2;
        XL3=-2*S3*(Z3-Z1);
        XL4=-2*S3*(-21-9*EQSQ)*ZE;
        XGH2=2*S4*Z32;
        XGH3=2*S4*(Z33-Z31);
        XGH4=-18*S4*ZE;
        XH2=-2*S2*Z22;
        XH3=-2*S2*(Z23-Z21);


        SSE=SE;
        SSI=SI;
        SSL=SL;
        SSH=SH/SINIQ;
        SSG=SGH-COSIQ*SSH;
        SE2=EE2;
        SI2=XI2;
        SL2=XL2;
        SGH2=XGH2;
        SH2=XH2;
        SE3=E3;
        SI3=XI3;
        SL3=XL3;
        SGH3=XGH3;
        SH3=XH3;
        SL4=XL4;
        SGH4=XGH4;
        ZCOSG=ZCOSGL;
        ZSING=ZSINGL;
        ZCOSI=ZCOSIL;
        ZSINI=ZSINIL;
        ZCOSH=ZCOSHL*COSQ+ZSINHL*SINQ;
        ZSINH=SINQ*ZCOSHL-COSQ*ZSINHL;
        ZN=ZNL;
        CC=C1L;
        ZE=ZEL;
        A1=ZCOSG*ZCOSH+ZSING*ZCOSI*ZSINH;
        A3=-ZSING*ZCOSH+ZCOSG*ZCOSI*ZSINH;
        A7=-ZCOSG*ZSINH+ZSING*ZCOSI*ZCOSH;
        A8=ZSING*ZSINI;
        A9=ZSING*ZSINH+ZCOSG*ZCOSI*ZCOSH;
        A10=ZCOSG*ZSINI;
        A2=COSIQ*A7+SINIQ*A8;
        A4=COSIQ*A9+SINIQ*A10;
        A5=-SINIQ*A7+COSIQ*A8;
        A6=-SINIQ*A9+COSIQ*A10;
        X1=A1*COSOMO+A2*SINOMO;
        X2=A3*COSOMO+A4*SINOMO;
        X3=-A1*SINOMO+A2*COSOMO;
        X4=-A3*SINOMO+A4*COSOMO;
        X5=A5*SINOMO;
        X6=A6*SINOMO;
        X7=A5*COSOMO;
        X8=A6*COSOMO;
        Z31=12*X1*X1-3*X3*X3;
        Z32=24*X1*X2-6*X3*X4;
        Z33=12*X2*X2-3*X4*X4;
        Z1=3*(A1*A1+A2*A2)+Z31*EQSQ;
        Z2=6*(A1*A3+A2*A4)+Z32*EQSQ;
        Z3=3*(A3*A3+A4*A4)+Z33*EQSQ;
        Z11=-6*A1*A5+EQSQ*(-24*X1*X7-6*X3*X5);
        Z12=-6*(A1*A6+A3*A5)+EQSQ*(-24*(X2*X7+X1*X8)-6*(X3*X6+X4*X5));
        Z13=-6*A3*A6+EQSQ*(-24*X2*X8-6*X4*X6);
        Z21=6*A2*A5+EQSQ*(24*X1*X5-6*X3*X7);
        Z22=6*(A4*A5+A2*A6)+EQSQ*(24*(X2*X5+X1*X6)-6*(X4*X7+X3*X8));
        Z23=6*A4*A6+EQSQ*(24*X2*X6-6*X4*X8);
        Z1=Z1+Z1+BSQ*Z31;
        Z2=Z2+Z2+BSQ*Z32;
        Z3=Z3+Z3+BSQ*Z33;
        S3=CC*XNOI;
        S2=-0.5*S3/RTEQSQ;
        S4=S3*RTEQSQ;
        S1=-15*EQ*S4;
        S5=X1*X3+X2*X4;
        S6=X2*X3+X1*X4;
        S7=X2*X4-X1*X3;
        SE=S1*ZN*S5;
        SI=S2*ZN*(Z11+Z13);
        SL=-ZN*S3*(Z1+Z3-14-6*EQSQ);
        SGH=S4*ZN*(Z31+Z33-6);
        SH=-ZN*S2*(Z21+Z23);

        if(XQNCL<5.2359877E-2)
            SH=0.0;
        end

        EE2=2*S1*S6;
        E3=2*S1*S7;
        XI2=2*S2*Z12;
        XI3=2*S2*(Z13-Z11);
        XL2=-2*S3*Z2;
        XL3=-2*S3*(Z3-Z1);
        XL4=-2*S3*(-21-9*EQSQ)*ZE;
        XGH2=2*S4*Z32;
        XGH3=2*S4*(Z33-Z31);
        XGH4=-18*S4*ZE;
        XH2=-2*S2*Z22;
        XH3=-2*S2*(Z23-Z21);
        SSE=SSE+SE;
        SSI=SSI+SI;
        SSL=SSL+SL;
        SSG=SSG+SGH-COSIQ/SINIQ*SH;
        SSH=SSH+SH/SINIQ;


        IRESFL=0;
        ISYNFL=0;
        BFACT=0;
        XLAMO=0;
        FASX2=0;
        FASX4=0;
        FASX6=0;
        DEL2=0;
        DEL3=0;
        D2201=0;
        D2211=0;
        D3210=0;
        D3222=0;
        D4410=0;
        D4422=0;
        D5220=0;
        D5232=0;
        D5421=0;
        D5433=0;
        if~(XNQ<(0.0052359877)&&XNQ>(0.0034906585))
            if~(((XNQ<(8.26E-3)||XNQ>(9.24E-3)))&&(EQ<0.5))
                IRESFL=1;
                EOC=EQ*EQSQ;
                G201=-0.306-(EQ-0.64)*0.440;

                if~(EQ>(0.65))
                    G211=3.616-13.247*EQ+16.290*EQSQ;
                    G310=-19.302+117.390*EQ-228.419*EQSQ+156.591*EOC;
                    G322=-18.9068+109.7927*EQ-214.6334*EQSQ+146.5816*EOC;
                    G410=-41.122+242.694*EQ-471.094*EQSQ+313.953*EOC;
                    G422=-146.407+841.880*EQ-1629.014*EQSQ+1083.435*EOC;
                    G520=-532.114+3017.977*EQ-5740*EQSQ+3708.276*EOC;
                else
                    G211=-72.099+331.819*EQ-508.738*EQSQ+266.724*EOC;
                    G310=-346.844+1582.851*EQ-2415.925*EQSQ+1246.113*EOC;
                    G322=-342.585+1554.908*EQ-2366.899*EQSQ+1215.972*EOC;
                    G410=-1052.797+4758.686*EQ-7193.992*EQSQ+3651.957*EOC;
                    G422=-3581.69+16178.11*EQ-24462.77*EQSQ+12422.52*EOC;

                    if~(EQ>(0.715))
                        G520=1464.74-4664.75*EQ+3763.64*EQSQ;
                    else
                        G520=-5149.66+29936.92*EQ-54087.36*EQSQ+31324.56*EOC;
                    end
                end
                if~(EQ>=(0.7))
                    G533=-919.2277+4988.61*EQ-9064.77*EQSQ+5542.21*EOC;
                    G521=-822.71072+4568.6173*EQ-8491.4146*EQSQ+5337.524*EOC;
                    G532=-853.666+4690.25*EQ-8624.77*EQSQ+5341.4*EOC;
                else
                    G533=-37995.78+161616.52*EQ-229838.2*EQSQ+109377.94*EOC;
                    G521=-51752.104+218913.95*EQ-309468.16*EQSQ+146349.42*EOC;
                    G532=-40023.88+170470.89*EQ-242699.48*EQSQ+115605.82*EOC;
                end

                SINI2=SINIQ*SINIQ;
                F220=0.75*(1+2*COSIQ+COSQ2);
                F221=1.5*SINI2;
                F321=1.875*SINIQ*(1-2*COSIQ-3*COSQ2);
                F322=-1.875*SINIQ*(1+2*COSIQ-3*COSQ2);
                F441=35*SINI2*F220;
                F442=39.3750*SINI2*SINI2;
                F522=9.84375*SINIQ*(SINI2*(1-2*COSIQ-5*COSQ2)...
                +0.33333333*(-2+4*COSIQ+6*COSQ2));
                F523=SINIQ*(4.92187512*SINI2*(-2-4*COSIQ+10*COSQ2)...
                +6.56250012*(1+2*COSIQ-3*COSQ2));
                F542=29.53125*SINIQ*(2-8*COSIQ+COSQ2*(-12+8*COSIQ...
                +10.*COSQ2));
                F543=29.53125*SINIQ*(-2-8*COSIQ+COSQ2*(12+8*COSIQ-10*COSQ2));
                XNO2=XNQ*XNQ;
                AINV2=AQNV*AQNV;
                TEMP1=3*XNO2*AINV2;
                TEMP=TEMP1*ROOT22;
                D2201=TEMP*F220*G201;
                D2211=TEMP*F221*G211;
                TEMP1=TEMP1*AQNV;
                TEMP=TEMP1*ROOT32;
                D3210=TEMP*F321*G310;
                D3222=TEMP*F322*G322;
                TEMP1=TEMP1*AQNV;
                TEMP=2*TEMP1*ROOT44;
                D4410=TEMP*F441*G410;
                D4422=TEMP*F442*G422;
                TEMP1=TEMP1*AQNV;
                TEMP=TEMP1*ROOT52;
                D5220=TEMP*F522*G520;
                D5232=TEMP*F523*G532;
                TEMP=2*TEMP1*ROOT54;
                D5421=TEMP*F542*G521;
                D5433=TEMP*F543*G533;
                XLAMO=XMAO+XNODEO+XNODEO-THGR-THGR;
                BFACT=XLLDOT+XNODOT+XNODOT-THDT-THDT;
                BFACT=BFACT+SSL+SSH+SSH;
            end
        else

            IRESFL=1;
            ISYNFL=1;
            G200=1.0+EQSQ*(-2.5+0.8125*EQSQ);
            G310=1.0+2.0*EQSQ;
            G300=1.0+EQSQ*(-6.0+6.60937*EQSQ);
            F220=0.75*(1+COSIQ)*(1+COSIQ);
            F311=0.9375*SINIQ*SINIQ*(1+3*COSIQ)-0.75*(1+COSIQ);
            F330=1+COSIQ;
            F330=1.875*F330*F330*F330;
            DEL1=3*XNQ*XNQ*AQNV*AQNV;
            DEL2=2*DEL1*F220*G200*Q22;
            DEL3=3*DEL1*F330*G300*Q33*AQNV;
            DEL1=DEL1*F311*G310*Q31*AQNV;
            FASX2=0.13130908;
            FASX4=2.8843198;
            FASX6=0.37448087;
            XLAMO=XMAO+XNODEO+OMEGAO-THGR;
            BFACT=XLLDOT+XPIDOT-THDT;
            BFACT=BFACT+SSL+SSG+SSH;
        end

        XFACT=BFACT-XNQ;


        XLI=XLAMO;
        XNI=XNQ;
        ATIME=0;
        STEPP=720;
        STEPN=-720;
        STEP2=259200;


        SINIO=SINIQ;
        COSIO=COSIQ;
        XMDOT=XLLDOT;
        OMGDOT=OMGDT;


        XMDF=XMO+XMDOT*TSINCE;
        OMGADF=OMEGAO+OMGDOT*TSINCE;
        XNODDF=XNODEO+XNODOT*TSINCE;
        TSQ=TSINCE*TSINCE;
        XNODE=XNODDF+XNODCF*TSQ;
        TEMPA=1-C1*TSINCE;
        TEMPE=BSTAR*C4*TSINCE;
        TEMPL=T2COF*TSQ;
        XN=XNODP;


        XLL=XMDF;
        OMGASM=OMGADF;
        XNODES=XNODE;
        T=TSINCE;
        XLL=XLL+SSL*T;
        OMGASM=OMGASM+SSG*T;
        XNODES=XNODES+SSH*T;
        EM=EO+SSE*T;
        XINC=XINCL+SSI*T;

        if~(XINC>=0)
            XINC=-XINC;
            XNODES=XNODES+PI;
            OMGASM=OMGASM-PI;
        end

        if~(IRESFL==0)
            while(1)
                if(ATIME==0)||((T>=0)&&(ATIME<0))||((T<0)&&(ATIME>=0))
                    if T>=0
                        DELT=STEPP;
                    else
                        DELT=STEPN;
                    end
                    ATIME=0;
                    XNI=XNQ;
                    XLI=XLAMO;
                    break
                else
                    if(abs(T)>=abs(ATIME))
                        DELT=STEPN;
                        if T>0
                            DELT=STEPP;
                        end
                        break
                    else
                        DELT=STEPP;
                        if T>=0
                            DELT=STEPN;
                        end
                        if(ISYNFL==0)
                            XOMI=OMEGAQ+OMGDT*ATIME;
                            X2OMI=XOMI+XOMI;
                            X2LI=XLI+XLI;
                            XNDOT=D2201*sin(X2OMI+XLI-G22)...
                            +D2211*sin(XLI-G22)...
                            +D3210*sin(XOMI+XLI-G32)...
                            +D3222*sin(-XOMI+XLI-G32)...
                            +D4410*sin(X2OMI+X2LI-G44)...
                            +D4422*sin(X2LI-G44)...
                            +D5220*sin(XOMI+XLI-G52)...
                            +D5232*sin(-XOMI+XLI-G52)...
                            +D5421*sin(XOMI+X2LI-G54)...
                            +D5433*sin(-XOMI+X2LI-G54);
                            XNDDT=D2201*cos(X2OMI+XLI-G22)...
                            +D2211*cos(XLI-G22)...
                            +D3210*cos(XOMI+XLI-G32)...
                            +D3222*cos(-XOMI+XLI-G32)...
                            +D5220*cos(XOMI+XLI-G52)...
                            +D5232*cos(-XOMI+XLI-G52)...
                            +2.*(D4410*cos(X2OMI+X2LI-G44)...
                            +D4422*cos(X2LI-G44)...
                            +D5421*cos(XOMI+X2LI-G54)...
                            +D5433*cos(-XOMI+X2LI-G54));
                        else
                            XNDOT=DEL1*sin(XLI-FASX2)+DEL2*...
                            sin(2.*(XLI-FASX4))...
                            +DEL3*sin(3.*(XLI-FASX6));
                            XNDDT=DEL1*cos(XLI-FASX2)...
                            +2.*DEL2*cos(2.*(XLI-FASX4))...
                            +3.*DEL3*cos(3.*(XLI-FASX6));
                        end
                        XLDOT=XNI+XFACT;
                        XNDDT=XNDDT*XLDOT;
                        XLI=XLI+XLDOT*DELT+XNDOT*STEP2;
                        XNI=XNI+XNDOT*DELT+XNDDT*STEP2;
                        ATIME=ATIME+DELT;
                    end
                end
            end

            while~(abs(T-ATIME)<STEPP)
                if(ISYNFL==0)
                    XOMI=OMEGAQ+OMGDT*ATIME;
                    X2OMI=XOMI+XOMI;
                    X2LI=XLI+XLI;
                    XNDOT=D2201*sin(X2OMI+XLI-G22)...
                    +D2211*sin(XLI-G22)...
                    +D3210*sin(XOMI+XLI-G32)...
                    +D3222*sin(-XOMI+XLI-G32)...
                    +D4410*sin(X2OMI+X2LI-G44)...
                    +D4422*sin(X2LI-G44)...
                    +D5220*sin(XOMI+XLI-G52)...
                    +D5232*sin(-XOMI+XLI-G52)...
                    +D5421*sin(XOMI+X2LI-G54)...
                    +D5433*sin(-XOMI+X2LI-G54);
                    XNDDT=D2201*cos(X2OMI+XLI-G22)...
                    +D2211*cos(XLI-G22)...
                    +D3210*cos(XOMI+XLI-G32)...
                    +D3222*cos(-XOMI+XLI-G32)...
                    +D5220*cos(XOMI+XLI-G52)...
                    +D5232*cos(-XOMI+XLI-G52)...
                    +2.*(D4410*cos(X2OMI+X2LI-G44)...
                    +D4422*cos(X2LI-G44)...
                    +D5421*cos(XOMI+X2LI-G54)...
                    +D5433*cos(-XOMI+X2LI-G54));
                else
                    XNDOT=DEL1*sin(XLI-FASX2)+DEL2*sin(2.*(XLI-FASX4))...
                    +DEL3*sin(3.*(XLI-FASX6));
                    XNDDT=DEL1*cos(XLI-FASX2)...
                    +2.*DEL2*cos(2.*(XLI-FASX4))...
                    +3.*DEL3*cos(3.*(XLI-FASX6));
                end
                XLDOT=XNI+XFACT;
                XNDDT=XNDDT*XLDOT;
                XLI=XLI+XLDOT*DELT+XNDOT*STEP2;
                XNI=XNI+XNDOT*DELT+XNDDT*STEP2;
                ATIME=ATIME+DELT;
            end

            FT=T-ATIME;
            if(ISYNFL==0)
                XOMI=OMEGAQ+OMGDT*ATIME;
                X2OMI=XOMI+XOMI;
                X2LI=XLI+XLI;
                XNDOT=D2201*sin(X2OMI+XLI-G22)...
                +D2211*sin(XLI-G22)...
                +D3210*sin(XOMI+XLI-G32)...
                +D3222*sin(-XOMI+XLI-G32)...
                +D4410*sin(X2OMI+X2LI-G44)...
                +D4422*sin(X2LI-G44)...
                +D5220*sin(XOMI+XLI-G52)...
                +D5232*sin(-XOMI+XLI-G52)...
                +D5421*sin(XOMI+X2LI-G54)...
                +D5433*sin(-XOMI+X2LI-G54);
                XNDDT=D2201*cos(X2OMI+XLI-G22)...
                +D2211*cos(XLI-G22)...
                +D3210*cos(XOMI+XLI-G32)...
                +D3222*cos(-XOMI+XLI-G32)...
                +D5220*cos(XOMI+XLI-G52)...
                +D5232*cos(-XOMI+XLI-G52)...
                +2.*(D4410*cos(X2OMI+X2LI-G44)...
                +D4422*cos(X2LI-G44)...
                +D5421*cos(XOMI+X2LI-G54)...
                +D5433*cos(-XOMI+X2LI-G54));
            else
                XNDOT=DEL1*sin(XLI-FASX2)+DEL2*sin(2.*(XLI-FASX4))...
                +DEL3*sin(3.*(XLI-FASX6));
                XNDDT=DEL1*cos(XLI-FASX2)...
                +2.*DEL2*cos(2.*(XLI-FASX4))...
                +3.*DEL3*cos(3.*(XLI-FASX6));
            end
            XLDOT=XNI+XFACT;
            XNDDT=XNDDT*XLDOT;
            XN=XNI+XNDOT*FT+XNDDT*FT*FT*0.5;
            XL=XLI+XLDOT*FT+XNDOT*FT*FT*0.5;
            TEMP=-XNODES+THGR+T*THDT;
            XLL=XL-OMGASM+TEMP;

            if(ISYNFL==0)
                XLL=XL+TEMP+TEMP;
            end
        end

        XMDF=XLL;
        OMGADF=OMGASM;
        XNODE=XNODES;


        A=(XKE/XN)^TOTHRD*TEMPA^2;
        E=EM-TEMPE;
        XMAM=XMDF+XNODP*TEMPL;


        EM=E;
        OMGASM=OMGADF;
        XNODES=XNODE;
        XLL=XMAM;
        SGHS=0;
        SGHL=0;
        SHS=0;
        SHL=0;
        PINC=0;
        PE=0;
        PL=0;
        SINIS=sin(XINC);
        COSIS=cos(XINC);

        if~(abs(SAVTSN-T)<(30))
            ZM=ZMOS+ZNS*T;
            ZF=ZM+2.*ZES*sin(ZM);
            SINZF=sin(ZF);
            F2=.5*SINZF*SINZF-.25;
            F3=-.5*SINZF*cos(ZF);
            SES=SE2*F2+SE3*F3;
            SIS=SI2*F2+SI3*F3;
            SLS=SL2*F2+SL3*F3+SL4*SINZF;
            SGHS=SGH2*F2+SGH3*F3+SGH4*SINZF;
            SHS=SH2*F2+SH3*F3;
            ZM=ZMOL+ZNL*T;
            ZF=ZM+2.*ZEL*sin(ZM);
            SINZF=sin(ZF);
            F2=.5*SINZF*SINZF-.25;
            F3=-.5*SINZF*cos(ZF);
            SEL=EE2*F2+E3*F3;
            SIL=XI2*F2+XI3*F3;
            SLL=XL2*F2+XL3*F3+XL4*SINZF;
            SGHL=XGH2*F2+XGH3*F3+XGH4*SINZF;
            SHL=XH2*F2+XH3*F3;
            PE=SES+SEL;
            PINC=SIS+SIL;
            PL=SLS+SLL;
        end

        PGH=SGHS+SGHL;
        PH=SHS+SHL;
        XINC=XINC+PINC;
        EM=EM+PE;

        if~(XQNCL<(.2))

            PH=PH/SINIQ;
            PGH=PGH-COSIQ*PH;
            OMGASM=OMGASM+PGH;
            XNODES=XNODES+PH;
            XLL=XLL+PL;
        else

            SINOK=sin(XNODES);
            COSOK=cos(XNODES);
            ALFDP=SINIS*SINOK;
            BETDP=SINIS*COSOK;
            DALF=PH*COSOK+PINC*COSIS*SINOK;
            DBET=-PH*SINOK+PINC*COSIS*COSOK;
            ALFDP=ALFDP+DALF;
            BETDP=BETDP+DBET;
            XLS=XLL+OMGASM+COSIS*XNODES;
            DLS=PL+PGH-PINC*XNODES*SINIS;
            XLS=XLS+DLS;
            XNODES=matlabshared.orbit.internal.GeneralPerturbations.arctan(ALFDP,BETDP);
            XLL=XLL+PL;
            OMGASM=XLS-XLL-cos(XINC)*XNODES;
        end

        E=EM;
        OMGADF=OMGASM;
        XNODE=XNODES;
        XMAM=XLL;


        XL=XMAM+OMGADF+XNODE;
        BETA=sqrt(1-E*E);
        XN=XKE/A^1.5;


        AXN=E*cos(OMGADF);
        TEMP=1/(A*BETA*BETA);
        XLL=TEMP*XLCOF*AXN;
        AYNL=TEMP*AYCOF;
        XLT=XL+XLL;
        AYN=E*sin(OMGADF)+AYNL;


        CAPU=mod(real(XLT-XNODE),2*pi);
        TEMP2=CAPU;

        for I=1:10
            SINEPW=sin(TEMP2);
            COSEPW=cos(TEMP2);
            TEMP3=real(AXN*SINEPW);
            TEMP4=AYN*COSEPW;
            TEMP5=AXN*COSEPW;
            TEMP6=AYN*SINEPW;
            EPW=(CAPU-TEMP4+TEMP3-TEMP2)/(1-TEMP5-TEMP6)+TEMP2;

            if(abs(EPW-TEMP2)<=E6A)
                break
            end

            TEMP2=real(EPW);
        end


        ECOSE=TEMP5+TEMP6;
        ESINE=TEMP3-TEMP4;
        ELSQ=AXN*AXN+AYN*AYN;
        TEMP=1-ELSQ;
        PL=A*TEMP;
        R=A*(1-ECOSE);
        TEMP1=1/R;
        RDOT=XKE*sqrt(A)*ESINE*TEMP1;
        RFDOT=XKE*sqrt(PL)*TEMP1;
        TEMP2=A*TEMP1;
        BETAL=sqrt(TEMP);
        TEMP3=1/(1+BETAL);
        COSU=TEMP2*(COSEPW-AXN+AYN*ESINE*TEMP3);
        SINU=TEMP2*(SINEPW-AYN-AXN*ESINE*TEMP3);
        U=matlabshared.orbit.internal.GeneralPerturbations.arctan(SINU,COSU);
        SIN2U=2*SINU*COSU;
        COS2U=2*COSU*COSU-1;
        TEMP=1/PL;
        TEMP1=CK2*TEMP;
        TEMP2=TEMP1*TEMP;


        RK=R*(1-1.5*TEMP2*BETAL*X3THM1)+0.5*TEMP1*X1MTH2*COS2U;
        UK=U-0.25*TEMP2*X7THM1*SIN2U;
        XNODEK=XNODE+1.5*TEMP2*COSIO*SIN2U;
        XINCK=XINC+1.5*TEMP2*COSIO*SINIO*COS2U;
        RDOTK=RDOT-XN*TEMP1*X1MTH2*SIN2U;
        RFDOTK=RFDOT+XN*TEMP1*(X1MTH2*COS2U+1.5*X3THM1);


        SINUK=sin(UK);
        COSUK=cos(UK);
        SINIK=sin(XINCK);
        COSIK=cos(XINCK);
        SINNOK=sin(XNODEK);
        COSNOK=cos(XNODEK);
        XMX=-SINNOK*COSIK;
        XMY=COSNOK*COSIK;
        UX=XMX*SINUK+COSNOK*COSUK;
        UY=XMY*SINUK+SINNOK*COSUK;
        UZ=SINIK*SINUK;
        VX=XMX*COSUK-COSNOK*SINUK;
        VY=XMY*COSUK-SINNOK*SINUK;
        VZ=SINIK*COSUK;


        X=RK*UX;
        Y=RK*UY;
        Z=RK*UZ;
        XDOT=RDOTK*UX+RFDOTK*VX;
        YDOT=RDOTK*UY+RFDOTK*VY;
        ZDOT=RDOTK*UZ+RFDOTK*VZ;
        rbar=[X;Y;Z]*matlabshared.orbit.internal.GeneralPerturbations.pEarthRadiusGP;
        vbar=...
        [XDOT;YDOT;ZDOT]*matlabshared.orbit.internal.GeneralPerturbations.pEarthRadiusGP/60;
        position(:,idx)=rbar;
        velocity(:,idx)=vbar;
    end
end

function epochDayNumber=hDayOfYear(epochYear,epochMonth,epochDay)


    if mod(epochYear,400)==0

        daysInFeb=29;
    elseif mod(epochYear,100)==0
        daysInFeb=28;
    elseif mod(epochYear,4)==0

        daysInFeb=29;
    else
        daysInFeb=28;
    end

    switch epochMonth
    case 1
        epochDayNumber=0;
    case 2
        epochDayNumber=31;
    case 3
        epochDayNumber=31+daysInFeb;
    case 4
        epochDayNumber=31+daysInFeb+31;
    case 5
        epochDayNumber=31+daysInFeb+31+30;
    case 6
        epochDayNumber=31+daysInFeb+31+30+31;
    case 7
        epochDayNumber=31+daysInFeb+31+30+31+30;
    case 8
        epochDayNumber=31+daysInFeb+31+30+31+30+31;
    case 9
        epochDayNumber=31+daysInFeb+31+30+31+30+31+31;
    case 10
        epochDayNumber=31+daysInFeb+31+30+31+30+31+31+30;
    case 11
        epochDayNumber=31+daysInFeb+31+30+31+30+31+31...
        +30+31;
    case 12
        epochDayNumber=31+daysInFeb+31+30+31+30+31+31...
        +30+31+30;
    otherwise
        epochDayNumber=0;
    end

    epochDayNumber=epochDayNumber+epochDay;
end


