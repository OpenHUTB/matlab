function testFailure=createOutputCheckerComps(this,hD,topN,outSigs,globalSigs)




    bitT=topN.getType('FixedPoint','Signed',0,'WordLength',1,'FractionLength',0);
    testFailures=hdlhandles(numel(outSigs),1);
    curSig=1;
    ignoreDataCycles=hD.getParameter('IgnoreDataChecking');
    if targetcodegen.targetCodeGenerationUtils.isFloatingPointMode()
        gp=pir();
        maxDutLatency=gp.getDutMaxLatency();

        if ignoreDataCycles>0
            if ignoreDataCycles<maxDutLatency
                warning(message('hdlcoder:engine:IdcLtDutLatency',num2str(ignoreDataCycles),...
                num2str(maxDutLatency)));
            end

        else
            ignoreDataCycles=maxDutLatency;
        end
    end
    multiClockMode=~this.isDUTsingleClock;

    allClk=this.clockTable(arrayfun(@(x)x.Kind==0,this.clockTable));
    clkSigs=hdlhandles(numel(allClk),1);
    for ii=1:numel(allClk)
        clkSigs(ii)=topN.findSignal('name',allClk(ii).Name);
    end
    allRst=this.clockTable(arrayfun(@(x)x.Kind==1,this.clockTable));
    rstSigs=hdlhandles(numel(allRst),1);
    for ii=1:numel(allClk)
        rstSigs(ii)=topN.findSignal('name',allRst(ii).Name);
    end



    clkIdx=1;
    rstIdx=1;

    for ii=1:numel(this.OutportSnk)
        outValid=getCeOut(this,topN,ii);
        outName=this.OutportSnk(ii).HDLPortName;
        if iscell(outName)&&numel(outName)==1&&iscell(outName{:})
            outName=outName{:};
        end
        dutOutSig=topN.findSignal('name',outName{1});
        if ignoreDataCycles>0
            check_enb=topN.addSignal(bitT,[outName{1},'_chkenb']);
            constOne=topN.addSignal(bitT,'constone');
            cval=pirelab.getValueWithType(1,bitT);
            hC=pirelab.getConstComp(topN,constOne,cval);
            idcName=[outName{1},'_IgnoreDataChecking'];
            if ignoreDataCycles==1




                check_enb.Reg=true;
                if multiClockMode
                    myRate=dutOutSig.SimulinkRate;
                    clkIdx=arrayfun(@(x)x.SimulinkRate==myRate,clkSigs);
                    rstIdx=arrayfun(@(x)x.SimulinkRate==myRate,rstSigs);
                end
                hC=topN.addComponent2('kind','register','name',...
                idcName,'datainput',constOne,'dataoutput',check_enb,...
                'clock',clkSigs(clkIdx),'reset',rstSigs(rstIdx),...
                'clockenable',outValid,...
                'blockcomment','Delay to implement IgnoreDataChecking');
            else

                cnt_sz=ceil(log2(ignoreDataCycles+1));

                cntT=topN.getType('FixedPoint','Signed',0,...
                'WordLength',cnt_sz,'FractionLength',0);
                rate=topN.findSignal('name',this.OutportSnk(ii).ClockName).SimulinkRate;
                check_cnt=topN.addSignal(cntT,[outName{1},'_chkcnt']);
                ignCntDone=topN.addSignal(bitT,[outName{1},'_ignCntDone']);
                needToCount=topN.addSignal(bitT,[outName{1},'_needToCount']);
                hC=pirelab.getCompareToValueComp(topN,check_cnt,ignCntDone,...
                '~=',pirelab.getValueWithType(ignoreDataCycles,cntT));
                ce_out=topN.findSignal('name',this.OutportSnk(ii).ClockEnable.Name);
                hC=pirelab.getLogicComp(topN,[ce_out,ignCntDone],needToCount,'and');

                hC=pirelab.getCounterLimitedComp(topN,check_cnt,ignoreDataCycles,...
                rate,idcName,0,false,needToCount);
                hC=pirelab.getCompareToValueComp(topN,check_cnt,check_enb,...
                '==',ignoreDataCycles);
            end
            outSig=topN.addSignal(bitT,[outName{1},'_chkdata']);
            outSig.SimulinkRate=dutOutSig.SimulinkRate;
            hC=pirelab.getLogicComp(topN,[outValid,check_enb],outSig,'and');

            outValid=outSig;
        end

        for jj=1:numel(outName)
            testFailures(curSig)=topN.addSignal(bitT,...
            [outName{jj},'_testFailure']);
            testFailures(curSig).Reg=true;
            outSig=topN.findSignal('name',outName{jj});
            testFailures(curSig).SimulinkRate=outSig.SimulinkRate;
            hC=pirelab.getTBCheckerComp(topN,...
            [outValid,outSig,outSigs(curSig)],testFailures(curSig));
            curSig=curSig+1;
        end
    end

    testFailure=topN.addSignal(bitT,'testFailure');
    if isempty(testFailures)
        hC=pirelab.getConstComp(topN,testFailure,false);
    else
        hC=pirelab.getLogicComp(topN,testFailures,testFailure,'or');
    end
end


function outValid=getCeOut(this,topN,idx)
    outValid=topN.findSignal('name',this.OutportSnk(idx).ClockEnable.Name);
    if isempty(outValid)
        bitT=topN.getType('Logic','WordLength',1);
        if isempty(this.InportSrc)
            rdenb=topN.findSignal('name',this.ClockEnableName);
        else
            rdenb=topN.findSignal('name',this.InportSrc(1).dataRdEnb.Name);
        end
        if this.initialLatency>0
            outValid=topN.addSignal(bitT,'ce_out');
            delayLine_out=topN.addSignal(bitT,'delayLine_out');
            hC=pirelab.getIntDelayComp(topN,rdenb,delayLine_out,this.initialLatency);
            hC=pirelab.getLogicComp(topN,[delayLine_out,rdenb],outValid,'and');
        else
            outValid=rdenb;
        end
        this.OutportSnk(idx).ClockEnable.Name=outValid.Name;
        for ii=1:numel(this.OutportSnk)
            if strcmpi(this.OutportSnk(ii).HDLPortName,this.OutportSnk(idx).HDLPortName)
                this.OutportSnk(ii).ClockEnable.Name=outValid.Name;
            end
        end
    end
    assert(~isempty(outValid));
end



