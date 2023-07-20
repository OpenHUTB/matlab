function bmunitNet=elabBMUnit(this,topNet,blockInfo,dataRate)




    ufix1Type=pir_ufixpt_t(1,0);
    inType=blockInfo.bmType;
    btype=pir_sfixpt_t(blockInfo.dlen+1,0);
    ptype=pir_ufixpt_t(blockInfo.dlen,0);

    if(blockInfo.issigned)
        posVType=pirelab.getPirVectorType(btype,blockInfo.N);
        posType=btype;
        ctype=pir_sfixpt_t(blockInfo.bmWL,0);
    else
        posVType=pirelab.getPirVectorType(ptype,blockInfo.N);
        posType=ptype;
        ctype=pir_ufixpt_t(blockInfo.bmWL,0);
    end



    bmunitNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','BMUnit',...
    'Inportnames',{'posSoftStream','negSoftStream','bmInValid'},...
    'InportTypes',[posVType,posVType,ufix1Type],...
    'InportRates',[dataRate,dataRate,dataRate],...
    'Outportnames',{'branchMetric','bmValid'},...
    'OutportTypes',[inType,ufix1Type]...
    );

    possoftval=bmunitNet.PirInputSignals(1);
    negsoftval=bmunitNet.PirInputSignals(2);
    valid=bmunitNet.PirInputSignals(3);

    bmmetric=bmunitNet.PirOutputSignals(1);
    bmvalid=bmunitNet.PirOutputSignals(2);


    dim=blockInfo.N;
    pmuxout=[];
    for i=1:dim
        pins(i)=bmunitNet.addSignal(posType,['softVal0_',num2str(i)]);%#ok<*AGROW>
        pmuxout=[pmuxout,pins(i)];
    end
    pirelab.getDemuxComp(bmunitNet,possoftval,pmuxout);

    nmuxout=[];
    for i=1:dim
        nins(i)=bmunitNet.addSignal(posType,['softVal1_',num2str(i)]);%#ok<*AGROW>
        nmuxout=[nmuxout,nins(i)];
    end
    sftcomp=pirelab.getDemuxComp(bmunitNet,negsoftval,nmuxout);
    sftcomp.addComment('softvalues for the branch metric addition');

    bmmuxin=[];
    for k=1:2^(dim)
        bmet(k)=bmunitNet.addSignal(ctype,['bmet_',num2str(k)]);
        dbmet(k)=bmunitNet.addSignal(ctype,['dbmet_',num2str(k)]);
        adderIns=[];
        tmpIdx=k-1;
        for idx=1:dim
            inIdx=dim-idx+1;
            if(rem(tmpIdx,2))
                adderIns=[adderIns,nins(inIdx)];
            else
                adderIns=[adderIns,pins(inIdx)];
            end
            tmpIdx=floor(tmpIdx/2);
        end

        if(dim==2)
            tcomp=pirelab.getAddComp(bmunitNet,adderIns,bmet(k),'Floor','Wrap','BMet adders');
            tcomp.addComment('addition of branch metrics');
            dcomp=pirelab.getIntDelayComp(bmunitNet,bmet(k),dbmet(k),1,'',0);
            dcomp.addComment('registering of branch metrics');
            bmmuxin=[bmmuxin,dbmet(k)];
        else
            tcomp=pirelab.getTreeArch(bmunitNet,adderIns,bmet(k),'sum','Floor','Wrap','BMet adders');
            tcomp.addComment('Tree stage addition of branch metrics');
            depth=ceil(log2(blockInfo.N))-1;
            dcomp=pirelab.getIntDelayComp(bmunitNet,bmet(k),dbmet(k),depth,'',0);
            dcomp.addComment('registering of branch metrics');
            bmmuxin=[bmmuxin,dbmet(k)];
        end
    end

    if(dim==2)
        this.muxSignal(bmunitNet,bmmuxin,bmmetric);
        dcomp1=pirelab.getIntDelayComp(bmunitNet,valid,bmvalid,1,'',0);
        dcomp1.addComment('registering the output valid');
    else
        this.muxSignal(bmunitNet,bmmuxin,bmmetric);
        dcomp1=pirelab.getIntDelayComp(bmunitNet,valid,bmvalid,depth,'',0);
        dcomp1.addComment('registering the output valid');
    end

end