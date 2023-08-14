function elabViterbiDecoder(this,topNet,blockInfo,insignals,outsignals)




    ufix1Type=pir_ufixpt_t(1,0);
    ram9Type=pir_ufixpt_t(128,0);
    numStates=blockInfo.numStates;
    dbtype=pir_ufixpt_t(numStates,0);


    datain=insignals(1);
    dataout=outsignals(1);
    if(strcmpi(blockInfo.OperationMode,'Continuous'))
        validin=insignals(2);
        if(blockInfo.ErasurePort)
            erain=insignals(3);
            if(blockInfo.ResetPort)
                rst=insignals(4);
            end
        else
            if(blockInfo.ResetPort)
                rst=insignals(3);
            end
        end
        validout=outsignals(2);
    else
        startin=insignals(2);
        endin=insignals(3);
        validin=insignals(4);
        if(blockInfo.ErasurePort)
            erain=insignals(5);
        end

        startout=outsignals(2);
        endout=outsignals(3);
        validout=outsignals(4);
    end

    dataind=topNet.addSignal(datain.type,'dataInReg');
    validind=topNet.addSignal(ufix1Type,'validInReg');



    if~(strcmpi(blockInfo.OperationMode,'Continuous'))

        startflag=topNet.addSignal(ufix1Type,'startFlag');
        framegapind=topNet.addSignal(ufix1Type,'frameGapInd');
        enbprocess=topNet.addSignal(ufix1Type,'enbProcess');
        validoutd=topNet.addSignal(ufix1Type,'validD');

        fcNet=this.elabFrameController(topNet,blockInfo,datain.SimulinkRate);



        fcomp=pirelab.instantiateNetwork(topNet,fcNet,[startin,endin,validin],...
        [startout,endout,validoutd,startflag,framegapind,enbprocess],...
        'FrameController_inst');
        fcomp.addComment('Instantiation of Frame Controller Network');
    end


    dcomp=pirelab.getUnitDelayComp(topNet,datain,dataind,'data_reg',0);
    dcomp.addComment('Delay the Input data');
    vcomp=pirelab.getUnitDelayComp(topNet,validin,validind,'valid_reg',0);
    vcomp.addComment('Delay the Input valid');
    if(blockInfo.ErasurePort)
        eraind=topNet.addSignal(erain.type,'erasureInReg');
        ecomp=pirelab.getUnitDelayComp(topNet,erain,eraind,'era_reg',0);
        ecomp.addComment('Delay the Input erasure');
    end
    if(blockInfo.ResetPort)
        rstd=topNet.addSignal(ufix1Type,'resetReg');
        rcomp=pirelab.getUnitDelayComp(topNet,rst,rstd,'rst_reg',0);
        rcomp.addComment('Delay the Input reset');
    end

    minstateidx=topNet.addSignal(pir_ufixpt_t(blockInfo.ConstraintLength-1),'minStateIdx');
    minvalid=topNet.addSignal(ufix1Type,'minValid');
    contrst=topNet.addSignal(ufix1Type,'contRst');
    if(blockInfo.ConstraintLength==9)
        decbitsL=topNet.addSignal(ram9Type,'decBitsL');
        decbitsH=topNet.addSignal(ram9Type,'decBitsH');
    else
        decbits=topNet.addSignal(dbtype,'decBits');
    end

    if(strcmpi(blockInfo.OperationMode,'Continuous'))
        if(blockInfo.ErasurePort)
            if(blockInfo.ResetPort)
                metricinsignals=[dataind,validind,eraind,rstd];
            else
                metricinsignals=[dataind,validind,eraind];
            end
        else
            if(blockInfo.ResetPort)
                metricinsignals=[dataind,validind,rstd];
            else
                metricinsignals=[dataind,validind];
            end
        end

        if(blockInfo.ResetPort)
            if(blockInfo.ConstraintLength==9)
                metricoutsignals=[minstateidx,minvalid,decbitsL,decbitsH,contrst];
            else
                metricoutsignals=[minstateidx,minvalid,decbits,contrst];
            end
        else
            if(blockInfo.ConstraintLength==9)
                metricoutsignals=[minstateidx,minvalid,decbitsL,decbitsH];
            else
                metricoutsignals=[minstateidx,minvalid,decbits];
            end

        end
    else
        if(blockInfo.ErasurePort)
            metricinsignals=[dataind,enbprocess,framegapind,startflag,eraind];
        else
            metricinsignals=[dataind,enbprocess,framegapind,startflag];
        end
        if(blockInfo.ConstraintLength==9)
            metricoutsignals=[minstateidx,minvalid,decbitsL,decbitsH];
        else
            metricoutsignals=[minstateidx,minvalid,decbits];
        end
    end


    mcNet=this.elabMetricCalculator(topNet,blockInfo,datain.SimulinkRate);



    mcComp=pirelab.instantiateNetwork(topNet,mcNet,metricinsignals,metricoutsignals,'MetricCalculator_inst');
    mcComp.addComment('Instantiation of Metric Calculator');

    decodebit=topNet.addSignal(dataout.type,'decodeBit');
    lifovalid=topNet.addSignal(ufix1Type,'lifoValid');


    if(blockInfo.ConstraintLength==9)
        ramtbinsignals=[decbitsL,decbitsH,minvalid,minstateidx];
    else
        ramtbinsignals=[decbits,minvalid,minstateidx];
    end

    if(strcmpi(blockInfo.OperationMode,'Continuous'))
        if(blockInfo.ResetPort)
            ramtbinsignals=[ramtbinsignals,contrst];
        end
        ramtboutsignals=[decodebit,lifovalid];
    else
        ramtboutsignals=[decodebit,lifovalid];
    end


    ramtbNet=this.elabRAMTracebackUnit(topNet,blockInfo,datain.SimulinkRate);



    rcomp=pirelab.instantiateNetwork(topNet,ramtbNet,ramtbinsignals,ramtboutsignals,'RAMTracebackUnit_inst');
    rcomp.addComment('Instantiation of RAM Traceback Unit');




    if(strcmpi(blockInfo.OperationMode,'Continuous'))
        if(blockInfo.ResetPort)
            decodebitd=topNet.addSignal(dataout.type,'decodeBitD');
            lifovalidd=topNet.addSignal(ufix1Type,'lifoValidD');
            maxval=blockInfo.ConstraintLength+11;
            maxtype=pir_ufixpt_t(floor(log2(maxval))+1,0);
            validcnt=topNet.addSignal(maxtype,'validCnt');
            iscntlimit=topNet.addSignal(ufix1Type,'isCntLimit');
            state=topNet.addSignal(ufix1Type,'state');
            pirelab.getCounterComp(topNet,[rst,validin],validcnt,'Free running',...
            0,1,maxval,1,0,1,0,'Counter',0);
            pirelab.getCompareToValueComp(topNet,validcnt,iscntlimit,'==',maxval,'');

            pirelab.getUnitDelayEnabledResettableComp(topNet,iscntlimit,state,iscntlimit,rst,'',0,1,1);

            decodebitvld=topNet.addSignal(dataout.type,'decodeBitVld');
            pirelab.getLogicComp(topNet,[decodebit,lifovalid],decodebitvld,'and');

            pirelab.getIntDelayComp(topNet,decodebitvld,decodebitd,1,'decode_data',0);
            pirelab.getIntDelayComp(topNet,lifovalid,lifovalidd,1,'decode_valid',0);

            pirelab.getUnitDelayEnabledResettableComp(topNet,lifovalidd,validout,state,rst,'',0,1,1);
            pirelab.getUnitDelayEnabledResettableComp(topNet,decodebitd,dataout,state,rst,'',0,1,1);
        else

            decodebitvld=topNet.addSignal(dataout.type,'decodeBitVld');
            pirelab.getLogicComp(topNet,[decodebit,lifovalid],decodebitvld,'and');

            pirelab.getIntDelayComp(topNet,decodebitvld,dataout,2,'decode_data',0);
            pirelab.getIntDelayComp(topNet,lifovalid,validout,2,'decode_valid',0);
        end
    else

        decodebitd=topNet.addSignal(dataout.type,'decodeBitD');
        decodebitvld=topNet.addSignal(dataout.type,'decodeBitVld');

        pirelab.getIntDelayComp(topNet,decodebit,decodebitd,1,'decode_data',0);
        pirelab.getLogicComp(topNet,[decodebitd,validoutd],decodebitvld,'and');
        pirelab.getIntDelayComp(topNet,decodebitvld,dataout,1,'dataout',0);
        pirelab.getIntDelayComp(topNet,validoutd,validout,1,'validout',0);
    end

end