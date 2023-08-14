function OneDFilterNet=elab1DFIR(this,topNet,blockInfo,dataRate)






    inportnames={'YIn','CbIn','CrIn','hStartIn','hEndIn','vStartIn','vEndIn','validIn'};
    outportnames={'YOut','CbOut','CrOut','hStartOut','hEndOut','vStartOut','vEndOut','validOut'};


    insignals=topNet.PirInputSignals;
    pixelIn=insignals(1);
    pixelInSplit=pixelIn.split;
    dataType=pixelInSplit.PirOutputSignal(1).Type;

    ctrlType=pir_boolean_t();
    OneDFilterNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','AntialiasingFilter',...
    'InportNames',inportnames,...
    'InportTypes',[dataType,dataType,dataType,ctrlType,ctrlType,ctrlType,ctrlType,ctrlType],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'OutportNames',outportnames,...
    'OutportTypes',[dataType,dataType,dataType,ctrlType,ctrlType,ctrlType,ctrlType,ctrlType]);


    YIn=OneDFilterNet.PirInputSignals(1);
    CbIn=OneDFilterNet.PirInputSignals(2);
    CrIn=OneDFilterNet.PirInputSignals(3);
    hStartIn=OneDFilterNet.PirInputSignals(4);
    hEndIn=OneDFilterNet.PirInputSignals(5);
    vStartIn=OneDFilterNet.PirInputSignals(6);
    vEndIn=OneDFilterNet.PirInputSignals(7);
    validIn=OneDFilterNet.PirInputSignals(8);

    YOut=OneDFilterNet.PirOutputSignals(1);
    CbOut=OneDFilterNet.PirOutputSignals(2);
    CrOut=OneDFilterNet.PirOutputSignals(3);
    hStartOut=OneDFilterNet.PirOutputSignals(4);
    hEndOut=OneDFilterNet.PirOutputSignals(5);
    vStartOut=OneDFilterNet.PirOutputSignals(6);
    vEndOut=OneDFilterNet.PirOutputSignals(7);
    validOut=OneDFilterNet.PirOutputSignals(8);


    blockInfo.padL=(numel(blockInfo.Coefficients)-1)/2;

    if blockInfo.padL~=0


        a=OneDFilterNet.addSignal(ctrlType,'a');
        b=OneDFilterNet.addSignal(ctrlType,'b');
        c=OneDFilterNet.addSignal(ctrlType,'c');
        d=OneDFilterNet.addSignal(ctrlType,'d');
        hStartDelay=OneDFilterNet.addSignal(ctrlType,'hStartDelay');
        EqualDelay=OneDFilterNet.addSignal(ctrlType,'EqualDelay');
        pirelab.getLogicComp(OneDFilterNet,[validIn,hStartIn],a,'and');
        pirelab.getLogicComp(OneDFilterNet,[validIn,hStartDelay],b,'and');
        pirelab.getLogicComp(OneDFilterNet,[validIn,hEndIn],c,'and');
        pirelab.getLogicComp(OneDFilterNet,[a,EqualDelay],d,'or');

        S0=OneDFilterNet.addSignal(ctrlType,'S0');
        S1=OneDFilterNet.addSignal(ctrlType,'S1');
        S0NOT=OneDFilterNet.addSignal(ctrlType,'S0NOT');
        S1NOT=OneDFilterNet.addSignal(ctrlType,'S1NOT');
        pirelab.getLogicComp(OneDFilterNet,S0,S0NOT,'not');
        pirelab.getLogicComp(OneDFilterNet,S1,S1NOT,'not');

        StateIs0=OneDFilterNet.addSignal(ctrlType,'StateIs0');
        StateIs1=OneDFilterNet.addSignal(ctrlType,'StateIs1');
        StateIs2=OneDFilterNet.addSignal(ctrlType,'StateIs2');
        pirelab.getLogicComp(OneDFilterNet,[S0NOT,S1NOT],StateIs0,'and');
        pirelab.getLogicComp(OneDFilterNet,[S0,S1NOT],StateIs1,'and');
        pirelab.getLogicComp(OneDFilterNet,[S0NOT,S1],StateIs2,'and');

        FSMEnable=OneDFilterNet.addSignal(ctrlType,'FSMEnable');
        pirelab.getLogicComp(OneDFilterNet,[a,b,c,d],FSMEnable,'or');

        S0Next=OneDFilterNet.addSignal(ctrlType,'S0Next');
        S0Next.SimulinkRate=dataRate;
        S1Next=OneDFilterNet.addSignal(ctrlType,'S1Next');
        S1Next.SimulinkRate=dataRate;
        pirelab.getUnitDelayEnabledComp(OneDFilterNet,S0Next,S0,FSMEnable,'FSMS0',false,'',false);
        pirelab.getUnitDelayEnabledComp(OneDFilterNet,S1Next,S1,FSMEnable,'FSMS1',false,'',false);

        S1NextOR1=OneDFilterNet.addSignal(ctrlType,'S1NextOR1');
        S1NextOR2=OneDFilterNet.addSignal(ctrlType,'S1NextOR2');
        pirelab.getLogicComp(OneDFilterNet,[S1NextOR1,S1NextOR2],S1Next,'or');
        aNOT=OneDFilterNet.addSignal(ctrlType,'aNOT');
        pirelab.getLogicComp(OneDFilterNet,a,aNOT,'not');
        dNOT=OneDFilterNet.addSignal(ctrlType,'dNOT');
        pirelab.getLogicComp(OneDFilterNet,d,dNOT,'not');
        pirelab.getLogicComp(OneDFilterNet,[aNOT,StateIs1,c],S1NextOR1,'and');
        pirelab.getLogicComp(OneDFilterNet,[dNOT,StateIs2,c],S1NextOR2,'and');

        S0NextOR1=OneDFilterNet.addSignal(ctrlType,'S0NextOR1');
        S0NextOR2=OneDFilterNet.addSignal(ctrlType,'S0NextOR2');
        pirelab.getLogicComp(OneDFilterNet,[S0NextOR1,S0NextOR2],S0Next,'or');
        StateIs0ANDb=OneDFilterNet.addSignal(ctrlType,'StateIs0ANDb');
        pirelab.getLogicComp(OneDFilterNet,[StateIs0,b],StateIs0ANDb,'and');
        pirelab.getLogicComp(OneDFilterNet,[StateIs0ANDb,aNOT],S0NextOR1,'and');
        cNOT=OneDFilterNet.addSignal(ctrlType,'cNOT');
        pirelab.getLogicComp(OneDFilterNet,c,cNOT,'not');
        pirelab.getLogicComp(OneDFilterNet,[StateIs1,cNOT,b],S0NextOR2,'and');

        ShiftEn=OneDFilterNet.addSignal(ctrlType,'EnableShifting');
        pirelab.getLogicComp(OneDFilterNet,[validIn,StateIs2],ShiftEn,'or');


        EqualDelayNOT=OneDFilterNet.addSignal(ctrlType,'EqualDelayNOT');
        pirelab.getLogicComp(OneDFilterNet,EqualDelay,EqualDelayNOT,'not');
        CtEnable=OneDFilterNet.addSignal(ctrlType,'CounterEnable');
        CtEnable.SimulinkRate=dataRate;
        pirelab.getLogicComp(OneDFilterNet,[StateIs2,EqualDelayNOT],CtEnable,'and');

        CtType=pir_unsigned_t(ceil(log2(blockInfo.padL+1)));
        ChromaSel=OneDFilterNet.addSignal(CtType,'ChromaSel');
        Equal=OneDFilterNet.addSignal(ctrlType,'Equal');
        Equal.SimulinkRate=dataRate;


        if blockInfo.padL==1
            pirelab.getWireComp(OneDFilterNet,CtEnable,ChromaSel);
            pirelab.getWireComp(OneDFilterNet,CtEnable,Equal);
        else
            CtReset=OneDFilterNet.addSignal(ctrlType,'CounterReset');
            CtReset.SimulinkRate=dataRate;
            pirelab.getLogicComp(OneDFilterNet,[StateIs1,validIn,hEndIn],CtReset,'and');

            CtOutput=OneDFilterNet.addSignal(CtType,'CounterOutput');
            CtOutput.SimulinkRate=dataRate;
            pirelab.getCounterComp(OneDFilterNet,[CtReset,CtEnable],CtOutput,...
            'Count limited',...
            1,...
            1,...
            blockInfo.padL,...
            1,...
            0,...
            1,...
            0,...
            'Counter');
            EqualNext=OneDFilterNet.addSignal(ctrlType,'EqualNext');
            pirelab.getCompareToValueComp(OneDFilterNet,CtOutput,EqualNext,'==',blockInfo.padL);
            pirelab.getLogicComp(OneDFilterNet,[EqualNext,CtEnable],Equal,'and');

            ZeroConst=OneDFilterNet.addSignal(CtType,'ZeroConst');
            pirelab.getConstComp(OneDFilterNet,ZeroConst,0);
            pirelab.getSwitchComp(OneDFilterNet,[ZeroConst,CtOutput],ChromaSel,CtEnable);
        end
        pirelab.getUnitDelayComp(OneDFilterNet,Equal,EqualDelay);





        StateIs1ANDvalidIn=OneDFilterNet.addSignal(ctrlType,'StateIs1ANDvalidIn');
        pirelab.getLogicComp(OneDFilterNet,[StateIs1,validIn],StateIs1ANDvalidIn,'and');

        validOutNext=OneDFilterNet.addSignal(ctrlType,'validOutNext');
        pirelab.getLogicComp(OneDFilterNet,[CtEnable,StateIs0ANDb,StateIs1ANDvalidIn],validOutNext,'or');

        validOut2Kernel=OneDFilterNet.addSignal(ctrlType,'validOut2Kernel');
        pirelab.getUnitDelayComp(OneDFilterNet,validOutNext,validOut2Kernel);






        hStartBuf(1)=OneDFilterNet.addSignal(ctrlType,'hStartBuf1');
        pirelab.getWireComp(OneDFilterNet,hStartIn,hStartBuf(1));
        for ii=1:blockInfo.padL
            hStartBuf(ii+1)=OneDFilterNet.addSignal(ctrlType,['hStartBuf',num2str(ii+1)]);
            pirelab.getUnitDelayEnabledComp(OneDFilterNet,hStartBuf(ii),hStartBuf(ii+1),ShiftEn,['hStartBuf',num2str(ii+1)],...
            false,'',false);
        end
        pirelab.getWireComp(OneDFilterNet,hStartBuf(1+blockInfo.padL),hStartDelay);


        hStart2Kernel=OneDFilterNet.addSignal(ctrlType,'hStart2Kernel');
        pirelab.getUnitDelayEnabledComp(OneDFilterNet,hStartDelay,hStart2Kernel,ShiftEn,'hStartEnDelay',false,'',false);


        hEnd2Kernel=OneDFilterNet.addSignal(ctrlType,'hEnd2Kernel');

        hEndBuf(1)=OneDFilterNet.addSignal(ctrlType,'hEndBuf1');
        pirelab.getWireComp(OneDFilterNet,hEndIn,hEndBuf(1));
        for ii=1:blockInfo.padL+1
            hEndBuf(ii+1)=OneDFilterNet.addSignal(ctrlType,['hEndBuf',num2str(ii+1)]);
            pirelab.getUnitDelayEnabledComp(OneDFilterNet,hEndBuf(ii),hEndBuf(ii+1),ShiftEn,['hEndBuf',num2str(ii+1)],...
            false,'',false);
        end
        pirelab.getWireComp(OneDFilterNet,hEndBuf(2+blockInfo.padL),hEnd2Kernel);



        vStart2Kernel=OneDFilterNet.addSignal(ctrlType,'vStart2Kernel');

        vStartBuf(1)=OneDFilterNet.addSignal(ctrlType,'vStartBuf1');
        pirelab.getWireComp(OneDFilterNet,vStartIn,vStartBuf(1));
        for ii=1:blockInfo.padL+1
            vStartBuf(ii+1)=OneDFilterNet.addSignal(ctrlType,['vStartBuf',num2str(ii+1)]);
            pirelab.getUnitDelayEnabledComp(OneDFilterNet,vStartBuf(ii),vStartBuf(ii+1),ShiftEn,['vStartBuf',num2str(ii+1)],...
            false,'',false);
        end
        pirelab.getWireComp(OneDFilterNet,vStartBuf(2+blockInfo.padL),vStart2Kernel);



        vEnd2Kernel=OneDFilterNet.addSignal(ctrlType,'vEnd2Kernel');

        vEndBuf(1)=OneDFilterNet.addSignal(ctrlType,'vEndBuf1');
        pirelab.getWireComp(OneDFilterNet,vEndIn,vEndBuf(1));
        for ii=1:blockInfo.padL+1
            vEndBuf(ii+1)=OneDFilterNet.addSignal(ctrlType,['vEndBuf',num2str(ii+1)]);
            pirelab.getUnitDelayEnabledComp(OneDFilterNet,vEndBuf(ii),vEndBuf(ii+1),ShiftEn,['vEndBuf',num2str(ii+1)],...
            false,'',false);
        end
        pirelab.getWireComp(OneDFilterNet,vEndBuf(2+blockInfo.padL),vEnd2Kernel);



        Y2Kernel=OneDFilterNet.addSignal(dataType,'Y2Kernel');

        YBuf(1)=OneDFilterNet.addSignal(dataType,'YBuf1');
        pirelab.getWireComp(OneDFilterNet,YIn,YBuf(1));
        for ii=1:blockInfo.padL+1
            YBuf(ii+1)=OneDFilterNet.addSignal(dataType,['YBuf',num2str(ii+1)]);%#ok
            pirelab.getUnitDelayEnabledComp(OneDFilterNet,YBuf(ii),YBuf(ii+1),ShiftEn,['YBuf',num2str(ii+1)],...
            false,'',false);
        end
        pirelab.getWireComp(OneDFilterNet,YBuf(2+blockInfo.padL),Y2Kernel);



        CbSwitchOut=OneDFilterNet.addSignal(dataType,'SwitchOut_CbIn');
        CrSwitchOut=OneDFilterNet.addSignal(dataType,'SwitchOut_CrIn');

























        for ii=1:blockInfo.padL+1
            Cbtemp(ii)=OneDFilterNet.addSignal(dataType,['CbShift',num2str(ii)]);%#ok
            Crtemp(ii)=OneDFilterNet.addSignal(dataType,['CrShift',num2str(ii)]);%#ok
            if ii==1
                pirelab.getUnitDelayEnabledComp(OneDFilterNet,CbSwitchOut,Cbtemp(ii),ShiftEn,['CbShift',num2str(ii)],...
                false,'',false);
                pirelab.getUnitDelayEnabledComp(OneDFilterNet,CrSwitchOut,Crtemp(ii),ShiftEn,['CrShift',num2str(ii)],...
                false,'',false);
            else
                pirelab.getUnitDelayEnabledComp(OneDFilterNet,Cbtemp(ii-1),Cbtemp(ii),ShiftEn,['CbShift',num2str(ii)],...
                false,'',false);
                pirelab.getUnitDelayEnabledComp(OneDFilterNet,Crtemp(ii-1),Crtemp(ii),ShiftEn,['CrShift',num2str(ii)],...
                false,'',false);
            end
        end

        LPaddingSwitch=OneDFilterNet.addSignal(ctrlType,'LeftPaddingSwitch');
        pirelab.getLogicComp(OneDFilterNet,[StateIs0,hStartDelay],LPaddingSwitch,'and');

        for ii=1:blockInfo.padL
            switchout1=OneDFilterNet.addSignal(dataType,['Switch',num2str(ii),'CbOut']);
            pirelab.getSwitchComp(OneDFilterNet,[Cbtemp(blockInfo.padL+ii),Cbtemp(blockInfo.padL+1-ii)],switchout1,LPaddingSwitch);
            Cbtemp(1+blockInfo.padL+ii)=OneDFilterNet.addSignal(dataType,['CbOut',num2str(ii)]);
            pirelab.getUnitDelayEnabledComp(OneDFilterNet,switchout1,Cbtemp(1+blockInfo.padL+ii),ShiftEn);

            switchout2=OneDFilterNet.addSignal(dataType,['Switch',num2str(ii),'CrOut']);
            pirelab.getSwitchComp(OneDFilterNet,[Crtemp(blockInfo.padL+ii),Crtemp(blockInfo.padL+1-ii)],switchout2,LPaddingSwitch);
            Crtemp(1+blockInfo.padL+ii)=OneDFilterNet.addSignal(dataType,['CrOut',num2str(ii)]);
            pirelab.getUnitDelayEnabledComp(OneDFilterNet,switchout2,Crtemp(1+blockInfo.padL+ii),ShiftEn);
        end

        CbVector=CbIn;
        CrVector=CrIn;
        for ii=1:blockInfo.padL
            CbVector=[CbVector,Cbtemp(2*ii-1)];%#ok
            CrVector=[CrVector,Crtemp(2*ii-1)];%#ok
        end
        pirelab.getMultiPortSwitchComp(OneDFilterNet,...
        [ChromaSel,CbVector],...
        CbSwitchOut,...
        1,...
        1,...
        'floor',...
        'Wrap',...
        'CbInMux');
        pirelab.getMultiPortSwitchComp(OneDFilterNet,[ChromaSel,CrVector],...
        CrSwitchOut,1,1,'floor','Wrap','CrInMux');
    else
        Y2Kernel=OneDFilterNet.addSignal(dataType,'Y2Kernel');
        Cbtemp=OneDFilterNet.addSignal(dataType,'Cb2Kernel');
        Crtemp=OneDFilterNet.addSignal(dataType,'Cr2Kernel');
        hStart2Kernel=OneDFilterNet.addSignal(ctrlType,'hStart2Kernel');
        hEnd2Kernel=OneDFilterNet.addSignal(ctrlType,'hEnd2Kernel');
        vStart2Kernel=OneDFilterNet.addSignal(ctrlType,'vStart2Kernel');
        vEnd2Kernel=OneDFilterNet.addSignal(ctrlType,'vEnd2Kernel');
        validOut2Kernel=OneDFilterNet.addSignal(ctrlType,'validOut2Kernel');

        pirelab.getUnitDelayComp(OneDFilterNet,YIn,Y2Kernel);
        pirelab.getUnitDelayComp(OneDFilterNet,CbIn,Cbtemp);
        pirelab.getUnitDelayComp(OneDFilterNet,CrIn,Crtemp);
        pirelab.getUnitDelayComp(OneDFilterNet,hStartIn,hStart2Kernel);
        pirelab.getUnitDelayComp(OneDFilterNet,hEndIn,hEnd2Kernel);
        pirelab.getUnitDelayComp(OneDFilterNet,vStartIn,vStart2Kernel);
        pirelab.getUnitDelayComp(OneDFilterNet,vEndIn,vEnd2Kernel);
        pirelab.getUnitDelayComp(OneDFilterNet,validIn,validOut2Kernel);
    end




    pFimath=fimath('RoundingMethod',blockInfo.RoundingMethod,...
    'OverflowAction',blockInfo.OverflowAction);
    blockInfo.coeffs=fi(fliplr(blockInfo.Coefficients),...
    blockInfo.CustomCoefficientsDataType,...
    pFimath);


    sigInfo.DataInType=dataType;
    sigInfo.ctlType=ctrlType;
    sigInfo.inRate=dataRate;
    sigInfo.DataOutType=dataType;

    filterKernelNet=this.elabFIRFilterKernel(OneDFilterNet,blockInfo,sigInfo);
    filterKernelNet.addComment('Apply FIR Kernel');
    if numel(blockInfo.coeffs)==1
        filterKernelNet.addComment(['Kernel coefficient is:'...
        ,sprintf('\n')...
        ,sprintf('\t%f\n',double(blockInfo.coeffs))]);
    elseif numel(blockInfo.coeffs)>2
        filterKernelNet.addComment(['Kernel coefficients are:'...
        ,sprintf('\n')...
        ,sprintf('\t%f\n',double(blockInfo.coeffs))]);
    end
    filterKernelNet.addComment(['Kernel coefficients will be examined to minimize the number of inferred',char(10)...
    ,'multiplication units. For example, given a kernel of five elements',char(10)...
    ,'[0.1 0.2 0.4 0.2 0.1] and input [CbDelay4 CbDelay3 CbDelay2 CbDelay1 Cb],',char(10)...
    ,'the expected Cb output is',char(10),char(10)...
    ,'    CbDelay4*0.1 + CbDelay3*0.2 + CbDelay2*0.4 + CbDelay1*0.2 + Cb*0.1.',char(10),char(10)...
    ,'This expression can be rewritten as',char(10),char(10)...
    ,'    (Cb+CbDelay4)*0.1 + (CbDelay1+CbDelay3)*0.2 + CbDelay2*0.4,',char(10),char(10)...
    ,'inferring only three multiplication units. The intermediate results',char(10)...
    ,'(Cb+CbDelay4) and (CbDelay1+CbDelay3) are calculated using PreAdders,',char(10)...
    ,'while the summation of (Cb+CbDelay4)*0.1, (CbDelay1+CbDelay3)*0.2, and',char(10)...
    ,'CbDelay2*0.4 is performed by PostAdders. Y and five control signals will',char(10)...
    ,'be passed through with appropriate delays.']);
    pirelab.instantiateNetwork(OneDFilterNet,filterKernelNet,...
    [Cbtemp,Crtemp,Y2Kernel,hStart2Kernel,hEnd2Kernel,vStart2Kernel,vEnd2Kernel,validOut2Kernel],...
    [CbOut,CrOut,YOut,hStartOut,hEndOut,vStartOut,vEndOut,validOut],...
    'fir_inst');




















