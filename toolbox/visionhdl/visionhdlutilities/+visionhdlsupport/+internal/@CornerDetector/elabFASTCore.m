function FASTCoreNet=elabFASTCore(~,topNet,blockInfo,dataRate)






    ctrlType=pir_boolean_t();

    iports={'pixelInVec','ShiftEnb'};
    itypes=[blockInfo.pixelInVecDT,ctrlType];
    irates=[dataRate,dataRate];
    if blockInfo.numInputPorts==3
        iports{end+1}='minC';
        itypes(end+1)=blockInfo.pixelInVecDT.BaseType;
        irates(end+1)=dataRate;
    end

    FASTCoreNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','FASTCore',...
    'InportNames',iports,...
    'InportTypes',itypes,...
    'InportRates',irates,...
    'OutportNames',{'cornerOut'},...
    'OutportTypes',blockInfo.outportCornerType);


    pixelInVec=FASTCoreNet.PirInputSignals(1);
    tapValidIn=FASTCoreNet.PirInputSignals(2);

    cornerOut=FASTCoreNet.PirOutputSignals(1);
    cornerOutType=blockInfo.outportCornerType;

    inputType=pixelInVec.Type;



    switch blockInfo.Method
    case 'FAST 5 of 8'
        centeridx=5;
        ringidx=[1;4;7;8;9;6;3;2];
        ringregion=5;
        finalDelay=6;
    case 'FAST 7 of 12'
        centeridx=13;
        ringidx=[6;11;16;22;23;24;20;15;10;4;3;2];
        ringregion=7;
        finalDelay=5;
    case 'FAST 9 of 16'
        centeridx=25;
        ringidx=[22;29;37;45;...
        46;47;41;35;...
        28;21;13;5;...
        4;3;9;15];
        ringregion=9;
        finalDelay=4;
    otherwise

    end
    ringlen=length(ringidx);




    tapInData=pixelInVec(1).split;
    tapOutvType=pirelab.getPirVectorType(pixelInVec.Type.BaseType,blockInfo.KernelWidth);
    tapDelayOrder=true;
    includeCurrent=true;
    booleanT=pir_boolean_t();

    for ii=1:blockInfo.KernelHeight
        iiStr=num2str(ii);

        tapOutSigVec(ii)=FASTCoreNet.addSignal(tapOutvType,...
        ['tapOutData_',iiStr]);%#ok<AGROW>


        pirelab.getTapDelayEnabledComp(FASTCoreNet,...
        tapInData.PirOutputSignals(ii),tapOutSigVec(ii),tapValidIn,...
        blockInfo.KernelWidth-1,['tapDelay_',iiStr],0,tapDelayOrder,...
        includeCurrent);




        tapOutSigSplit=tapOutSigVec(ii).split;
        for jj=1:numel(tapOutSigSplit.PirOutputSignals)

            tapOutSig(ii,jj)=tapOutSigSplit.PirOutputSignals(jj);%#ok<AGROW>
        end
    end


    tapOutSigFlat=tapOutSig(:);

    tapOutSigRing=tapOutSigFlat(ringidx);
    tapOutSigCenter=tapOutSigFlat(centeridx);

    inWL=inputType.BaseType.WordLength;
    inFL=inputType.BaseType.FractionLength;

    if blockInfo.numInputPorts==3
        minContrastSig=FASTCoreNet.PirInputSignals(3);
    else
        minContrastSig=FASTCoreNet.addSignal(inputType.BaseType,'minContrastValue');
        fiMinContrast=fi(blockInfo.MinContrast,...
        inputType.BaseType.Signed,inWL,-inFL);
        pirelab.getConstComp(FASTCoreNet,minContrastSig,fiMinContrast);
    end


    centerType=FASTCoreNet.getType('FixedPoint','Signed',true,...
    'WordLength',inWL+2,...
    'FractionLength',inFL);

    centerLo=FASTCoreNet.addSignal(centerType,'centerLo');
    centerHi=FASTCoreNet.addSignal(centerType,'centerHi');
    centerLoreg=FASTCoreNet.addSignal(centerType,'centerLoReg');
    centerHireg=FASTCoreNet.addSignal(centerType,'centerHiReg');

    minConConv=FASTCoreNet.addSignal(centerType,'minConConv');
    centerConv=FASTCoreNet.addSignal(centerType,'centerConv');

    pirelab.getDTCComp(FASTCoreNet,minContrastSig,minConConv,'Floor','Wrap');
    pirelab.getDTCComp(FASTCoreNet,tapOutSigCenter,centerConv,'Floor','Wrap');
    pirelab.getSubComp(FASTCoreNet,[centerConv,minConConv],centerLo);
    pirelab.getAddComp(FASTCoreNet,[centerConv,minConConv],centerHi);
    pirelab.getUnitDelayComp(FASTCoreNet,centerLo,centerLoreg);
    pirelab.getUnitDelayComp(FASTCoreNet,centerHi,centerHireg);



    for ii=1:ringlen
        ringreg(ii)=FASTCoreNet.addSignal(inputType.BaseType,sprintf('ring%dreg',ii));%#ok
        comple(ii)=FASTCoreNet.addSignal(booleanT,sprintf('comp%dle',ii));%#ok
        compge(ii)=FASTCoreNet.addSignal(booleanT,sprintf('comp%dge',ii));%#ok
        complereg(ii)=FASTCoreNet.addSignal(booleanT,sprintf('comp%dlereg',ii));%#ok
        compgereg(ii)=FASTCoreNet.addSignal(booleanT,sprintf('comp%dgereg',ii));%#ok

        pirelab.getUnitDelayComp(FASTCoreNet,tapOutSigRing(ii),ringreg(ii));

        pirelab.getRelOpComp(FASTCoreNet,[ringreg(ii),centerLoreg],comple(ii),'<');
        pirelab.getRelOpComp(FASTCoreNet,[ringreg(ii),centerHireg],compge(ii),'>');


        pirelab.getUnitDelayComp(FASTCoreNet,comple(ii),complereg(ii));
        pirelab.getUnitDelayComp(FASTCoreNet,compge(ii),compgereg(ii));
    end




    for ii=1:ringlen
        compleAnd(ii)=FASTCoreNet.addSignal(booleanT,sprintf('comp%dleAnd',ii));%#ok
        compgeAnd(ii)=FASTCoreNet.addSignal(booleanT,sprintf('comp%dgeAnd',ii));%#ok



        if ii+ringregion-1<=ringlen
            pirelab.getLogicComp(FASTCoreNet,complereg(ii:ii+ringregion-1),compleAnd(ii),'and');
            pirelab.getLogicComp(FASTCoreNet,compgereg(ii:ii+ringregion-1),compgeAnd(ii),'and');
        else
            pirelab.getLogicComp(FASTCoreNet,complereg([ii:ringlen,1:ringregion-(ringlen-ii+1)]),...
            compleAnd(ii),'and');
            pirelab.getLogicComp(FASTCoreNet,compgereg([ii:ringlen,1:ringregion-(ringlen-ii+1)]),...
            compgeAnd(ii),'and');

        end


    end



    compleOr=FASTCoreNet.addSignal(booleanT,'compleOr');
    compgeOr=FASTCoreNet.addSignal(booleanT,'compgeOr');
    compleOrreg=FASTCoreNet.addSignal(booleanT,'compleOrreg');
    compgeOrreg=FASTCoreNet.addSignal(booleanT,'compgeOrreg');

    pirelab.getLogicComp(FASTCoreNet,compleAnd,compleOr,'or');
    pirelab.getLogicComp(FASTCoreNet,compgeAnd,compgeOr,'or');

    compFinal=FASTCoreNet.addSignal(booleanT,'compFinal');
    compFinalreg=FASTCoreNet.addSignal(booleanT,'compFinalreg');

    pirelab.getLogicComp(FASTCoreNet,[compleOrreg,compgeOrreg],compFinal,'or');
    pirelab.getUnitDelayComp(FASTCoreNet,compFinal,compFinalreg);



    centersubringType=FASTCoreNet.getType('FixedPoint','Signed',true,...
    'WordLength',inWL+2,...
    'FractionLength',inFL);


    absringType=FASTCoreNet.getType('FixedPoint','Signed',true,...
    'WordLength',inWL+2+ceil(log2(ringlen)),...
    'FractionLength',inFL);

    absringzero=FASTCoreNet.addSignal(absringType,'absringzero');
    pirelab.getConstComp(FASTCoreNet,absringzero,0);
    centerpixeldtc=FASTCoreNet.addSignal(centersubringType,'centerpixeldtc');
    pirelab.getDTCComp(FASTCoreNet,tapOutSigCenter,centerpixeldtc,'Floor','Wrap');
    for ii=1:ringlen

        ringdtc(ii)=FASTCoreNet.addSignal(centersubringType,sprintf('centersub%dring',ii));%#ok
        centersubring(ii)=FASTCoreNet.addSignal(centersubringType,sprintf('centersub%dring',ii));%#ok
        ringpipe(ii)=FASTCoreNet.addSignal(centersubringType,sprintf('ring%dpipe',ii));%#ok

        pirelab.getDTCComp(FASTCoreNet,tapOutSigRing(ii),ringdtc(ii),'Floor','Wrap');
        pirelab.getSubComp(FASTCoreNet,[centerpixeldtc,ringdtc(ii)],centersubring(ii));
        pirelab.getUnitDelayComp(FASTCoreNet,centersubring(ii),ringpipe(ii));

        absring(ii)=FASTCoreNet.addSignal(absringType,sprintf('abs%dring',ii));%#ok
        absringsub(ii)=FASTCoreNet.addSignal(absringType,sprintf('abs%dringsub',ii));%#ok
        absringpipe(ii)=FASTCoreNet.addSignal(absringType,sprintf('abs%dringpipe',ii));%#ok
        pirelab.getAbsComp(FASTCoreNet,ringpipe(ii),absring(ii));
        pirelab.getSubComp(FASTCoreNet,[absring(ii),minContrastSig],absringsub(ii));
        pirelab.getUnitDelayComp(FASTCoreNet,absringsub(ii),absringpipe(ii));

        ringgepresum(ii)=FASTCoreNet.addSignal(absringType,sprintf('ringge%dpresum',ii));%#ok
        ringlepresum(ii)=FASTCoreNet.addSignal(absringType,sprintf('ringle%dpresum',ii));%#ok

        pirelab.getSwitchComp(FASTCoreNet,[absringzero,absringpipe(ii)],ringgepresum(ii),compgereg(ii));
        pirelab.getSwitchComp(FASTCoreNet,[absringzero,absringpipe(ii)],ringlepresum(ii),complereg(ii));
    end



    cornergeSum=FASTCoreNet.addSignal(absringType,'cornergeSum');
    cornerleSum=FASTCoreNet.addSignal(absringType,'cornerleSum');












    switch blockInfo.Method
    case 'FAST 5 of 8'
        finalDelay=finalDelay-2;

        io=1;
        for ii=1:2:8
            soege1(io)=FASTCoreNet.addSignal(absringType,sprintf('sumge1%dadd',ii));%#ok
            soele1(io)=FASTCoreNet.addSignal(absringType,sprintf('sumle1%dadd',ii));%#ok
            soege1reg(io)=FASTCoreNet.addSignal(absringType,sprintf('sumge1%dreg',ii));%#ok
            soele1reg(io)=FASTCoreNet.addSignal(absringType,sprintf('sumle1%dreg',ii));%#ok
            pirelab.getAddComp(FASTCoreNet,[ringgepresum(ii),ringgepresum(ii+1)],soege1(io));
            pirelab.getAddComp(FASTCoreNet,[ringlepresum(ii),ringlepresum(ii+1)],soele1(io));
            pirelab.getUnitDelayComp(FASTCoreNet,soege1(io),soege1reg(io));
            pirelab.getUnitDelayComp(FASTCoreNet,soele1(io),soele1reg(io));
            io=io+1;
        end

        io=1;
        for ii=1:2:4
            soege2(io)=FASTCoreNet.addSignal(absringType,sprintf('sumge2%dadd',ii));%#ok
            soele2(io)=FASTCoreNet.addSignal(absringType,sprintf('sumle2%dadd',ii));%#ok
            soege2reg(io)=FASTCoreNet.addSignal(absringType,sprintf('sumge2%dreg',ii));%#ok
            soele2reg(io)=FASTCoreNet.addSignal(absringType,sprintf('sumle2%dreg',ii));%#ok
            pirelab.getAddComp(FASTCoreNet,[soege1reg(ii),soege1reg(ii+1)],soege2(io));
            pirelab.getAddComp(FASTCoreNet,[soele1reg(ii),soele1reg(ii+1)],soele2(io));
            pirelab.getUnitDelayComp(FASTCoreNet,soege2(io),soege2reg(io));
            pirelab.getUnitDelayComp(FASTCoreNet,soele2(io),soele2reg(io));
            io=io+1;
        end

        soege3=FASTCoreNet.addSignal(absringType,sprintf('sumge3%dadd',1));
        soele3=FASTCoreNet.addSignal(absringType,sprintf('sumle3%dadd',1));
        soege3reg=FASTCoreNet.addSignal(absringType,sprintf('sumge3%dreg',1));
        soele3reg=FASTCoreNet.addSignal(absringType,sprintf('sumle3%dreg',1));
        pirelab.getAddComp(FASTCoreNet,[soege2reg(1),soege2reg(2)],soege3);
        pirelab.getAddComp(FASTCoreNet,[soele2reg(1),soele2reg(2)],soele3);
        pirelab.getUnitDelayComp(FASTCoreNet,soege3,soege3reg);
        pirelab.getUnitDelayComp(FASTCoreNet,soele3,soele3reg);

        cornerleSum=soele3reg;
        cornergeSum=soege3reg;

        pirelab.getIntDelayComp(FASTCoreNet,compleOr,compleOrreg,3);
        pirelab.getIntDelayComp(FASTCoreNet,compgeOr,compgeOrreg,3);

    case 'FAST 7 of 12'
        finalDelay=finalDelay-3;

        io=1;
        for ii=1:2:12
            soege1(io)=FASTCoreNet.addSignal(absringType,sprintf('sumge1%dadd',ii));%#ok
            soele1(io)=FASTCoreNet.addSignal(absringType,sprintf('sumle1%dadd',ii));%#ok
            soege1reg(io)=FASTCoreNet.addSignal(absringType,sprintf('sumge1%dreg',ii));%#ok
            soele1reg(io)=FASTCoreNet.addSignal(absringType,sprintf('sumle1%dreg',ii));%#ok
            pirelab.getAddComp(FASTCoreNet,[ringgepresum(ii),ringgepresum(ii+1)],soege1(io));
            pirelab.getAddComp(FASTCoreNet,[ringlepresum(ii),ringlepresum(ii+1)],soele1(io));
            pirelab.getUnitDelayComp(FASTCoreNet,soege1(io),soege1reg(io));
            pirelab.getUnitDelayComp(FASTCoreNet,soele1(io),soele1reg(io));
            io=io+1;
        end

        io=1;
        for ii=1:2:6
            soege2(io)=FASTCoreNet.addSignal(absringType,sprintf('sumge2%dadd',ii));%#ok
            soele2(io)=FASTCoreNet.addSignal(absringType,sprintf('sumle2%dadd',ii));%#ok
            soege2reg(io)=FASTCoreNet.addSignal(absringType,sprintf('sumge2%dreg',ii));%#ok
            soele2reg(io)=FASTCoreNet.addSignal(absringType,sprintf('sumle2%dreg',ii));%#ok
            pirelab.getAddComp(FASTCoreNet,[soege1reg(ii),soege1reg(ii+1)],soege2(io));
            pirelab.getAddComp(FASTCoreNet,[soele1reg(ii),soele1reg(ii+1)],soele2(io));
            pirelab.getUnitDelayComp(FASTCoreNet,soege2(io),soege2reg(io));
            pirelab.getUnitDelayComp(FASTCoreNet,soele2(io),soele2reg(io));
            io=io+1;
        end

        io=1;
        for ii=1:2:3
            if ii~=3
                soege3(io)=FASTCoreNet.addSignal(absringType,sprintf('sumge3%dadd',ii));%#ok
                soele3(io)=FASTCoreNet.addSignal(absringType,sprintf('sumle3%dadd',ii));%#ok
            else

                soege3(io)=soege2reg(ii);%#ok
                soele3(io)=soele2reg(ii);%#ok
            end
            soege3reg(io)=FASTCoreNet.addSignal(absringType,sprintf('sumge3%dreg',ii));%#ok
            soele3reg(io)=FASTCoreNet.addSignal(absringType,sprintf('sumle3%dreg',ii));%#ok
            if ii~=3
                pirelab.getAddComp(FASTCoreNet,[soege2reg(ii),soege2reg(ii+1)],soege3(io));
                pirelab.getAddComp(FASTCoreNet,[soele2reg(ii),soele2reg(ii+1)],soele3(io));
            end
            pirelab.getUnitDelayComp(FASTCoreNet,soege3(io),soege3reg(io));
            pirelab.getUnitDelayComp(FASTCoreNet,soele3(io),soele3reg(io));
            io=io+1;
        end

        soege4=FASTCoreNet.addSignal(absringType,sprintf('sumge4%dadd',1));
        soele4=FASTCoreNet.addSignal(absringType,sprintf('sumle4%dadd',1));
        soege4reg=FASTCoreNet.addSignal(absringType,sprintf('sumge4%dreg',1));
        soele4reg=FASTCoreNet.addSignal(absringType,sprintf('sumle4%dreg',1));
        pirelab.getAddComp(FASTCoreNet,[soege3reg(1),soege3reg(2)],soege4);
        pirelab.getAddComp(FASTCoreNet,[soele3reg(1),soele3reg(2)],soele4);
        pirelab.getUnitDelayComp(FASTCoreNet,soege4,soege4reg);
        pirelab.getUnitDelayComp(FASTCoreNet,soele4,soele4reg);

        cornerleSum=soele4reg;
        cornergeSum=soege4reg;

        pirelab.getIntDelayComp(FASTCoreNet,compleOr,compleOrreg,4);
        pirelab.getIntDelayComp(FASTCoreNet,compgeOr,compgeOrreg,4);

    case 'FAST 9 of 16'
        finalDelay=finalDelay-3;

        io=1;
        for ii=1:2:16
            soege1(io)=FASTCoreNet.addSignal(absringType,sprintf('sumge1%dadd',ii));%#ok
            soele1(io)=FASTCoreNet.addSignal(absringType,sprintf('sumle1%dadd',ii));%#ok
            soege1reg(io)=FASTCoreNet.addSignal(absringType,sprintf('sumge1%dreg',ii));%#ok
            soele1reg(io)=FASTCoreNet.addSignal(absringType,sprintf('sumle1%dreg',ii));%#ok
            pirelab.getAddComp(FASTCoreNet,[ringgepresum(ii),ringgepresum(ii+1)],soege1(io));
            pirelab.getAddComp(FASTCoreNet,[ringlepresum(ii),ringlepresum(ii+1)],soele1(io));
            pirelab.getUnitDelayComp(FASTCoreNet,soege1(io),soege1reg(io));
            pirelab.getUnitDelayComp(FASTCoreNet,soele1(io),soele1reg(io));
            io=io+1;
        end

        io=1;
        for ii=1:2:8
            soege2(io)=FASTCoreNet.addSignal(absringType,sprintf('sumge2%dadd',ii));%#ok
            soele2(io)=FASTCoreNet.addSignal(absringType,sprintf('sumle2%dadd',ii));%#ok
            soege2reg(io)=FASTCoreNet.addSignal(absringType,sprintf('sumge2%dreg',ii));%#ok
            soele2reg(io)=FASTCoreNet.addSignal(absringType,sprintf('sumle2%dreg',ii));%#ok
            pirelab.getAddComp(FASTCoreNet,[soege1reg(ii),soege1reg(ii+1)],soege2(io));
            pirelab.getAddComp(FASTCoreNet,[soele1reg(ii),soele1reg(ii+1)],soele2(io));
            pirelab.getUnitDelayComp(FASTCoreNet,soege2(io),soege2reg(io));
            pirelab.getUnitDelayComp(FASTCoreNet,soele2(io),soele2reg(io));
            io=io+1;
        end

        io=1;
        for ii=1:2:4
            soege3(io)=FASTCoreNet.addSignal(absringType,sprintf('sumge3%dadd',ii));%#ok
            soele3(io)=FASTCoreNet.addSignal(absringType,sprintf('sumle3%dadd',ii));%#ok
            soege3reg(io)=FASTCoreNet.addSignal(absringType,sprintf('sumge3%dreg',ii));%#ok
            soele3reg(io)=FASTCoreNet.addSignal(absringType,sprintf('sumle3%dreg',ii));%#ok
            pirelab.getAddComp(FASTCoreNet,[soege2reg(ii),soege2reg(ii+1)],soege3(io));
            pirelab.getAddComp(FASTCoreNet,[soele2reg(ii),soele2reg(ii+1)],soele3(io));
            pirelab.getUnitDelayComp(FASTCoreNet,soege3(io),soege3reg(io));
            pirelab.getUnitDelayComp(FASTCoreNet,soele3(io),soele3reg(io));
            io=io+1;
        end

        soege4=FASTCoreNet.addSignal(absringType,sprintf('sumge4%dadd',1));
        soele4=FASTCoreNet.addSignal(absringType,sprintf('sumle4%dadd',1));
        soege4reg=FASTCoreNet.addSignal(absringType,sprintf('sumge4%dreg',1));
        soele4reg=FASTCoreNet.addSignal(absringType,sprintf('sumle4%dreg',1));
        pirelab.getAddComp(FASTCoreNet,[soege3reg(1),soege3reg(2)],soege4);
        pirelab.getAddComp(FASTCoreNet,[soele3reg(1),soele3reg(2)],soele4);
        pirelab.getUnitDelayComp(FASTCoreNet,soege4,soege4reg);
        pirelab.getUnitDelayComp(FASTCoreNet,soele4,soele4reg);

        cornerleSum=soele4reg;
        cornergeSum=soege4reg;

        pirelab.getIntDelayComp(FASTCoreNet,compleOr,compleOrreg,4);
        pirelab.getIntDelayComp(FASTCoreNet,compgeOr,compgeOrreg,4);

    otherwise

    end







    cornerleSumSwitch=FASTCoreNet.addSignal(absringType,'cornerleSumSwitch');
    cornergeSumSwitch=FASTCoreNet.addSignal(absringType,'cornergeSumSwitch');
    cornerMax=FASTCoreNet.addSignal(absringType,'cornerMax');
    cornerMaxreg=FASTCoreNet.addSignal(absringType,'cornerMaxreg');
    cornerConvert=FASTCoreNet.addSignal(cornerOutType,'cornerConvert');
    cornerpreout=FASTCoreNet.addSignal(cornerOutType,'cornerpreout');
    zerooutconst=FASTCoreNet.addSignal(cornerOutType,'cornerzero');

    pirelab.getSwitchComp(FASTCoreNet,[absringzero,cornerleSum],cornerleSumSwitch,compleOrreg);
    pirelab.getSwitchComp(FASTCoreNet,[absringzero,cornergeSum],cornergeSumSwitch,compgeOrreg);

    pirelab.getSwitchComp(FASTCoreNet,[cornergeSumSwitch,cornerleSumSwitch],cornerMax,compgeOrreg,'','==',1);
    pirelab.getUnitDelayComp(FASTCoreNet,cornerMax,cornerMaxreg);

    pirelab.getDTCComp(FASTCoreNet,cornerMaxreg,cornerConvert,...
    blockInfo.RoundingMethod,blockInfo.OverflowAction);

    pirelab.getConstComp(FASTCoreNet,zerooutconst,0);
    pirelab.getSwitchComp(FASTCoreNet,[cornerConvert,zerooutconst],cornerpreout,compFinalreg,'','==',1);
    pirelab.getIntDelayComp(FASTCoreNet,cornerpreout,cornerOut,finalDelay);



