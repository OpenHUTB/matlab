function[testNumOut,injFreqOut,refSignalOut,estimatedParameterOut,testEnableOut,estParIdxOut,Kp_iOut,Ki_iOut]=estimateMotorParamAcim(SignalsPU,Ts,curTime,RsMeasTestTime,I_rated,Rs,Ld,R_board,V_rated,currentPU_RWV,sigma,IaIbVdc,inverter_V_max,speedFB,speed_rated,Freq_rated,algoVar)

    coder.allowpcode('plain');
%#codegen

    persistent flag;
    if isempty(flag)
        flag=single(0);
    end

    persistent errorID;
    if isempty(errorID)
        errorID=single(0);
    end

    persistent estParIdx;
    if isempty(estParIdx)
        estParIdx=single(20);
    end

    persistent phaseDiffRad;
    if isempty(phaseDiffRad)
        phaseDiffRad=single(0);
    end

    persistent flagNextVal;
    if isempty(flagNextVal)
        flagNextVal=single(1);
    end

    persistent delay;
    if isempty(delay)
        delay=single(1);
    end

    persistent estimatedParameter;
    if isempty(estimatedParameter)
        estimatedParameter=single(0);
    end

    persistent voltagePU_RWV;
    if isempty(voltagePU_RWV)
        voltagePU_RWV=single(V_rated/sqrt(3));
    end

    persistent Kp_i;
    if isempty(Kp_i)
        Kp_i=single(0);
    end

    persistent Ki_i;
    if isempty(Ki_i)
        Ki_i=single(0);
    end

    persistent testNum;

    if isempty(testNum)
        testNum=single(0);
    end

    persistent testEnable;
    if isempty(testEnable)
        testEnable=single(1);
    end

    persistent injFreq;
    if isempty(injFreq)
        injFreq=Freq_rated;
    end

    persistent speed_mech_rpm;
    if isempty(speed_mech_rpm)
        speed_mech_rpm=single(0);
    end

    persistent speed_radPerSec;
    if isempty(speed_radPerSec)
        speed_radPerSec=single(0);
    end

    persistent numInjFreq;
    if isempty(numInjFreq)
        numInjFreq=single(2);
    end

    persistent numWaves;
    if isempty(numWaves)
        numWaves=single(0);
    end

    persistent refSignal;
    if isempty(refSignal)
        refSignal=single(0);
    end

    persistent savedTimeInstance;
    if isempty(savedTimeInstance)
        savedTimeInstance=single(0);
    end

    persistent timeInstance1;
    if isempty(timeInstance1)
        timeInstance1=single(0);
    end

    persistent timeInstance2;
    if isempty(timeInstance2)
        timeInstance2=single(0);
    end

    persistent samplesPerHalfCycle;
    if isempty(samplesPerHalfCycle)
        samplesPerHalfCycle=single(0);
    end

    persistent sinIdx;
    if isempty(sinIdx)
        sinIdx=single(1);
    end

    persistent count1;
    if isempty(count1)
        count1=single(0);
    end

    persistent count2;
    if isempty(count2)
        count2=single(0);
    end

    persistent count3;
    if isempty(count3)
        count3=single(0);
    end

    persistent count4;
    if isempty(count4)
        count4=single(0);
    end

    persistent arraySine;
    if isempty(arraySine)
        arraySine=single(zeros(10000,1));
    end

    persistent max;
    if isempty(max)
        max=single(0);
    end

    persistent min;
    if isempty(min)
        min=single(0);
    end

    persistent Sig1;
    persistent Sig2;
    if isempty(Sig1)
        Sig1=single(0);
    end
    if isempty(Sig2)
        Sig2=single(0);
    end

    persistent Sig1Prev;
    persistent Sig2Prev;
    if isempty(Sig1Prev)
        Sig1Prev=single(0);
    end
    if isempty(Sig2Prev)
        Sig2Prev=single(0);
    end

    persistent Sig1Mean;
    persistent Sig2Mean;
    persistent Sig3Mean;
    persistent Sig4Mean;
    persistent Sig5Mean;
    if isempty(Sig1Mean)
        Sig1Mean=single(0);
    end
    if isempty(Sig2Mean)
        Sig2Mean=single(0);
    end
    if isempty(Sig3Mean)
        Sig3Mean=single(0);
    end
    if isempty(Sig4Mean)
        Sig4Mean=single(0);
    end
    if isempty(Sig5Mean)
        Sig5Mean=single(0);
    end

    persistent I_amplitude;
    if isempty(I_amplitude)
        I_amplitude=single(0.1);
    end

    persistent Req_motor;

    if isempty(Req_motor)
        Req_motor=single(0.1);
    end

    persistent Req_freq_1;

    if isempty(Req_freq_1)
        Req_freq_1=single(0.1);
    end

    persistent Freq_1;
    if isempty(Freq_1)
        Freq_1=single(0.1);
    end

    persistent Xeq_freq_1;
    if isempty(Xeq_freq_1)
        Xeq_freq_1=single(0.1);
    end

    persistent Req_freq_2;
    if isempty(Req_freq_2)
        Req_freq_2=single(0.1);
    end

    persistent Freq_2;
    if isempty(Freq_2)
        Freq_2=single(0.1);
    end

    persistent Rr_dash;
    if isempty(Rr_dash)
        Rr_dash=single(0.1);
    end

    persistent Lm_dash;
    if isempty(Lm_dash)
        Lm_dash=single(0.1);
    end

    persistent Llk_dash;
    if isempty(Llk_dash)
        Llk_dash=single(0.1);
    end

    persistent Rr_motor;
    if isempty(Rr_motor)
        Rr_motor=single(0.1);
    end

    persistent Lm_motor;
    if isempty(Lm_motor)
        Lm_motor=single(0.1);
    end

    persistent injVol;
    if isempty(injVol)
        injVol=single(0.1);
    end

    persistent V_amplitude1;
    if isempty(V_amplitude1)
        V_amplitude1=single(0.1);
    end

    persistent high_Freq_inj_test;
    if isempty(high_Freq_inj_test)
        high_Freq_inj_test=single(0);
    end

    persistent Xeq_high_freq;
    if isempty(Xeq_high_freq)
        Xeq_high_freq=single(0.001);
    end

    persistent Sig3;
    if isempty(Sig3)
        Sig3=single(0);
    end

    persistent Sig4;
    if isempty(Sig4)
        Sig4=single(0);
    end
    persistent ResCounter;
    if isempty(ResCounter)
        ResCounter=single(0);
    end

    persistent Telec;
    if isempty(Telec)
        Telec=single(0);
    end

    persistent openloop_test_flag;
    if isempty(openloop_test_flag)
        openloop_test_flag=single(0);
    end

    if testNum>0&&testEnable

        if abs(IaIbVdc(1))*currentPU_RWV>(algoVar(3)*I_rated)||abs(IaIbVdc(2))*currentPU_RWV>(algoVar(3)*I_rated)
            flag=single(15);
            errorID=single(1);
        elseif IaIbVdc(3)*inverter_V_max<(algoVar(4)*V_rated)
            flag=single(15);
            errorID=single(2);
        end
    end

    switch flag

    case 0

        if curTime>=savedTimeInstance+delay
            flag=flagNextVal;
            savedTimeInstance=curTime;
        end

    case 1
        if curTime<savedTimeInstance+0.1
            Sig1=Sig1+single(SignalsPU(1));
            Sig2=Sig2+single(SignalsPU(2));
        else
            savedTimeInstance=curTime;
            flagNextVal=single(2);
            delay=single(0.5);
            flag=single(0);
        end

    case 2

        voltagePU_RWV=single(V_rated/sqrt(3));
        estimatedParameter=single(Sig1*1e-4/((0.3-0.2)/Ts));
        savedTimeInstance=curTime;

        flagNextVal=single(3);
        delay=single(0.5);
        flag=single(0);
        estParIdx=single(0);

    case 3

        estimatedParameter=single(Sig2*1e-4/((0.3-0.2)/Ts));
        estParIdx=single(1);

        if algoVar(5)==0

            refSignal=algoVar(1);
            Sig1=single(0);
            Sig2=single(0);
            savedTimeInstance=curTime;
            flagNextVal=single(4);
            delay=single(0.5);
            flag=single(0);
            testNum=single(2);
        else

            refSignal=single(0.9);
            Sig1=single(0);
            Sig2=single(0);
            savedTimeInstance=curTime;
            flagNextVal=single(17);
            delay=single(3);
            flag=single(0);
            testNum=single(1);
            injFreq=single(0.9*Freq_rated);
        end

    case 4

        if curTime<savedTimeInstance+RsMeasTestTime
            if refSignal==algoVar(1)
                Sig1=Sig1+single(SignalsPU(1)*1e-3);
                Sig2=Sig2+single(SignalsPU(2)*1e-3);

            else
                Sig3=Sig3+single(SignalsPU(1)*1e-3);
                Sig4=Sig4+single(SignalsPU(2)*1e-3);
            end
        else
            if ResCounter<single(1)
                refSignal=algoVar(2);
                savedTimeInstance=curTime;
                flagNextVal=single(4);
                delay=single(0.1);
                flag=single(0);
                ResCounter=single(1);
            else

                flagNextVal=single(5);
                delay=single(0.1);
                flag=single(0);
                savedTimeInstance=curTime;
                ResCounter=single(0);
            end
        end

    case 5

        Sig1=(Sig1*voltagePU_RWV/(RsMeasTestTime*1e-3/Ts));
        Sig2=Sig2*currentPU_RWV/(RsMeasTestTime*1e-3/Ts);
        Sig3=(Sig3*voltagePU_RWV/(RsMeasTestTime*1e-3/Ts));
        Sig4=Sig4*currentPU_RWV/(RsMeasTestTime*1e-3/Ts);
        estimatedParameter=single((Sig1-Sig3)/(Sig2-Sig4))-R_board;
        Req_motor=single((Sig1)/(Sig2));
        estParIdx=single(2);
        injFreq=single(1*uint16(Freq_rated/single(10)));
        samplesPerHalfCycle=single(uint16(0.5*(1/(Ts*injFreq))));
        Sig1=single(0);
        Sig2=single(0);
        numWaves=single(5);
        Sig3=single(0);
        Sig4=single(0);
        savedTimeInstance=curTime;
        flagNextVal=single(6);
        delay=single(0.5);
        flag=single(0);
        refSignal=single(0.1);
        testNum=single(3);

    case 6
        SignalsPU(2)=single(SignalsPU(2))*currentPU_RWV;
        Sig1=Sig1+((single(SignalsPU(2))-arraySine(sinIdx))/samplesPerHalfCycle);

        if count1>=numWaves
            arraySine(sinIdx)=0;
        else
            arraySine(sinIdx)=single(SignalsPU(2));
        end
        if Sig1>max
            max=Sig1;
        elseif Sig1<min
            min=Sig1;
        end

        if sinIdx>=samplesPerHalfCycle
            sinIdx=single(1);
            if count1==0

                max=Sig1;
                min=max;
            end
            count1=count1+single(1);
            if count1>numWaves
                if testNum==1
                    delay=single(1);
                    flag=single(0);
                    openloop_test_flag=single(1);
                    refSignal=single(0.5);
                    estimatedParameter=(max-min)*pi*0.25;
                    estParIdx=single(9);
                    flagNextVal=single(17);
                else
                    flagNextVal=single(7);
                    flag=flagNextVal;
                end
            end
        else
            sinIdx=sinIdx+single(1);
        end

    case 7
        if(max-min)*pi*0.25<(0.5*I_rated)&&(high_Freq_inj_test==single(0))
            flagNextVal=single(6);
            injVol=injVol+single(0.025);
            refSignal=injVol;
        else
            flagNextVal=single(8);
            numWaves=single(8);
            I_amplitude=(max-min)*pi*0.25;
            V_amplitude1=injVol;
        end

        delay=single(0.2);
        flag=single(0);
        savedTimeInstance=curTime;
        count1=single(0);
        count2=single(0);
        Sig1=single(0);
        Sig2=single(0);
        sinIdx=single(1);

    case 8
        SignalsPU(1)=single(SignalsPU(1))*voltagePU_RWV;
        SignalsPU(2)=single(SignalsPU(2))*currentPU_RWV;

        Sig1=Sig1+((single(SignalsPU(1))-arraySine(sinIdx))/samplesPerHalfCycle);
        Sig2=Sig2+((single(SignalsPU(2))-arraySine(sinIdx+5000))/samplesPerHalfCycle);
        arraySine(sinIdx)=single(SignalsPU(1));
        arraySine(sinIdx+5000)=single(SignalsPU(2));
        if count1>0
            Sig1Mean=Sig1Mean+Sig1;
            Sig2Mean=Sig2Mean+Sig2;
            count2=count2+1;
        end
        if sinIdx>=samplesPerHalfCycle
            sinIdx=single(1);
            count1=count1+single(1);
        else
            sinIdx=sinIdx+single(1);
        end

        if curTime>savedTimeInstance+(numWaves+1)*(0.5/injFreq)
            Sig1Mean=Sig1Mean/count2;
            Sig2Mean=Sig2Mean/count2;
            flagNextVal=single(9);
            flag=flagNextVal;
            count1=single(0);
            count2=single(0);
            numWaves=single(5);
            Sig1Prev=Sig1;
            Sig2Prev=Sig2;
        end

    case 9
        SignalsPU(1)=single(SignalsPU(1))*voltagePU_RWV;
        SignalsPU(2)=single(SignalsPU(2))*currentPU_RWV;

        Sig1=Sig1+((single(SignalsPU(1))-arraySine(sinIdx))/samplesPerHalfCycle);
        Sig2=Sig2+((single(SignalsPU(2))-arraySine(sinIdx+5000))/samplesPerHalfCycle);

        arraySine(sinIdx)=single(SignalsPU(1));
        arraySine(sinIdx+5000)=single(SignalsPU(2));
        if sinIdx>=samplesPerHalfCycle
            sinIdx=single(1);
        else
            sinIdx=sinIdx+single(1);
        end

        if Sig1>Sig1Mean&&Sig1Prev<Sig1Mean
            timeInstance1=curTime;
            count2=single(1);

        elseif Sig2>Sig2Mean&&Sig2Prev<Sig2Mean&&count2
            timeInstance2=curTime;
            phaseDiffRad=phaseDiffRad+((timeInstance2-timeInstance1)*injFreq*2*pi);
            if(injFreq==(single(uint16(1*Freq_rated/10))))
                Req_freq_1=V_amplitude1*voltagePU_RWV*cos(phaseDiffRad)/I_amplitude;
                Xeq_freq_1=V_amplitude1*voltagePU_RWV*sin(phaseDiffRad)/I_amplitude;
                Req_freq_1=Req_freq_1-Req_motor;
                Freq_1=injFreq;
            elseif(injFreq==(single(2*uint16(Freq_rated/10))))
                Req_freq_2=V_amplitude1*voltagePU_RWV*cos(phaseDiffRad)/I_amplitude;
                Req_freq_2=Req_freq_2-Req_motor;
                Freq_2=injFreq;

            elseif(injFreq==single(200))
                Xeq_high_freq=V_amplitude1*voltagePU_RWV*sin(phaseDiffRad)*single(0.5)/(2*pi*injFreq*I_amplitude);
                count4=count4+1;
            end

            count3=count3+single(1);

            if(count3<numInjFreq)

                injFreq=single(injFreq*2);
                samplesPerHalfCycle=single(uint16(0.5*(1/(Ts*injFreq))));
                numWaves=single(5);
                flagNextVal=single(6);
                delay=single(0.2);
                flag=single(0);
                sinIdx=single(1);
                count1=single(0);
                count2=single(0);
                phaseDiffRad=single(0);
                Sig1=single(0);
                Sig2=single(0);
                Sig1Mean=single(0);
                Sig2Mean=single(0);
                arraySine=single(zeros(10000,1));
                injVol=single(0.1);
                V_amplitude1=single(0.1);
                refSignal=single(0.1);

            else

                if count4<single(1)
                    Rr_dash=(Req_freq_2*Req_freq_1)*((2*pi*Freq_1)^2-(2*pi*Freq_2)^2)/((Req_freq_2*(2*pi*Freq_1)^2)-(Req_freq_1*(2*pi*Freq_2)^2));
                    Lm_dash=(Rr_dash/(2*pi*Freq_1))*sqrt(abs(Req_freq_1/(Req_freq_1-Rr_dash)));
                    Llk_dash=(Xeq_freq_1/(2*pi*Freq_1))-((Lm_dash*Rr_dash^2)/(Rr_dash^2+(2*pi*Freq_1*Lm_dash)^2));
                    savedTimeInstance=curTime;
                    sinIdx=single(1);
                    count1=single(0);
                    count2=single(0);
                    phaseDiffRad=single(0);
                    Sig1=single(0);
                    Sig2=single(0);
                    Sig1Mean=single(0);
                    Sig2Mean=single(0);
                    arraySine=single(zeros(10000,1));
                    flagNextVal=single(6);
                    delay=single(0.5);
                    flag=single(0);
                    injVol=single(0.1);
                    V_amplitude1=single(0.1);
                    injFreq=single(200);
                    samplesPerHalfCycle=single(uint16(0.5*(1/(Ts*injFreq))));
                    high_Freq_inj_test=single(1);
                    refSignal=single(0.1);

                else
                    savedTimeInstance=curTime;
                    sinIdx=single(1);
                    count1=single(0);
                    count2=single(0);
                    phaseDiffRad=single(0);
                    Sig1=single(0);
                    Sig2=single(0);
                    Sig1Mean=single(0);
                    Sig2Mean=single(0);
                    arraySine=single(zeros(10000,1));
                    flagNextVal=single(10);
                    delay=single(0.5);
                    flag=single(0);
                    injVol=single(0.1);
                    V_amplitude1=single(0.1);
                    injFreq=single(200);
                    samplesPerHalfCycle=single(uint16(0.5*(1/(Ts*injFreq))));
                    refSignal=injVol;

                end

            end
        end
        Sig1Prev=Sig1;
        Sig2Prev=Sig2;

    case 10

        if testNum==3
            estimatedParameter=single((Llk_dash+Lm_dash)*Rr_dash/Lm_dash);
            Rr_motor=estimatedParameter;
            flagNextVal=single(10);
            delay=single(0.5);
            flag=single(0);
            estParIdx=single(3);
            testNum=single(4);
            savedTimeInstance=curTime;
            count3=single(0);
            count4=single(0);

        elseif testNum==4
            estimatedParameter=single((Llk_dash+Lm_dash)*sqrt(Rr_dash/Rr_motor));
            Lm_motor=estimatedParameter;
            flagNextVal=single(10);
            delay=single(0.5);
            flag=single(0);
            estParIdx=single(4);
            testNum=single(5);
            savedTimeInstance=curTime;

        elseif testNum==5
            estimatedParameter=single(Xeq_high_freq);
            flagNextVal=single(11);
            delay=single(0.5);
            flag=single(0);
            estParIdx=single(5);
            testNum=single(6);
            refSignal=single(0.65);
            numWaves=single(60000);

            Kp_i=single((Ld/(8*sigma*1e-6))*(currentPU_RWV/voltagePU_RWV));
            Ki_i=single(((Rs+R_board)/(8*sigma*1e-6))*(currentPU_RWV/voltagePU_RWV));

        end

    case 11

        Sig2Mean=Sig2Mean+SignalsPU(3);
        Sig3Mean=Sig3Mean+SignalsPU(4);
        Sig4Mean=Sig4Mean+SignalsPU(5);
        Sig5Mean=Sig5Mean+SignalsPU(6);

        count2=count2+1;
        if count2>numWaves
            Sig2Mean=Sig2Mean*voltagePU_RWV/count2;
            Sig3Mean=Sig3Mean*currentPU_RWV/count2;
            Sig4Mean=Sig4Mean*voltagePU_RWV/count2;
            Sig5Mean=Sig5Mean*currentPU_RWV/count2;
            flagNextVal=single(12);
            flag=flagNextVal;
            count2=single(0);
        end
    case 12

        flagNextVal=single(13);
        savedTimeInstance=curTime;
        count1=curTime;
        delay=single(0.02);
        flag=single(0);
        speed_radPerSec=(speedFB*speed_rated)*2*pi/60;
        testEnable=single(0);

    case 13

        if abs(speedFB*speed_rated)<(single(0.25)*speed_radPerSec*single(60/(2*pi)))
            speed_mech_rpm=single(speedFB*speed_rated);
            timeInstance2=curTime;
            estimatedParameter=((3/2*((Sig2Mean*Sig3Mean)+(Sig4Mean*Sig5Mean)))-...
            (3/2*(Sig5Mean^2+Sig3Mean^2)*(Req_motor)))/...
            (((speed_radPerSec-(speed_mech_rpm*2*pi/60))/...
            (timeInstance2-count1))*(speed_radPerSec));

            Telec=((3/2*((Sig2Mean*Sig3Mean)+(Sig4Mean*Sig5Mean)))-...
            (3/2*(Sig5Mean^2+Sig3Mean^2)*(Req_motor)))/speed_radPerSec;
            estParIdx=single(6);
            flagNextVal=single(14);
            savedTimeInstance=curTime;
            delay=single(0.5);
            flag=single(0);
        end
    case 14

        estimatedParameter=(Telec)/speed_radPerSec;
        estParIdx=single(7);
        flagNextVal=single(16);
        delay=single(0.5);
        flag=single(0);
        testNum=single(0);
    case 15
        testEnable=single(0);
        estimatedParameter=errorID;
        estParIdx=single(8);
        flagNextVal=single(16);
        delay=single(0.5);
        flag=single(0);
    case 16
        flag=single(0);
        errorID=single(0);
        estParIdx=single(20);
        phaseDiffRad=single(0);
        flagNextVal=single(1);
        delay=single(1);
        estimatedParameter=single(0);
        voltagePU_RWV=single(V_rated/sqrt(3));
        Kp_i=single(0);
        Ki_i=single(0);
        testNum=single(0);
        testEnable=single(1);
        injFreq=Freq_rated;
        speed_mech_rpm=single(0);
        speed_radPerSec=single(0);
        numInjFreq=single(2);
        numWaves=single(0);
        refSignal=single(0);
        savedTimeInstance=single(0);
        timeInstance1=single(0);
        timeInstance2=single(0);
        samplesPerHalfCycle=single(0);
        sinIdx=single(1);
        count1=single(0);
        count2=single(0);
        count3=single(0);
        arraySine=single(zeros(10000,1));
        max=single(0);
        min=single(0);
        Sig1=single(0);
        Sig2=single(0);
        Sig1Prev=single(0);
        Sig2Prev=single(0);
        Sig1Mean=single(0);
        Sig2Mean=single(0);
        Sig3Mean=single(0);
        Sig4Mean=single(0);
        Sig5Mean=single(0);

        I_amplitude=single(0.1);
        Req_motor=single(0.1);
        Req_freq_1=single(0.1);
        Freq_1=single(0.1);
        Xeq_freq_1=single(0.1);
        Req_freq_2=single(0.1);
        Freq_2=single(0.1);
        Rr_dash=single(0.1);
        Lm_dash=single(0.1);
        Llk_dash=single(0.1);
        Rr_motor=single(0.1);
        Lm_motor=single(0.1);
        high_Freq_inj_test=single(0);

    case 17

        if openloop_test_flag==single(0)

            flagNextVal=single(6);
            delay=single(3);
            flag=single(0);
            samplesPerHalfCycle=single(uint16(0.5*(1/(Ts*injFreq))));
            numWaves=single(5);
            savedTimeInstance=curTime;
        else
            count1=single(0);
            count2=single(0);
            sinIdx=single(1);
            refSignal=single(0);
            Sig1=single(0);
            Sig2=single(0);
            savedTimeInstance=curTime;
            flagNextVal=single(18);
            delay=single(1);
            flag=single(0);
            openloop_test_flag=single(0);

        end

    case 18

        refSignal=algoVar(1);
        Sig1=single(0);
        Sig2=single(0);
        savedTimeInstance=curTime;
        flagNextVal=single(4);
        delay=single(1);
        flag=single(0);
        testNum=single(2);

    end
    testNumOut=testNum;
    injFreqOut=injFreq;
    refSignalOut=refSignal;
    estimatedParameterOut=estimatedParameter;
    testEnableOut=testEnable;
    estParIdxOut=estParIdx;
    Kp_iOut=Kp_i;
    Ki_iOut=Ki_i;



