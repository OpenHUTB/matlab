function bmtopNet=elabBMTop(this,topNet,blockInfo,dataRate)




    ufix1Type=pir_ufixpt_t(1,0);
    ctype=pir_sfixpt_t(blockInfo.dlen+1,0);

    if(blockInfo.ErasurePort)
        eraType=pirelab.getPirVectorType(ufix1Type,blockInfo.N);
    end

    bmType=blockInfo.bmType;
    inTop=topNet.pirInputSignals(1);

    if blockInfo.issigned
        posVType=pirelab.getPirVectorType(ctype,blockInfo.N);
        negVType=pirelab.getPirVectorType(ctype,blockInfo.N);
        posType=pir_sfixpt_t(blockInfo.dlen+1,0);
        pType=pir_sfixpt_t(blockInfo.dlen,0);
        maxval=0;
    else
        posVType=pirelab.getPirVectorType(pir_ufixpt_t(blockInfo.dlen,0),blockInfo.N);
        negVType=pirelab.getPirVectorType(pir_ufixpt_t(blockInfo.dlen,0),blockInfo.N);
        posType=pir_ufixpt_t(blockInfo.dlen,0);
        pType=pir_ufixpt_t(blockInfo.dlen,0);
        maxval=(2^blockInfo.dlen)-1;
    end


    if~(strcmpi(blockInfo.OperationMode,'Continuous'))
        if(blockInfo.ErasurePort)
            bminsignals={'softdata','validin','framegap_vld','erasure'};
            bminporttypes=[inTop.type,ufix1Type,ufix1Type,eraType];
            bminportrates=[dataRate,dataRate,dataRate,dataRate];
        else
            bminsignals={'softdata','validin','framegap_vld'};
            bminporttypes=[inTop.type,ufix1Type,ufix1Type];
            bminportrates=[dataRate,dataRate,dataRate];
        end
    else
        if(blockInfo.ErasurePort)
            if(blockInfo.ResetPort)
                bminsignals={'softdata','validin','bmrst','erasure'};
                bminporttypes=[inTop.type,ufix1Type,ufix1Type,eraType];
                bminportrates=[dataRate,dataRate,dataRate,dataRate];
            else
                bminsignals={'softdata','validin','erasure'};
                bminporttypes=[inTop.type,ufix1Type,eraType];
                bminportrates=[dataRate,dataRate,dataRate];
            end

        else
            if(blockInfo.ResetPort)
                bminsignals={'softdata','validin','bmrst'};
                bminporttypes=[inTop.type,ufix1Type,ufix1Type];
                bminportrates=[dataRate,dataRate,dataRate];
            else
                bminsignals={'softdata','validin'};
                bminporttypes=[inTop.type,ufix1Type];
                bminportrates=[dataRate,dataRate];
            end

        end
    end


    bmtopNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','BMTop',...
    'Inportnames',bminsignals,...
    'InportTypes',bminporttypes,...
    'InportRates',bminportrates,...
    'Outportnames',{'branchMetric','bmValid'},...
    'OutportTypes',[bmType,ufix1Type]...
    );

    softdata=bmtopNet.PirInputSignals(1);
    valid=bmtopNet.PirInputSignals(2);

    if~(strcmpi(blockInfo.OperationMode,'Continuous'))
        bmrst=bmtopNet.PirInputSignals(3);
        if(blockInfo.ErasurePort)
            erasure=bmtopNet.PirInputSignals(4);
        end
    else
        if(blockInfo.ErasurePort)
            if(blockInfo.ResetPort)
                bmrst=bmtopNet.PirInputSignals(3);
                erasure=bmtopNet.PirInputSignals(4);
            else
                erasure=bmtopNet.PirInputSignals(3);
            end
        else
            if(blockInfo.ResetPort)
                bmrst=bmtopNet.PirInputSignals(3);
            end
        end
    end

    bmetric=bmtopNet.PirOutputSignals(1);
    bmvalid=bmtopNet.PirOutputSignals(2);


    dmuxouttmp=[];
    for i=1:blockInfo.N
        dins(i)=bmtopNet.addSignal(pType,['softbit',num2str(i)]);%#ok<*AGROW>
        dmuxouttmp=[dmuxouttmp,dins(i)];
    end

    pirelab.getDemuxComp(bmtopNet,softdata,dmuxouttmp);

    dmuxout=[];
    for i=1:blockInfo.N
        softbit_dtc(i)=bmtopNet.addSignal(posType,['softbit_dtc',num2str(i)]);%#ok<*AGROW>
        pirelab.getDTCComp(bmtopNet,dmuxouttmp(i),softbit_dtc(i),'floor','wrap');
        dmuxout=[dmuxout,softbit_dtc(i)];
    end


    if(blockInfo.ErasurePort)

        emuxout=[];
        eravalid=[];
        for i=1:blockInfo.N
            dins(i)=bmtopNet.addSignal(ufix1Type,['erasurebit',num2str(i)]);%#ok<*AGROW>
            emuxout=[emuxout,dins(i)];
            eins(i)=bmtopNet.addSignal(ufix1Type,['eravldbit',num2str(i)]);%#ok<*AGROW>
            pirelab.getLogicComp(bmtopNet,[emuxout(i),valid],eins(i),'and');
            eravalid=[eravalid,eins(i)];
        end

        pirelab.getDemuxComp(bmtopNet,erasure,emuxout);

        if~(strcmpi(blockInfo.OperationMode,'Continuous'))||(blockInfo.ResetPort)

            erstout=[];
            for i=1:blockInfo.N
                rins(i)=bmtopNet.addSignal(ufix1Type,['bmrstval',num2str(i)]);%#ok<*AGROW>
                pirelab.getLogicComp(bmtopNet,[eravalid(i),bmrst],rins(i),'or');
                erstout=[erstout,rins(i)];
            end


        end
    end

    posstream=bmtopNet.addSignal(posVType,'posSoftsStream');
    negstream=bmtopNet.addSignal(negVType,'negSoftStream');

    for i=1:blockInfo.N
        pstream(i)=bmtopNet.addSignal(posType,['posStream_',num2str(i)]);
        nstream(i)=bmtopNet.addSignal(posType,['negStream_',num2str(i)]);
    end

    max=bmtopNet.addSignal(posType,'maxVal');
    maxvalcomp=pirelab.getConstComp(bmtopNet,max,maxval);
    maxvalcomp.addComment('Max value of a soft bit');

    for i=1:blockInfo.N
        nsoft_temp(i)=bmtopNet.addSignal(posType,['nstream_temp',num2str(i)]);
        pirelab.getSubComp(bmtopNet,[max,dmuxout(i)],nsoft_temp(i));
    end

    for i=1:blockInfo.N
        if(strcmpi(blockInfo.OperationMode,'Continuous'))&&~(blockInfo.ResetPort)
            if(blockInfo.ErasurePort)
                pirelab.getUnitDelayEnabledResettableComp(bmtopNet,dmuxout(i),pstream(i),valid,eravalid(i),'',0,1,1);
                pirelab.getUnitDelayEnabledResettableComp(bmtopNet,nsoft_temp(i),nstream(i),valid,eravalid(i),'',0,1,1);
            else
                pirelab.getUnitDelayEnabledComp(bmtopNet,dmuxout(i),pstream(i),valid,'',0);
                pirelab.getUnitDelayEnabledComp(bmtopNet,nsoft_temp(i),nstream(i),valid,'',0);
            end
        else
            if(blockInfo.ErasurePort)
                pirelab.getUnitDelayEnabledResettableComp(bmtopNet,dmuxout(i),pstream(i),valid,erstout(i),'',0,1,1);
                pirelab.getUnitDelayEnabledResettableComp(bmtopNet,nsoft_temp(i),nstream(i),valid,erstout(i),'',0,1,1);
            else
                pirelab.getUnitDelayEnabledResettableComp(bmtopNet,dmuxout(i),pstream(i),valid,bmrst,'',0,1,1);
                pirelab.getUnitDelayEnabledResettableComp(bmtopNet,nsoft_temp(i),nstream(i),valid,bmrst,'',0,1,1);
            end
        end
    end


    pArray=[];
    nArray=[];
    for i=1:blockInfo.N
        pArray=[pArray,pstream(i)];
        nArray=[nArray,nstream(i)];
    end

    dim=blockInfo.N;

    pmuxin=[];
    for i=1:dim
        pmuxin=[pmuxin,pArray(i)];
    end
    muxpcomp=pirelab.getMuxComp(bmtopNet,pmuxin,posstream);
    muxpcomp.addComment('posSoftbit Stream Muxing');

    nmuxin=[];
    for i=1:dim
        nmuxin=[nmuxin,nArray(i)];
    end
    muxncomp=pirelab.getMuxComp(bmtopNet,nmuxin,negstream);
    muxncomp.addComment('negSoftBit Stream Muxing');

    bmvalidin=bmtopNet.addSignal(ufix1Type,'bmvalidin');
    pirelab.getUnitDelayComp(bmtopNet,valid,bmvalidin,'',0);


    bmunitNet=this.elabBMUnit(bmtopNet,blockInfo,softdata.SimulinkRate);



    bcomp=pirelab.instantiateNetwork(bmtopNet,bmunitNet,[posstream,negstream,bmvalidin],[bmetric,bmvalid],'BMUnit_inst');
    bcomp.addComment('Instantiation of Branch Metric Unit');

end