function gammaNet=elaborateGamma(~,topNet,blockInfo,dataRate)



    WORDLEN=blockInfo.wordSize;
    FRACLEN=blockInfo.fracSize;
    VECLEN=blockInfo.vecSize;
    K=blockInfo.ConstrLen;
    BITGROWTH=floor(log2(VECLEN))+2+floor(log2(K-1));

    boolType=pir_boolean_t();
    inDataType=pir_sfixpt_t(WORDLEN,FRACLEN);
    inVecType=pirelab.getPirVectorType(inDataType,VECLEN);
    outDataType=pir_sfixpt_t(WORDLEN+BITGROWTH,FRACLEN);
    outVecType=pirelab.getPirVectorType(outDataType,2^VECLEN);




    inportNames={'llrC','llrU','startIn','endIn','validIn'};
    inTypes=[inVecType,inDataType,boolType,boolType,boolType];
    indataRates=dataRate*ones(1,length(inportNames));

    outportNames={'gamma0','gamma1','startOut','endOut','validOut'};
    outTypes=[outVecType,outVecType,boolType,boolType,boolType];

    gammaNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','GammaNetwork',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',indataRates,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );

    llrC=gammaNet.PirInputSignals(1);
    llrU=gammaNet.PirInputSignals(2);
    startIn=gammaNet.PirInputSignals(3);
    endIn=gammaNet.PirInputSignals(4);
    validIn=gammaNet.PirInputSignals(5);


    gamma0=gammaNet.PirOutputSignals(1);
    gamma1=gammaNet.PirOutputSignals(2);
    startOut=gammaNet.PirOutputSignals(3);
    endOut=gammaNet.PirOutputSignals(4);
    validOut=gammaNet.PirOutputSignals(5);

    llrUDTC=gammaNet.addSignal(outDataType,'llrUDTC');
    llrCDTC=gammaNet.addSignal(outVecType,'llrCDTC');

    pirelab.getDTCComp(gammaNet,llrU,llrUDTC);
    pirelab.getDTCComp(gammaNet,llrC,llrCDTC);


    llrCReg=[];
    for ind=1:VECLEN
        llrCDemux(ind)=gammaNet.addSignal(outDataType,['llrCDemux_',num2str(ind)]);%#ok<*AGROW>
        llrCReg=[llrCReg,llrCDemux(ind)];
    end
    pirelab.getDemuxComp(gammaNet,llrCDTC,llrCReg);

    llrUReg=gammaNet.addSignal(outDataType,'llrUncodedReg');
    pirelab.getIntDelayComp(gammaNet,llrUDTC,llrUReg,2,'llrUncoded_register',0);

    zer=gammaNet.addSignal(outDataType,'zero');
    zeroComp=pirelab.getConstComp(gammaNet,zer,0);
    zeroComp.addComment('Zero from constant');

    pmuxout=[];
    for ind=1:VECLEN
        posLLRc(ind)=gammaNet.addSignal(outDataType,['posLLRc_',num2str(ind)]);%#ok<*AGROW>
        pirelab.getIntDelayComp(gammaNet,llrCReg(ind),posLLRc(ind),1,['llrC_reg_',num2str(ind)],0);
        pmuxout=[pmuxout,posLLRc(ind)];
    end



    for ind=1:VECLEN
        negLLRc(ind)=gammaNet.addSignal(outDataType,['negllrCoded_',num2str(ind)]);%#ok<*AGROW>
        pirelab.getSubComp(gammaNet,[zer,pmuxout(ind)],negLLRc(ind));

    end

    bmmuxin=[];
    for k=1:2^(VECLEN)
        bmet(k)=gammaNet.addSignal(outDataType,['bmet_',num2str(k)]);
        dbmet(k)=gammaNet.addSignal(outDataType,['dbmet_',num2str(k)]);
        adderIns=[];
        bitIdx=reshape(int2bit(k-1,VECLEN),VECLEN,[]).';
        for idx=1:VECLEN
            if bitIdx(idx)==0
                adderIns=[adderIns,negLLRc(idx)];
            else
                adderIns=[adderIns,posLLRc(idx)];
            end
        end

        if(VECLEN==2)
            tcomp=pirelab.getAddComp(gammaNet,adderIns,bmet(k),'Floor','Wrap','BMet adders');
            tcomp.addComment('addition of branch metrics');
            dcomp=pirelab.getIntDelayComp(gammaNet,bmet(k),dbmet(k),1,'',0);
            dcomp.addComment('registering of branch metrics');
            bmmuxin=[bmmuxin,dbmet(k)];
            depth=1;
        else
            tcomp=pirelab.getTreeArch(gammaNet,adderIns,bmet(k),'sum','Floor','Wrap','BMet adders');
            tcomp.addComment('Tree stage addition of branch metrics');

            depth=1;
            dcomp=pirelab.getIntDelayComp(gammaNet,bmet(k),dbmet(k),depth,'',0);
            dcomp.addComment('registering of branch metrics');
            bmmuxin=[bmmuxin,dbmet(k)];
        end
    end

    for idx=1:2^(VECLEN)
        addOut1(idx)=gammaNet.addSignal(outDataType,['addOut1_',num2str(idx)]);
        addcomp1=pirelab.getAddComp(gammaNet,[bmmuxin(idx),llrUReg],addOut1(idx),'Floor','Wrap','Branch metric plus uncoded LLR');
        addcomp1.addComment('Branch metric plus uncoded LLR');
        addOut0(idx)=gammaNet.addSignal(outDataType,['addOut0_',num2str(idx)]);
        addcomp0=pirelab.getSubComp(gammaNet,[bmmuxin(idx),llrUReg],addOut0(idx),'Floor','Wrap','Branch metric minus uncoded LLR');
        addcomp0.addComment('Branch metric minus uncoded LLR');
    end

    for idx=1:2^(VECLEN)
        bitShiftOut1(idx)=gammaNet.addSignal(outDataType,['bitShiftOut1_',num2str(idx)]);
        pirelab.getBitShiftComp(gammaNet,addOut1(idx),bitShiftOut1(idx),'sra',1);
        delayOut1(idx)=gammaNet.addSignal(outDataType,['delayOut1_',num2str(idx)]);
        pirelab.getIntDelayComp(gammaNet,bitShiftOut1(idx),delayOut1(idx),1,'',0);
        bitShiftOut0(idx)=gammaNet.addSignal(outDataType,['bitShiftOut0_',num2str(idx)]);
        pirelab.getBitShiftComp(gammaNet,addOut0(idx),bitShiftOut0(idx),'sra',1);
        delayOut0(idx)=gammaNet.addSignal(outDataType,['delayOut0_',num2str(idx)]);
        pirelab.getIntDelayComp(gammaNet,bitShiftOut0(idx),delayOut0(idx),1,'',0);
    end


    pirelab.getIntDelayComp(gammaNet,startIn,startOut,depth+1,'startIn_register',0);
    pirelab.getIntDelayComp(gammaNet,endIn,endOut,depth+2,'endIn_register',0);
    pirelab.getIntDelayComp(gammaNet,validIn,validOut,depth+2,'validIn_register',0);

    pirelab.getMuxComp(gammaNet,delayOut0,gamma0);
    pirelab.getMuxComp(gammaNet,delayOut1,gamma1);






