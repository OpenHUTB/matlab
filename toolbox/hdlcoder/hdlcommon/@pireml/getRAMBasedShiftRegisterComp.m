function[RamNet,RamComp]=getRAMBasedShiftRegisterComp(hN,hSignalsIn,hSignalsOut,...
    delayNumber,thresholdSize,compName,resetnone,ramName,RamNet)













    if(nargin<5)||isempty(thresholdSize)
        thresholdSize=32;
    end

    if(nargin<6)||isempty(compName)
        compName='shift_reg';
    end

    if(nargin<7)||isempty(resetnone)
        resetnone=false;
    end

    if(nargin<8)||isempty(ramName)
        ramName='ShiftRegisterRAM';
    end

    if(nargin<9)
        RamNet='';
    end


    if thresholdSize<4
        thresholdSize=4;
    end

    if delayNumber>=thresholdSize





        dataType=hSignalsIn.Type;
        ufix1Type=pir_ufixpt_t(1,0);
        addrWidth=ceil(log2(double(delayNumber)));
        addrType=pir_ufixpt_t(addrWidth,0);


        waddr=hN.addSignal(addrType,sprintf('%s_waddr',compName));
        waddrComp=pireml.getCounterComp(...
        'Network',hN,...
        'OutputSignal',waddr,...
        'OutputSimulinkRate',hSignalsIn.SimulinkRate,...
        'Name',sprintf('%s_wr',compName),...
        'InitialValue',0,...
        'CountToValue',delayNumber-3);
        waddrComp.addComment(sprintf('Write address counter for RAM-based shift register %s',compName));


        raddr=hN.addSignal(addrType,sprintf('%s_raddr',compName));
        raddrComp=pireml.getCounterComp(...
        'Network',hN,...
        'OutputSignal',raddr,...
        'OutputSimulinkRate',hSignalsIn.SimulinkRate,...
        'Name',sprintf('%s_rd',compName),...
        'InitialValue',1,...
        'CountToValue',delayNumber-3,...
        'CountFromValue',0);
        raddrComp.addComment(sprintf('Read address counter for RAM-based shift register %s',compName));


        regin=hN.addSignal(dataType,sprintf('%s_regin',compName));
        reginComp=pireml.getUnitDelayComp(hN,hSignalsIn,regin,sprintf('%s_reginc',compName),'',resetnone);
        reginComp.addComment(sprintf('Input register for RAM-based shift register %s',compName));


        wrenb=hN.addSignal(ufix1Type,sprintf('%s_wrenb',compName));
        wrenb.SimulinkRate=regin.SimulinkRate;
        pireml.getConstComp(hN,wrenb,1,sprintf('%s_wrenbc',compName));


        regout=hN.addSignal(dataType,sprintf('%s_regout',compName));
        hInSignals=[regin,waddr,wrenb,raddr];
        hOutSignals=regout;
        hOutSignals.SimulinkRate=regin.SimulinkRate;
        if isempty(RamNet)
            [RamNet,RamComp]=pirelab.getSimpleDualPortRamComp(hN,hInSignals,hOutSignals,ramName,1,-1,[]);
        else
            [RamNet,RamComp]=pirelab.getSimpleDualPortRamComp(hN,hInSignals,hOutSignals,ramName,1,-1,RamNet);
        end


        regoutComp=pireml.getUnitDelayComp(hN,regout,hSignalsOut,sprintf('%s_regoutc',compName),'',resetnone);
        regoutComp.addComment(sprintf('Output register for RAM-based shift register %s',compName));

    else


        RamComp=pireml.getIntDelayComp(hN,hSignalsIn,hSignalsOut,delayNumber,compName,'',resetnone);
        RamComp.addComment(sprintf('Shift register %s',compName));
        RamNet='';
    end


