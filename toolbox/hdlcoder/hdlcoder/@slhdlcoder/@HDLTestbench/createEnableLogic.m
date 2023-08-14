function delay_out=createEnableLogic(this,hD,topN,globalSigs,snkDone,rdEnb)






    inputdatainterval=this.getInputDataInterval;

    globalClkEn=globalSigs(3);
    global_reset=globalSigs(2);
    resetn=topN.addSignal(global_reset.Type,'resetn');
    pirelab.getLogicComp(topN,global_reset,resetn,'not');
    snkDonen=topN.addSignal(snkDone.Type,'snkDonen');
    pirelab.getLogicComp(topN,snkDone,snkDonen,'not');
    tb_enb=topN.addSignal(snkDone.Type,'tb_enb');
    resetValue=hD.getParameter('force_reset_value');
    if resetValue==0
        pirelab.getLogicComp(topN,[global_reset,snkDonen],tb_enb,'and');
    else
        pirelab.getLogicComp(topN,[resetn,snkDonen],tb_enb,'and');
    end

    tb_enb_delay=topN.addSignal(snkDone.Type,'tb_enb_delay');
    delay_out=tb_enb_delay;
    compName=[hD.getParameter('instance_prefix'),'enable_delay'];
    enableDelay=this.getEnableDelay(hD);
    createPipelineRegComp(topN,enableDelay,tb_enb,tb_enb_delay,globalSigs(1),...
    global_reset,compName);
    multiClockMode=~this.isDUTsingleClock;
    tHold=hD.getParameter('force_hold_time');

    if inputdatainterval>1
        tcCtrSize=ceil(log2(inputdatainterval));
        tcType=topN.getType('FixedPoint','Signed',0,'WordLength',tcCtrSize);
        ctrOutS=topN.addSignal(tcType,'counter');


        pireml.getCounterComp(...
        'Network',topN,...
        'OutputSignal',ctrOutS,...
        'OutputSimulinkRate',ctrOutS.SimulinkRate,...
        'Name','slow_clock_enable',...
        'InitialValue',1,...
        'CountFromValue',0,...
        'CountToValue',inputdatainterval-1,...
        'LimitedCounterOptimize',0,...
        'ClockEnableSignal',tb_enb_delay);



        if this.isCEasDataValid&&inputdatainterval>this.clkrate
            phaseV{1}=0;
            if iscell(this.phaseVector)
                for i=1:length(this.phaseVector)
                    phaseV{end+1}=this.phaseVector{i}+inputdatainterval;%#ok<AGROW>
                end
            else
                phaseV{2}=this.phaseVector;
            end
        else
            phaseV=this.phaseVector;
        end

        phaseSigs=hdlhandles(length(phaseV),1);
        for ii=1:length(phaseV)
            if iscell(phaseV)
                phase=phaseV{ii};
                splitVector=false;
            else
                phase=phaseV(ii);
                splitVector=true;
            end
            if multiClockMode
                phaseSigs(ii)=globalSigs(3);
            else
                if all(phase>=0)
                    phaseSigs(ii)=counterPhaseDecoder(topN,phase,inputdatainterval,...
                    ctrOutS,tb_enb_delay,splitVector);
                end
            end
        end




        idx=1;
        uniqueSampleTime=this.tbRates;
        numInputRates=numel(uniqueSampleTime);
        for ii=1:numel(this.InportSrc)
            for jj=1:numInputRates
                if this.InportSrc(ii).HDLSampleTime==uniqueSampleTime(jj)
                    idx=jj;
                    break;
                end
            end
            this.InportSrc(ii).ClockEnable=this.InportSrc(ii).dataRdEnb;
            this.InportSrc(ii).dataRdEnb=phaseSigs(idx);
        end


        idx=[];
        uniqueSampleTime=this.tbRatesOut;
        for ii=1:numel(this.OutportSnk)
            for jj=1:numel(uniqueSampleTime)
                if this.OutportSnk(ii).HDLSampleTime==uniqueSampleTime(jj)
                    idx=jj+numInputRates;
                    break;
                end
            end
            if isempty(idx)


                idx=1;
            end
            outEnb=topN.findSignal('name',this.OutportSnk(ii).ClockEnable.Name);
            if~isempty(outEnb)
                this.OutportSnk(ii).dataRdEnb=outEnb;
            else
                this.OutportSnk(ii).dataRdEnb=phaseSigs(idx);
            end
        end

        if this.isCEasDataValid
            enbSig=phaseSigs(1);
        else
            enbSig=tb_enb_delay;
        end
        notDone=topN.addSignal(globalClkEn);
        notDone.Name='notDone';
        pirelab.getLogicComp(topN,[enbSig,snkDonen],notDone,'and');
        pirelab.getTBTimeDelayComp(topN,notDone,globalClkEn,tHold);
        delay_out=globalClkEn;
    else
        constFalse=topN.addSignal(snkDone.Type,'const_false');
        pirelab.getConstComp(topN,constFalse,false);

        pirelab.getSwitchComp(topN,[tb_enb_delay,constFalse],rdEnb,snkDone);
        pirelab.getTBTimeDelayComp(topN,rdEnb,globalClkEn,tHold);

        for ii=1:numel(this.InportSrc)
            this.InportSrc(ii).dataRdEnb=rdEnb;
        end
        for ii=1:numel(this.OutportSnk)
            this.OutportSnk(ii).dataRdEnb=rdEnb;
        end
    end

    if multiClockMode
        defaultName=hD.getParameter('ClockEnableName');


        allClkEn=this.clockTable(arrayfun(@(x)x.Kind==2,this.clockTable));
        tPeriod=hD.getParameter('force_clock_high_time')+...
        hD.getParameter('force_clock_low_time');
        for ii=1:numel(allClkEn)
            clkenb=topN.findSignal('name',allClkEn(ii).Name);
            if isempty(clkenb)
                clkenb=topN.addSignal(globalClkEn.Type,allClkEn(ii).Name);
            end
            if~isempty(clkenb.getDrivers)
                continue;
            end
            if strcmp(defaultName,allClkEn(ii).Name)
                pirelab.getWireComp(topN,globalClkEn,clkenb);
            elseif~strcmp(allClkEn(ii).Name,globalClkEn.Name)
                if~isempty(clkenb)&&numel(allClkEn)>1
                    pirelab.getTBTimeDelayComp(topN,tb_enb_delay,clkenb,...
                    tHold+tPeriod);
                    delay_out=clkenb;
                end
            end
        end
    end

    if this.isCEasDataValid&&inputdatainterval>1&&numel(phaseSigs)==1

        srcDone=topN.findSignal('name','srcDone');
        srcDoneDelay=topN.addSignal(srcDone);
        srcDoneDelay.Name=[srcDone.Name,'_delay'];
        pirelab.getUnitDelayComp(topN,srcDone,srcDoneDelay);

        constFalse=topN.addSignal(snkDone.Type,'const_false');
        pirelab.getConstComp(topN,constFalse,false);

        globalClkEn.disconnectDriver(globalClkEn.getDrivers);
        delayP=phaseSigs(1).getReceivers;
        phaseSigs(1).disconnectReceiver(delayP);
        ceAsDvEnb=topN.addSignal(srcDone);
        ceAsDvEnb.Name='ceAsDvEnb';
        pirelab.getSwitchComp(topN,[phaseSigs(1),constFalse],ceAsDvEnb,...
        srcDoneDelay);
        ceAsDvEnb.addReceiver(delayP);
        globalClkEn.addDriver(delayP.Owner.PirOutputPorts(1));
    end

    if hD.getParameter('force_clockenable')==0



        globalClkEn.disconnectDriver(globalClkEn.getDrivers);
    end
end




function hC=createPipelineRegComp(topN,delay,tb_enb,tb_enb_delay,...
    clock,reset,compName)
    if delay==0
        hC=pirelab.getWireComp(topN,tb_enb,tb_enb_delay,compName);
    else
        for ii=1:delay
            if ii==1
                inSig=tb_enb;
            else
                inSig=outSig;
            end
            if ii==delay
                outSig=tb_enb_delay;
            else
                outSig=topN.addSignal(tb_enb.Type,sprintf('%s_pipe%d',tb_enb.Name,ii));
            end


            hC=topN.addComponent2('kind','register','name',compName,...
            'datainput',inSig,'dataoutput',outSig,'clock',clock,'reset',reset,...
            'blockcomment',sprintf('Delay inside enable generation: register depth %d',delay));
        end
    end
end


function phaseSigOut=counterPhaseDecoder(topN,phase,count,ctrOutS,clkEnS,...
    splitVector)
    if length(phase)==1
        phase_inc=phase(1);
        fullLen=false;
    else
        if length(phase)==3&&phase(3)==count
            phase_inc=phase(2);
            fullLen=true;
        else
            phase_inc=abs(phase(2)-phase(1));
            fullLen=length(phase)==count;
        end
    end
    if phase_inc==1&&fullLen&&~splitVector
        phase_suffix='all';
        preservePhase=false;
    else
        phase_suffix=int2str(phase_inc);
        preservePhase=true;
    end

    bitT=topN.getType('Logic','WordLength',1);


    sigName=['phase_',phase_suffix];
    while~isempty(topN.findSignal('name',sigName))
        sigName=['alpha_',sigName];%#ok<AGROW>
    end

    phaseSigOut=topN.addSignal(bitT,sigName);
    phaseSigOut.Preserve(preservePhase);

    if length(phase)==1

        compareVal=topN.addSignal(ctrOutS.Type,'tmp_phase');

        pirelab.getConstComp(topN,compareVal,phase);
        ctrS=topN.addSignal(bitT,['phase_',phase_suffix,'_ctr']);
        pirelab.getRelOpComp(topN,[ctrOutS,compareVal],ctrS,'==',...
        true,['phasesel_',int2str(phase)]);
        pirelab.getLogicComp(topN,[ctrS,clkEnS],phaseSigOut,'and');
    elseif fullLen&&phase_inc==1

        pirelab.getWireComp(topN,clkEnS,phaseSigOut);
    else

        allPhaseOut=topN.addSignal(bitT,['phase_',phase_suffix,'_all']);
        pirelab.getTBCounterModComp(topN,ctrOutS,allPhaseOut,phase_inc);



        selPhaseS=topN.addSignal(bitT,['phase_',phase_suffix,'_valid']);
        pirelab.getLogicComp(topN,[allPhaseOut,clkEnS],selPhaseS,'and');
        pirelab.getWireComp(topN,selPhaseS,phaseSigOut);
    end
end



