function elabConvEncNetwork(this,topNet,blockInfo,insignals,outsignals,...
    dataRate)




    n=blockInfo.CodeGenLen;
    clength=blockInfo.clength;
    gmatrix=blockInfo.gmatrix;
    fbmatrix=blockInfo.fbmatrix;
    feedbackenb=blockInfo.feedbackenb;


    ufix1Type=pir_ufixpt_t(1,0);
    vType=pirelab.getPirVectorType(ufix1Type,clength-1);
    nType=pirelab.getPirVectorType(ufix1Type,n);

    datain=insignals(1);
    dataout=outsignals(1);

    if strcmpi(blockInfo.operationMode,'Terminated')||...
        strcmpi(blockInfo.operationMode,'Truncated')

        startin=insignals(2);
        endin=insignals(3);
        validin=insignals(4);

        startout=outsignals(2);
        endout=outsignals(3);
        validout=outsignals(4);

        rstSig=topNet.addSignal(ufix1Type,'rstSig');
        endSig=topNet.addSignal(ufix1Type,'endSig');
        enbSig=topNet.addSignal(ufix1Type,'enbSig');

        frameinsignals=[startin,endin,validin];
        if strcmpi(blockInfo.operationMode,'Terminated')
            tailFlag=topNet.addSignal(ufix1Type,'tailFlag');
            frameoutsignals=[rstSig,endSig,enbSig,tailFlag];
        else
            frameoutsignals=[rstSig,endSig,enbSig];

            if(blockInfo.enbIStPort)
                ISt=insignals(5);
                for ii=clength-2:-1:0
                    IStvecs(ii+1)=topNet.addSignal(ufix1Type,['ISt',num2str(ii)]);
                    pirelab.getBitSliceComp(topNet,ISt,IStvecs(ii+1),ii,ii);
                end
                IStvec=topNet.addSignal(vType,'IStvec');
                pirelab.getMuxComp(topNet,IStvecs(end:-1:1),IStvec);
                IStreg=topNet.addSignal(vType,'IStreg');
                istCmp=pirelab.getUnitDelayComp(topNet,IStvec,IStreg,'IStreg',0);
                istCmp.addComment('register the initial state');
            end

            if(blockInfo.enbFStPort)
                FSt=outsignals(5);
            end
        end
    else

        validin=insignals(2);
        enbSig=topNet.addSignal(ufix1Type,'enbSig');
        vesigCmp=pirelab.getUnitDelayComp(topNet,validin,enbSig,'enbSig',0);
        vesigCmp.addComment('register the validin signal');
        if(blockInfo.enbRst)
            rst=insignals(3);
            rstReg=topNet.addSignal(ufix1Type,'rstReg');
            rstRegReg=topNet.addSignal(ufix1Type,'rstRegReg');

            rstSig=topNet.addSignal(ufix1Type,'rstSig');
            rstCmp=pirelab.getWireComp(topNet,rstReg,rstSig);
            rstCmp.addComment('delayed reset signal');
            pirelab.getUnitDelayComp(topNet,rst,rstReg,'rstReg',0);
            pirelab.getUnitDelayComp(topNet,rstReg,rstRegReg,'rstRegReg',0);
        end

        validout=outsignals(2);
    end

    datainreg=topNet.addSignal(ufix1Type,'datainReg');
    dataCmp=pirelab.getUnitDelayComp(topNet,datain,datainreg,'datainreg',0);
    dataCmp.addComment('register the datain signal');
    bitin=topNet.addSignal(ufix1Type,'bitin');
    pirelab.getWireComp(topNet,datainreg,bitin);

    if~(strcmpi(blockInfo.operationMode,'Continuous'))


        fcNet=this.elabControlUnit(topNet,blockInfo,datain.SimulinkRate);
        fcomp=pirelab.instantiateNetwork(topNet,fcNet,[frameinsignals],...
        [frameoutsignals],...
        'FrameController_inst');
        fcomp.addComment('Instantiation of Frame Controller Network');
    end



    shiftreg=topNet.addSignal(vType,'shiftreg');
    shiftreg_next=topNet.addSignal(vType,'shiftreg_next');


    bitinreg=topNet.addSignal(ufix1Type,'bitinreg');

    if~(blockInfo.enbRst)
        shiftREgCmp=pirelab.getUnitDelayEnabledComp(topNet,shiftreg_next,shiftreg,enbSig,...
        'shiftreg',0);

    elseif strcmpi(blockInfo.operationMode,'Truncated')
        if(blockInfo.enbIStPort)
            shiftreg_nexttmp=topNet.addSignal(vType,'shiftreg_nexttmp');
            rstenb=topNet.addSignal(ufix1Type,'rstenb');
            shiftREgCmp=pirelab.getUnitDelayEnabledComp(topNet,shiftreg_nexttmp,shiftreg,rstenb,...
            'shiftreg',0);
        else
            shiftREgCmp=pirelab.getUnitDelayEnabledResettableComp(topNet,shiftreg_next,shiftreg,...
            enbSig,rstSig,'shiftreg',0,'',1);
        end
    else
        shiftREgCmp=pirelab.getUnitDelayEnabledResettableComp(topNet,shiftreg_next,shiftreg,...
        enbSig,rstSig,'shiftreg',0,'',1);
    end
    shiftREgCmp.addComment('update shift registers');

    validOutd=topNet.addSignal(ufix1Type,'validOutd');
    validdCmp=pirelab.getUnitDelayComp(topNet,enbSig,validOutd,'validOutd',0);
    validdCmp.addComment('delay balancing the valid signal');

    if strcmpi(blockInfo.operationMode,'Terminated')

        bittmp=topNet.addSignal(ufix1Type,'bittmp');
        bitinval=bittmp;
    else

        bitinval=bitin;
    end

    if(strcmpi(blockInfo.operationMode,'Continuous'))&&(blockInfo.enbRst)

        bitregCmp=pirelab.getUnitDelayEnabledResettableComp(topNet,bitinval,bitinreg,enbSig,...
        rstSig,'bitinreg',0,'',1);
    else

        bitregCmp=pirelab.getUnitDelayEnabledComp(topNet,bitinval,bitinreg,enbSig,'bitinreg',0);
    end
    bitregCmp.addComment('delay the bitin signal');

    srarray=this.demuxSignal(topNet,shiftreg,'shiftregout');
    buffbits=[bitinreg,srarray];

    if(feedbackenb)
        fbbit=topNet.addSignal(ufix1Type,'fbbit');
        fbXORin=[];
        for ii=1:clength
            if(fbmatrix(ii))
                fbXORin=[fbXORin,buffbits(ii)];
            end
        end
        fbCmp=pirelab.getBitwiseOpComp(topNet,fbXORin,fbbit,'XOR');
        data=fbbit;
        fbCmp.addComment('feedback output');
    else
        data=bitinreg;
    end


    if~strcmpi(blockInfo.operationMode,'Continuous')
        endOutd=topNet.addSignal(ufix1Type,'endOutd');
        startOutd=topNet.addSignal(ufix1Type,'startOutd');
        endCmp=pirelab.getUnitDelayComp(topNet,endSig,endOutd,'endOutd',0);
        endCmp.addComment('delay balancing the end signal');
        strtCmp=pirelab.getUnitDelayComp(topNet,rstSig,startOutd,'startOutd',0);
        strtCmp.addComment('delay balancing the start signal');
    end

    if strcmpi(blockInfo.operationMode,'Truncated')
        if(blockInfo.enbFStPort)



            finalstate=topNet.addSignal(vType,'finalstate');
            fstCmp=pirelab.getWireComp(topNet,shiftreg_next,finalstate);
            fstCmp.addComment('final state output');

        end

        if(blockInfo.enbIStPort)
            pirelab.getLogicComp(topNet,[rstSig,enbSig],rstenb,'or');
            istshftCmp=pirelab.getSwitchComp(topNet,[shiftreg_next,IStreg],shiftreg_nexttmp,...
            rstSig,'','==',0);
            istshftCmp.addComment('Initial state applied on start signal');
        end
    elseif strcmpi(blockInfo.operationMode,'Terminated')
        fbmatrixp=blockInfo.fbmatrixp;
        tailbit=topNet.addSignal(ufix1Type,'tailbit');

        if feedbackenb
            tbXORin=[];
            for ii=1:clength
                if(fbmatrixp(ii))
                    tbXORin=[tbXORin,buffbits(ii)];
                end
            end
            pirelab.getBitwiseOpComp(topNet,tbXORin,tailbit,'XOR');
            tbCmp=pirelab.getSwitchComp(topNet,[bitin,tailbit],bittmp,tailFlag,'','==',0);
            tbCmp.addComment('tail or data bits to the encoder');
        else
            pirelab.getConstComp(topNet,tailbit,0,'tailbit_0');
            tbCmp=pirelab.getSwitchComp(topNet,[bitin,tailbit],bittmp,tailFlag,'','==',0);
            tbCmp.addComment('tail or data bits to the encoder');
        end
    end
    nxtmem=[data,srarray(1:end-1)];
    this.muxSignal(topNet,nxtmem,shiftreg_next);

    for i=1:n

        outxor=[];
        for jj=1:clength
            if(gmatrix(i,jj))
                outxor=[outxor,buffbits(jj)];
            end
        end
        encodeds(i)=topNet.addSignal(ufix1Type,['encoded_entry',num2str(i)]);
        encCmp=pirelab.getBitwiseOpComp(topNet,outxor,encodeds(i),'XOR');
    end
    encCmp.addComment('encoded output');

    encoded=topNet.addSignal(nType,'encoded');
    pirelab.getMuxComp(topNet,encodeds,encoded);
    encOutCmp=pirelab.getUnitDelayComp(topNet,encoded,dataout);
    encOutCmp.addComment('register output signal');
    if~strcmpi(blockInfo.operationMode,'Continuous')
        strtOutCmp=pirelab.getUnitDelayComp(topNet,startOutd,startout,'startout',0);
        strtOutCmp.addComment('register start out signal');
        endtOutCmp=pirelab.getUnitDelayComp(topNet,endOutd,endout,'endout',0);
        endtOutCmp.addComment('register end out signal');
        vldOutCmp=pirelab.getUnitDelayComp(topNet,validOutd,validout,'validout',0);

        if strcmpi(blockInfo.operationMode,'Truncated')
            if(blockInfo.enbFStPort)
                FStOut=topNet.addSignal(pir_ufixpt_t(clength-1,0),'FStOut');
                pirelab.getBitConcatComp(topNet,finalstate(end:-1:1),FStOut);
                fstCmp=pirelab.getUnitDelayComp(topNet,FStOut,FSt,'FSt',0);
                fstCmp.addComment('delay balancing final state');
            end
        end
    else
        if(blockInfo.enbRst)

            ORoper=[rst,rstReg,rstRegReg];

            rstOR=topNet.addSignal(ufix1Type,'rstOR');
            pirelab.getBitwiseOpComp(topNet,ORoper,rstOR,'OR');
            negrstOR=topNet.addSignal(ufix1Type,'negrstOR');
            pirelab.getLogicComp(topNet,rstOR,negrstOR,'not');
            validtmp=topNet.addSignal(ufix1Type,'validtmp');
            pirelab.getLogicComp(topNet,[negrstOR,validOutd],validtmp,'and');
            vldOutCmp=pirelab.getUnitDelayComp(topNet,validtmp,validout,'validout',0);
        else
            vldOutCmp=pirelab.getUnitDelayComp(topNet,validOutd,validout,'validout',0);
        end
    end
    vldOutCmp.addComment('register valid out signal');
end

