function tbNet=elabTraceback(this,topNet,blockInfo,dataRate)





    t=blockInfo.trellis;
    numStates=t.numStates;



    ufix1Type=pir_ufixpt_t(1,0);
    decvType=pirelab.getPirVectorType(ufix1Type,numStates);


    idxWL=ceil(log2(numStates));
    idxType=pir_ufixpt_t(idxWL,0);



    inportnames={'dec','idx'};
    inporttypes=[decvType,idxType];
    inportrates=[dataRate,dataRate];

    if blockInfo.hasResetPort
        inportnames{end+1}='tb_rst';
        inporttypes(end+1)=ufix1Type;
        inportrates(end+1)=dataRate;
    end

    tbNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','Traceback',...
    'InportNames',inportnames,...
    'InportTypes',inporttypes,...
    'InportRates',inportrates,...
    'OutportNames',{'decoded'},...
    'OutportTypes',ufix1Type);


    decin=tbNet.PirInputSignals(1);
    idxin=tbNet.PirInputSignals(2);
    decoded=tbNet.PirOutputSignals(1);

    tbd=blockInfo.tbd;
    compnum=blockInfo.tbcompnum;

    if blockInfo.hasResetPort
        resetin=tbNet.PirInputSignals(3);


        resetdelay=blockInfo.latency-blockInfo.tbregnum-1;
        dresetin=tbNet.addSignal(ufix1Type,'tb_rst_delay');
        intdcomp=pirelab.getIntDelayComp(tbNet,resetin,dresetin,resetdelay,'rst_delay_register',0);
        intdcomp.addComment('Delay the reset signal to match the delays introduced in Branch metric computation and ACS');


        piperegnum=floor(tbd/compnum);
        vType=pirelab.getPirVectorType(ufix1Type,piperegnum+1);
        tapdreset=tbNet.addSignal(vType,'tb_rst_tapdelay');
        c=pirelab.getTapDelayComp(tbNet,dresetin,tapdreset,piperegnum,'rst_tapdelay_register',zeros(1,piperegnum),false,true);
        c.addComment('Tap delay the reset signal to match the extra delays introduced from traceback pipeline registers');


        tapdresets=demuxSignal(this,tbNet,tapdreset,'tapdrst_entry');

    else
        resetin=[];
    end


    tbcompNet=this.elabTracebackUnit(tbNet,blockInfo,dataRate);
    tbcompNet.addComment('Traceback Decoding Unit');





    regk=1;

    for i=1:tbd

        decout(i)=tbNet.addSignal(decvType,['dec',num2str(i)]);
        idxout(i)=tbNet.addSignal(idxType,['idx',num2str(i)]);


        if(i==1)

            tbdecin=decin;
            tbidxin=idxin;
        end

        if isempty(resetin)
            tbComp=pirelab.instantiateNetwork(tbNet,tbcompNet,[tbdecin,tbidxin],[decout(i),idxout(i)],['TracebackComp_inst',num2str(i)]);
        else
            tbComp=pirelab.instantiateNetwork(tbNet,tbcompNet,[tbdecin,tbidxin,tapdresets(regk)],[decout(i),idxout(i)],['TracebackComp_inst',num2str(i)]);
        end
        tbComp.addComment(['Traceback Component',num2str(i)]);

        if(mod(i,compnum)==0)


            decpipereg(regk)=tbNet.addSignal(decvType,['decpipereg',num2str(regk)]);%#ok<AGROW>
            idxpipereg(regk)=tbNet.addSignal(idxType,['idxpipereg',num2str(regk)]);%#ok<AGROW>

            if isempty(resetin)
                decregcomp=pirelab.getUnitDelayComp(tbNet,decout(i),decpipereg(regk),'decpipelineregister',0);
            else







                tbresetEnb=tapdresets(regk+1);
                decregcomp=pirelab.getUnitDelayResettableComp(tbNet,decout(i),decpipereg(regk),tbresetEnb,'decpipelineregister',0,'',true);
            end

            idxregcomp=pirelab.getUnitDelayComp(tbNet,idxout(i),idxpipereg(regk),'idxpipelineregister',0);
            decregcomp.addComment(['Decision pipeline register',num2str(regk)]);
            idxregcomp.addComment(['Index pipeline register',num2str(regk)]);


            tbdecin=decpipereg(regk);
            tbidxin=idxpipereg(regk);
            regk=regk+1;
        else

            tbdecin=decout(i);
            tbidxin=idxout(i);
        end


    end


    pirelab.getBitSliceComp(tbNet,tbidxin,decoded,idxWL-1,idxWL-1);
