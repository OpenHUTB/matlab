function[testNumOut,injFreqOut,refSignalOut,estimatedParameterOut,testEnableOut,estParIdxOut,Kp_iOut,Ki_iOut]=estimateMotorParamAlgoExpo(SignalsPU,Ts,curTime,RsMeasTestTime,I_rated,pole_pairs,Rs,Ld,R_board,V_rated,currentPU_RWV,sigma,IaIbVdc,inverter_V_max,speedFB,speed_rated,Vd_ref_Rs,freqMin,freqMax,freqStep)









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

    persistent phaseDiffDeg;
    if isempty(phaseDiffDeg)
        phaseDiffDeg=single(0);
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

    persistent injFreqMin;
    if isempty(injFreqMin)
        injFreqMin=single(freqMin);
    end

    persistent injFreqMax;
    if isempty(injFreqMax)
        injFreqMax=single(freqMax);
    end

    persistent injFreq;
    if isempty(injFreq)
        injFreq=injFreqMax;
    end

    persistent lambda;
    if isempty(lambda)
        lambda=single(0);
    end

    persistent speed_mech_rpm;
    if isempty(speed_mech_rpm)
        speed_mech_rpm=single(0);
    end

    persistent speed_radPerSec;
    if isempty(speed_radPerSec)
        speed_radPerSec=single(0);
    end

    persistent injFreqStep;
    if isempty(injFreqStep)
        injFreqStep=single(freqStep);
    end

    persistent numInjFreq;
    if isempty(numInjFreq)
        numInjFreq=single(10);
    end

    persistent estL;
    if isempty(estL)
        estL=single(0);
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

    persistent arraySine;
    if isempty(arraySine)
        arraySine=single(zeros(1000,1));
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



    if testNum>0&&testEnable
        if abs(IaIbVdc(1))*currentPU_RWV>I_rated||abs(IaIbVdc(2))*currentPU_RWV>I_rated
            flag=single(15);
            errorID=single(1);
        elseif IaIbVdc(3)*inverter_V_max<0.8*V_rated
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


        refSignal=single(Vd_ref_Rs);
        Sig1=single(0);
        Sig2=single(0);
        savedTimeInstance=curTime;
        flagNextVal=single(4);
        delay=single(0.5);
        flag=single(0);
        estParIdx=single(1);
        testNum=single(1);


    case 4


        if curTime<savedTimeInstance+RsMeasTestTime
            Sig1=Sig1+single(SignalsPU(1)*1e-3);
            Sig2=Sig2+single(SignalsPU(2)*1e-3);
        else
            flagNextVal=single(5);
            delay=single(0.1);
            flag=single(0);
            savedTimeInstance=curTime;
        end


    case 5

        Sig1=(Sig1*voltagePU_RWV/(RsMeasTestTime*1e-3/Ts));
        Sig2=Sig2*currentPU_RWV/(RsMeasTestTime*1e-3/Ts);
        estimatedParameter=single(Sig1/Sig2)-R_board;
        estParIdx=single(2);
        samplesPerHalfCycle=single(uint16(0.5*(1/(Ts*injFreq))));
        Sig1=single(0);
        Sig2=single(0);
        numWaves=single(5);

        savedTimeInstance=curTime;
        flagNextVal=single(7);
        delay=single(0.5);
        flag=single(0);

        testNum=single(2);

    case 7



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
                flagNextVal=single(8);
                flag=flagNextVal;
            end
        else
            sinIdx=sinIdx+single(1);
        end


    case 8





        if(max-min)*pi*0.5<0.5*I_rated&&injFreq>injFreqMin
            flagNextVal=single(7);

            injFreq=injFreq-100;
            samplesPerHalfCycle=single(uint16(0.5*(1/(Ts*injFreq))));
        else
            flagNextVal=single(9);
            if injFreq==single(injFreqMax)

                injFreqStep=injFreqStep*(-1);
            end
            numWaves=single(8);
        end
        delay=single(0.2);
        flag=single(0);
        savedTimeInstance=curTime;
        count1=single(0);
        count2=single(0);
        Sig1=single(0);
        Sig2=single(0);
        sinIdx=single(1);

    case 9



        SignalsPU(1)=single(SignalsPU(1))*voltagePU_RWV;
        SignalsPU(2)=single(SignalsPU(2))*currentPU_RWV;

        Sig1=Sig1+((single(SignalsPU(1))-arraySine(sinIdx))/samplesPerHalfCycle);
        Sig2=Sig2+((single(SignalsPU(2))-arraySine(sinIdx+500))/samplesPerHalfCycle);
        arraySine(sinIdx)=single(SignalsPU(1));
        arraySine(sinIdx+500)=single(SignalsPU(2));

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

            flagNextVal=single(10);
            flag=flagNextVal;
            count1=single(0);
            count2=single(0);
            numWaves=single(5);
            Sig1Prev=Sig1;
            Sig2Prev=Sig2;
        end


    case 10

        SignalsPU(1)=single(SignalsPU(1))*voltagePU_RWV;
        SignalsPU(2)=single(SignalsPU(2))*currentPU_RWV;

        Sig1=Sig1+((single(SignalsPU(1))-arraySine(sinIdx))/samplesPerHalfCycle);
        Sig2=Sig2+((single(SignalsPU(2))-arraySine(sinIdx+500))/samplesPerHalfCycle);

        arraySine(sinIdx)=single(SignalsPU(1));
        arraySine(sinIdx+500)=single(SignalsPU(2));
        if sinIdx>=samplesPerHalfCycle
            sinIdx=single(1);
        else
            sinIdx=sinIdx+single(1);
        end


        if Sig1>Sig1Mean&&Sig1Prev<Sig1Mean
            timeInstance1=curTime-(Ts*((Sig1-Sig1Mean)/(Sig1-Sig1Prev)));
            count2=single(1);

        elseif Sig2>Sig2Mean&&Sig2Prev<Sig2Mean&&count2
            timeInstance2=curTime-(Ts*((Sig2-Sig2Mean)/(Sig2-Sig2Prev)))-(2*Ts);


            phaseDiffDeg=phaseDiffDeg+((timeInstance2-timeInstance1)*injFreq*2*pi);
            count1=count1+single(1);
            if(count1<numInjFreq)
                count2=single(0);
            else
                estL=estL+tan(phaseDiffDeg/numInjFreq)*(Rs+R_board)/(injFreq*2*pi);

                injFreq=injFreq+injFreqStep;
                samplesPerHalfCycle=single(uint16(0.5*(1/(Ts*injFreq))));
                numWaves=single(8);

                flagNextVal=single(9);
                delay=single(0.2);
                flag=single(0);


                savedTimeInstance=curTime;
                sinIdx=single(1);
                count1=single(0);
                count2=single(0);
                phaseDiffDeg=single(0);
                Sig1=single(0);
                Sig2=single(0);
                Sig1Mean=single(0);
                Sig2Mean=single(0);
                arraySine=single(zeros(1000,1));
                count3=count3+single(1);
                if count3>=numInjFreq
                    estimatedParameter=single(estL/numInjFreq);
                    estL=single(0);
                    if testNum==2
                        estParIdx=single(3);
                        testNum=single(3);
                        flagNextVal=single(7);
                        if injFreqStep<0
                            injFreqStep=injFreqStep*(-1);
                        end
                        delay=single(0.5);
                        flag=single(0);
                        injFreq=single(injFreqMax);
                        samplesPerHalfCycle=single(uint16(0.5*(1/(Ts*injFreq))));
                        numWaves=single(5);

                    else
                        estParIdx=single(4);
                        flagNextVal=single(11);
                        delay=single(5);
                        flag=single(0);
                        testNum=single(4);
                        refSignal=single(0.9);
                        numWaves=single(60000);


                        Kp_i=single((Ld/(2*sigma*1e-6))*(currentPU_RWV/voltagePU_RWV));
                        Ki_i=single(((Rs+R_board)/(2*sigma*1e-6))*(currentPU_RWV/voltagePU_RWV));


                    end

                    count3=single(0);
                end
            end
        end
        Sig1Prev=Sig1;
        Sig2Prev=Sig2;


    case 11

        Sig1Mean=Sig1Mean+(SignalsPU(1)-SignalsPU(2));
        Sig2Mean=Sig2Mean+SignalsPU(3);
        Sig3Mean=Sig3Mean+SignalsPU(4);
        Sig4Mean=Sig4Mean+SignalsPU(5);
        Sig5Mean=Sig5Mean+SignalsPU(6);

        count2=count2+1;
        if count2>numWaves
            Sig1Mean=Sig1Mean*voltagePU_RWV/count2;
            Sig2Mean=Sig2Mean*voltagePU_RWV/count2;
            Sig3Mean=Sig3Mean*currentPU_RWV/count2;
            Sig4Mean=Sig4Mean*voltagePU_RWV/count2;
            Sig5Mean=Sig5Mean*currentPU_RWV/count2;
            flagNextVal=single(12);
            flag=flagNextVal;
            count2=single(0);
            Sig1Prev=(SignalsPU(1)-SignalsPU(2))*voltagePU_RWV;
        end
    case 12

        Sig1=(SignalsPU(1)-SignalsPU(2))*voltagePU_RWV;
        if Sig1>Sig1Mean&&Sig1Prev<Sig1Mean
            if~count2
                timeInstance1=curTime-(Ts*((Sig1-Sig1Mean)/(Sig1-Sig1Prev)));
                count2=single(1);
            else
                timeInstance2=curTime-(Ts*((Sig1-Sig1Mean)/(Sig1-Sig1Prev)));
                injFreq=1/(timeInstance2-timeInstance1);
                samplesPerHalfCycle=single(uint16(0.5*(1/(Ts*injFreq))));






                lambda=(Sig4Mean-(Rs)*Sig5Mean-Ld*Sig3Mean*(injFreq*2*pi))/(injFreq*2*pi);
                estimatedParameter=sqrt(3)*(lambda*(injFreq*2*pi))/((60*injFreq/pole_pairs)*1e-3);
                estParIdx=single(5);
                count2=single(0);
                Sig1=single(0);
                flagNextVal=single(13);

                savedTimeInstance=curTime;
                delay=single(0.02);
                flag=single(0);

                speed_radPerSec=(60*injFreq/pole_pairs)*2*pi/60;
                testEnable=single(0);
                count1=curTime;
            end
        end
        Sig1Prev=Sig1;
    case 13
        if abs(speedFB*speed_rated)<(0.25*speed_rated)
            speed_mech_rpm=single(0.25*speed_rated);
            timeInstance2=curTime;













            estimatedParameter=((3/2*((Sig2Mean*Sig3Mean)+(Sig4Mean*Sig5Mean)))-...
            (3/2*(Sig5Mean^2+Sig3Mean^2)*(Rs)))/...
            (((speed_radPerSec-(speed_mech_rpm*2*pi/60))/...
            (timeInstance2-count1))*(speed_radPerSec));
            estParIdx=single(6);
            flagNextVal=single(14);
            savedTimeInstance=curTime;
            delay=single(0.5);
            flag=single(0);
        end
    case 14







        estimatedParameter=((3/2)*pole_pairs*(lambda*Sig5Mean))/speed_radPerSec;
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
        phaseDiffDeg=single(0);
        flagNextVal=single(1);
        delay=single(1);
        estimatedParameter=single(0);
        voltagePU_RWV=single(V_rated/sqrt(3));
        Kp_i=single(0);
        Ki_i=single(0);
        testNum=single(0);
        testEnable=single(1);
        injFreqMin=single(400);
        injFreqMax=single(1000);
        injFreq=injFreqMax;
        lambda=single(0);
        speed_mech_rpm=single(0);
        speed_radPerSec=single(0);
        injFreqStep=single(10);
        numInjFreq=single(10);
        estL=single(0);
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
        arraySine=single(zeros(1000,1));
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
    end
    testNumOut=testNum;
    injFreqOut=injFreq;
    refSignalOut=refSignal;
    estimatedParameterOut=estimatedParameter;
    testEnableOut=testEnable;
    estParIdxOut=estParIdx;
    Kp_iOut=Kp_i;
    Ki_iOut=Ki_i;

