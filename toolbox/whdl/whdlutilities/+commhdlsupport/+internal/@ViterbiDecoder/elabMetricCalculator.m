function mcNet=elabMetricCalculator(this,topNet,blockInfo,dataRate)




    ufix1Type=pir_ufixpt_t(1,0);
    bmtype=blockInfo.bmType;
    smtype=blockInfo.smType;
    numStates=blockInfo.numStates;
    dbType=pirelab.getPirVectorType(ufix1Type,numStates);
    idxType=pir_ufixpt_t(blockInfo.ConstraintLength-1);
    dbtype=pir_ufixpt_t(numStates,0);
    ram9Type=pir_ufixpt_t(128,0);

    if blockInfo.issigned
        intype=pir_sfixpt_t(blockInfo.dlen,0);
        inType=pirelab.getPirVectorType(intype,blockInfo.N);
        eraType=pirelab.getPirVectorType(ufix1Type,blockInfo.N);
    else
        intype=pir_ufixpt_t(blockInfo.dlen,0);
        inType=pirelab.getPirVectorType(intype,blockInfo.N);
        eraType=pirelab.getPirVectorType(ufix1Type,blockInfo.N);
    end


    if(strcmpi(blockInfo.OperationMode,'Continuous'))
        if(blockInfo.ErasurePort)
            if(blockInfo.ResetPort)
                metricinsignals={'softdata','validin','erasurein','rst'};
                metricintypes=[inType,ufix1Type,eraType,ufix1Type];
                metricinrates=[dataRate,dataRate,dataRate,dataRate];
            else
                metricinsignals={'softdata','validin','erasurein'};
                metricintypes=[inType,ufix1Type,eraType];
                metricinrates=[dataRate,dataRate,dataRate];
            end
        else
            if(blockInfo.ResetPort)
                metricinsignals={'softdata','validin','rst'};
                metricintypes=[inType,ufix1Type,ufix1Type];
                metricinrates=[dataRate,dataRate,dataRate,];
            else
                metricinsignals={'softdata','validin'};
                metricintypes=[inType,ufix1Type];
                metricinrates=[dataRate,dataRate];
            end
        end

        if(blockInfo.ResetPort)
            if(blockInfo.ConstraintLength==9)
                metricoutsignals={'minStateIdx','minValid','decbitsL','decbitsH','contRst'};
                metricouttypes=[idxType,ufix1Type,ram9Type,ram9Type,ufix1Type];
            else
                metricoutsignals={'minStateIdx','minValid','decbits','contRst'};
                metricouttypes=[idxType,ufix1Type,dbtype,ufix1Type];
            end
        else
            if(blockInfo.ConstraintLength==9)
                metricoutsignals={'minStateIdx','minValid','decbitsL','decbitsH'};
                metricouttypes=[idxType,ufix1Type,ram9Type,ram9Type];
            else
                metricoutsignals={'minStateIdx','minValid','decbits'};
                metricouttypes=[idxType,ufix1Type,dbtype];
            end

        end
    else
        if(blockInfo.ErasurePort)
            metricinsignals={'softdata','validin','frameGapInd','startFlag','erasurein'};
            metricintypes=[inType,ufix1Type,ufix1Type,ufix1Type,eraType];
            metricinrates=[dataRate,dataRate,dataRate,dataRate,dataRate];
        else
            metricinsignals={'softdata','validin','frameGapInd','startFlag'};
            metricintypes=[inType,ufix1Type,ufix1Type,ufix1Type];
            metricinrates=[dataRate,dataRate,dataRate,dataRate];
        end
        if(blockInfo.ConstraintLength==9)
            metricoutsignals={'minStateIdx','minValid','decbitsL','decbitsH'};
            metricouttypes=[idxType,ufix1Type,ram9Type,ram9Type];
        else
            metricoutsignals={'minStateIdx','minValid','decbits'};
            metricouttypes=[idxType,ufix1Type,dbtype];
        end
    end


    mcNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','MetricCalculator',...
    'Inportnames',metricinsignals,...
    'InportTypes',metricintypes,...
    'InportRates',metricinrates,...
    'Outportnames',metricoutsignals,...
    'OutportTypes',metricouttypes...
    );


    softdata=mcNet.PirInputSignals(1);
    validin=mcNet.PirInputSignals(2);
    minstateidx=mcNet.PirOutputSignals(1);
    validout=mcNet.PirOutputSignals(2);

    if(blockInfo.ConstraintLength==9)
        decbitsL=mcNet.PirOutputSignals(3);
        decbitsH=mcNet.PirOutputSignals(4);
        idx=5;
    else
        decbits=mcNet.PirOutputSignals(3);
        idx=4;
    end

    if(strcmpi(blockInfo.OperationMode,'Continuous'))
        if(blockInfo.ErasurePort)
            erasure=mcNet.PirInputSignals(3);
            if(blockInfo.ResetPort)
                acsrst=mcNet.PirInputSignals(4);
            end
        else
            if(blockInfo.ResetPort)
                acsrst=mcNet.PirInputSignals(3);
            end
        end

        if(blockInfo.ResetPort)
            contrst=mcNet.PirOutputSignals(idx);
        end
    else
        framegap_vld=mcNet.PirInputSignals(3);
        framestart=mcNet.PirInputSignals(4);

        if(blockInfo.ErasurePort)
            erasure=mcNet.PirInputSignals(5);
        end
    end

    bmet=mcNet.addSignal(bmtype,'bMet');
    bmvalid=mcNet.addSignal(ufix1Type,'bmvalid');
    acsrstd=mcNet.addSignal(ufix1Type,'acsRstD');

    smet=mcNet.addSignal(smtype,'sMet');
    smvalid=mcNet.addSignal(ufix1Type,'smvalid');
    decbitsreg=mcNet.addSignal(dbType,'decBitsReg');

    if(~(blockInfo.ConstraintLength==9))
        decbitsd=mcNet.addSignal(decbits.type,'decBitsD');
    end

    minstateidxD=mcNet.addSignal(minstateidx.type,'minstateidxD');
    validoutD=mcNet.addSignal(ufix1Type,'validoutD');

    if(blockInfo.ResetPort)
        bmrst=mcNet.addSignal(ufix1Type,'bmRst');

        pirelab.getWireComp(mcNet,acsrst,bmrst);
    end


    if~(strcmpi(blockInfo.OperationMode,'Continuous'))
        if(blockInfo.ErasurePort)
            bminsignals=[softdata,validin,framegap_vld,erasure];
        else
            bminsignals=[softdata,validin,framegap_vld];
        end
        acsinsignals=[bmet,bmvalid,acsrstd];
    else
        if(blockInfo.ErasurePort)
            if(blockInfo.ResetPort)
                bminsignals=[softdata,validin,bmrst,erasure];
            else
                bminsignals=[softdata,validin,erasure];
            end
        else
            if(blockInfo.ResetPort)
                bminsignals=[softdata,validin,bmrst];
            else
                bminsignals=[softdata,validin];
            end
        end
        if(blockInfo.ResetPort)
            acsinsignals=[bmet,bmvalid,acsrstd];
        else
            acsinsignals=[bmet,bmvalid];
        end
    end

    if(blockInfo.N<5)
        acsdelay=2;
    else
        acsdelay=3;
    end

    if(strcmpi(blockInfo.OperationMode,'Continuous'))

        if(blockInfo.ResetPort)
            rcomp=pirelab.getIntDelayComp(mcNet,acsrst,acsrstd,acsdelay,'ACS_rst',0);
            rcomp.addComment('Delay of ACS Reset Signal')
        end
    else
        acsrst=mcNet.addSignal(ufix1Type,'acsRst');
        if(strcmpi(blockInfo.OperationMode,'Terminated'))
            rcomp=pirelab.getLogicComp(mcNet,[framegap_vld,framestart],acsrst,'or');
        elseif(strcmpi(blockInfo.OperationMode,'Truncated'))
            rcomp=pirelab.getWireComp(mcNet,framestart,acsrst);
        end
        rcomp.addComment('ACS Reset Signal for frame mode')
        rdcomp=pirelab.getIntDelayComp(mcNet,acsrst,acsrstd,acsdelay,'ACS_rst',0);
        rdcomp.addComment('Delay of ACS Reset Signal')
    end


    bmtopNet=this.elabBMTop(mcNet,blockInfo,softdata.SimulinkRate);



    bcomp=pirelab.instantiateNetwork(mcNet,bmtopNet,bminsignals,[bmet,bmvalid],'BMTop_inst');
    bcomp.addComment('Instantiation for BMTop Network');


    acsNet=this.elabACS(mcNet,blockInfo,softdata.SimulinkRate);



    acomp=pirelab.instantiateNetwork(mcNet,acsNet,acsinsignals,[smet,decbitsreg,smvalid],'ACS_inst');
    acomp.addComment('Instantiation for ACS Network');

    CL=blockInfo.ConstraintLength;

    if(CL==9)
        ram9Type=pir_ufixpt_t(numStates/2,0);
        decbitsdL=mcNet.addSignal(ram9Type,'decBitsDL');
        decbitsdH=mcNet.addSignal(ram9Type,'decBitsDH');

        decins=this.demuxSignal(mcNet,decbitsreg,'decin_entry');
        bLComp=pirelab.getBitConcatComp(mcNet,decins(numStates/2:-1:1),decbitsdL);
        bLComp.addComment('CL-9 special case 128 bit limitation, Vector to scalar conversion -- Lower 128');
        bHComp=pirelab.getBitConcatComp(mcNet,decins(numStates:-1:(numStates/2)+1),decbitsdH);
        bHComp.addComment('Vector to scalar conversion -- Upper 128');
    else
        decins=this.demuxSignal(mcNet,decbitsreg,'decin_entry');
        bComp=pirelab.getBitConcatComp(mcNet,decins(numStates:-1:1),decbitsd,'');
        bComp.addComment('Vector to scalar conversion');
    end


    mmcNet=this.elabMinmetricCal(mcNet,blockInfo,softdata.SimulinkRate);



    mcomp=pirelab.instantiateNetwork(mcNet,mmcNet,[smet,smvalid],[minstateidxD,validoutD],'MinMetCal_inst');
    mcomp.addComment('Instantiation for MinimumMetricCalulation Network');

    if(blockInfo.N<5)
        mcomp=pirelab.getIntDelayComp(mcNet,minstateidxD,minstateidx,1,'',0);
        mcomp.addComment('Delaying the minStateIdx');

        vcomp=pirelab.getIntDelayComp(mcNet,validoutD,validout,1,'',0);
        vcomp.addComment('Delaying the validout indicating minStateIdx');

        if(CL==9)
            decLcomp=pirelab.getIntDelayComp(mcNet,decbitsdL,decbitsL,CL+1,'decbitsL',0);
            decLcomp.addComment('Delaying Decision Lower half bits with Minimum Metric Calculation network');

            decHcomp=pirelab.getIntDelayComp(mcNet,decbitsdH,decbitsH,CL+1,'decbitsH',0);
            decHcomp.addComment('Delaying Decision bits Upper half with Minimum Metric Calculation network');
        else
            deccomp=pirelab.getIntDelayComp(mcNet,decbitsd,decbits,CL+1,'decbits',0);
            deccomp.addComment('Delaying Decision bits with Minimum Metric Calculation network');
        end
    else
        mcomp=pirelab.getWireComp(mcNet,minstateidxD,minstateidx);
        mcomp.addComment('Delaying the minStateIdx');

        vcomp=pirelab.getWireComp(mcNet,validoutD,validout);
        vcomp.addComment('Delaying the validout indicating minStateIdx');

        if(CL==9)
            decLcomp=pirelab.getIntDelayComp(mcNet,decbitsdL,decbitsL,CL,'decbitsL',0);
            decLcomp.addComment('Delaying Decision Lower half bits with Minimum Metric Calculation network');

            decHcomp=pirelab.getIntDelayComp(mcNet,decbitsdH,decbitsH,CL,'decbitsH',0);
            decHcomp.addComment('Delaying Decision bits Upper half with Minimum Metric Calculation network');
        else
            deccomp=pirelab.getIntDelayComp(mcNet,decbitsd,decbits,CL,'decbits',0);
            deccomp.addComment('Delaying Decision bits with Minimum Metric Calculation network');
        end

    end

    if(strcmpi(blockInfo.OperationMode,'Continuous')&&(blockInfo.ResetPort))
        if(blockInfo.N<5)
            rscomp=pirelab.getIntDelayComp(mcNet,acsrstd,contrst,CL+2,'Cont_rst',0);
            rscomp.addComment('Continuous Mode Reset Signal')
        else
            rscomp=pirelab.getIntDelayComp(mcNet,acsrstd,contrst,CL+1,'Cont_rst',0);
            rscomp.addComment('Continuous Mode Reset Signal')
        end
    end


