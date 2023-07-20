function net=elabBiquadFilter(this,net,blockInfo,insignals,outsignals)




    din=insignals;
    dout=outsignals;

    dataIn=din(1);
    validIn=din(2);

    dataOut=dout(1);
    validOut=dout(2);

    dataRate=din(1).simulinkRate;
    InportNames={din(1).Name};
    InportTypes=[din(1).Type];
    InportRates=dataRate;

    for loop=2:length(din)
        InportNames{end+1}=din(loop).Name;
        InportTypes=[InportTypes;din(loop).Type];%#ok<*AGROW>
        InportRates=[InportRates;dataRate];
    end

    OutportNames={dout(1).Name};
    OutportTypes=[dout(1).Type];
    for loop=2:length(dout)
        OutportNames{end+1}=dout(loop).Name;
        OutportTypes=[OutportTypes;dout(loop).Type];
    end


    if blockInfo.FrameSize==1
        inWL=InportTypes(1).WordLength;
        inFL=InportTypes(1).FractionLength;
        outWL=OutportTypes(1).WordLength;
        outFL=OutportTypes(1).FractionLength;
    else
        inWL=InportTypes(1).BaseType.WordLength;
        inFL=InportTypes(1).BaseType.FractionLength;
        outWL=OutportTypes(1).BaseType.WordLength;
        outFL=OutportTypes(1).BaseType.FractionLength;
    end


    sec0reg=net.addSignal(InportTypes(1),'sec0reg');
    sec0reg.SimulinkRate=dataRate;
    ctrlType=InportTypes(2);
    sec0validreg=net.addSignal(ctrlType,'sec0validreg');
    sec0validreg.SimulinkRate=dataRate;
    pirelab.getUnitDelayComp(net,dataIn,sec0reg,'sec0dataregister');
    pirelab.getUnitDelayComp(net,validIn,sec0validreg,'sec0validregister');
    finalDelay=1;

    scalarMulTypeFirstType=net.getType('FixedPoint','Signed',true,...
    'WordLength',inWL+blockInfo.SVWL,...
    'FractionLength',inFL+blockInfo.SVFL);
    if blockInfo.FrameSize==1
        secMulTypeFirst=scalarMulTypeFirstType;
    else
        secMulTypeFirst=pirelab.getPirVectorType(scalarMulTypeFirstType,[blockInfo.FrameSize,1]);
    end
    sec0mul=net.addSignal(secMulTypeFirst,'sec0mul');
    sec0mul.SimulinkRate=dataRate;
    sec0mulreg=net.addSignal(secMulTypeFirst,'sec0mulreg');
    sec0mulreg.SimulinkRate=dataRate;
    sec0mulvalidreg=net.addSignal(ctrlType,'sec0mulvalidreg');
    sec0mulvalidreg.SimulinkRate=dataRate;
    pirelab.getUnitDelayComp(net,sec0mul,sec0mulreg,'sec0muldataregister');
    pirelab.getUnitDelayComp(net,sec0validreg,sec0mulvalidreg,'sec0mulvalidregister');
    finalDelay=finalDelay+1;

    outputType=OutportTypes(1);
    sec0dtc=net.addSignal(outputType,'sec0dtc');
    sec0dtc.SimulinkRate=dataRate;
    sec0out=net.addSignal(outputType,'sec0out');
    sec0out.SimulinkRate=dataRate;
    sec0validout=net.addSignal(ctrlType,'sec0validout');
    sec0validout.SimulinkRate=dataRate;
    if blockInfo.FrameSize==1

        pirelab.getGainComp(net,sec0reg,sec0mul,blockInfo.SVCoeffs(1),...
        blockInfo.gainMode,blockInfo.gainOptimMode);
        pirelab.getDTCComp(net,sec0mulreg,sec0dtc,...
        blockInfo.RoundingMethod,blockInfo.OverflowAction);
    else
        s0mrsplit=sec0mulreg.split;
        s0regsplit=sec0reg.split;
        for ii=1:blockInfo.FrameSize
            scalar0mul(ii)=net.addSignal(secMulTypeFirst.BaseType,sprintf('scalar0mul%d',ii));
            scalar0mul(ii).SimulinkRate=dataRate;
            scalar0dtc(ii)=net.addSignal(outputType.BaseType,sprintf('scalar0dtc%d',ii));
            scalar0dtc(ii).SimulinkRate=dataRate;

            pirelab.getGainComp(net,s0regsplit.PirOutputSignals(ii),scalar0mul(ii),blockInfo.SVCoeffs(1),...
            blockInfo.gainMode,blockInfo.gainOptimMode);
            pirelab.getDTCComp(net,s0mrsplit.PirOutputSignals(ii),scalar0dtc(ii),...
            blockInfo.RoundingMethod,blockInfo.OverflowAction);
        end
        pirelab.getMuxComp(net,scalar0mul,sec0mul);
        pirelab.getMuxComp(net,scalar0dtc,sec0dtc);
    end

    pirelab.getUnitDelayComp(net,sec0dtc,sec0out,'sec0OutRegister');
    pirelab.getUnitDelayComp(net,sec0mulvalidreg,sec0validout,'sec0validoutregister');
    finalDelay=finalDelay+1;

    scalarsecMulType=net.getType('FixedPoint','Signed',true,...
    'WordLength',blockInfo.sectionTypeWL+blockInfo.SVWL,...
    'FractionLength',blockInfo.sectionTypeFL+blockInfo.SVFL);
    if blockInfo.FrameSize==1
        secMulType=scalarsecMulType;
    else
        secMulType=pirelab.getPirVectorType(scalarsecMulType,[blockInfo.FrameSize,1]);
    end
    inDataSec=sec0out;
    inValidSec=sec0validout;
    for sectionNum=1:blockInfo.NumSections
        switch blockInfo.Structure
        case 'Direct form II'
            [subnet,secDelay]=elabDF2(this,net,blockInfo,sectionNum);
        case 'Direct form II transposed'
            [subnet,secDelay]=elabDF2T(this,net,blockInfo,sectionNum);
        case 'Pipelined feedback form'
            if blockInfo.FrameSize==1
                [subnet,secDelay]=elabScalarPipe(this,net,blockInfo,sectionNum);
            else
                [subnet,secDelay]=elabFramePipe(this,net,blockInfo,sectionNum);
            end
        end
        finalDelay=finalDelay+secDelay;

        secout=net.addSignal(outputType,sprintf('sec%dout',sectionNum));
        secout.SimulinkRate=dataRate;
        secvalidout=net.addSignal(ctrlType,sprintf('sec%dvalidout',sectionNum));
        secvalidout.SimulinkRate=dataRate;

        pirelab.instantiateNetwork(net,subnet,[inDataSec,inValidSec],[secout,secvalidout],sprintf('BiquadSection%d_inst',sectionNum));

        secNmul=net.addSignal(secMulType,sprintf('sec%dmul',sectionNum));
        secNmul.SimulinkRate=dataRate;
        secNmulreg=net.addSignal(secMulType,sprintf('sec%dmulreg',sectionNum));
        secNmulreg.SimulinkRate=dataRate;
        secNmulvalidreg=net.addSignal(ctrlType,sprintf('sec%dmulvalidreg',sectionNum));
        secNmulvalidreg.SimulinkRate=dataRate;
        pirelab.getUnitDelayComp(net,secNmul,secNmulreg,sprintf('sec%dmuldataregister',sectionNum));
        pirelab.getUnitDelayComp(net,secvalidout,secNmulvalidreg,sprintf('sec%dmulvalidregister',sectionNum));
        finalDelay=finalDelay+1;
        secNdtc=net.addSignal(outputType,sprintf('sec%ddtc',sectionNum));
        secNdtc.SimulinkRate=dataRate;
        secNout=net.addSignal(outputType,sprintf('sec%dout',sectionNum));
        secNout.SimulinkRate=dataRate;
        secNvalidout=net.addSignal(ctrlType,sprintf('sec%dvalidout',sectionNum));
        secNvalidout.SimulinkRate=dataRate;

        if blockInfo.FrameSize==1

            pirelab.getGainComp(net,secout,secNmul,blockInfo.SVCoeffs(sectionNum+1),...
            blockInfo.gainMode,blockInfo.gainOptimMode);
            pirelab.getDTCComp(net,secNmulreg,secNdtc,...
            blockInfo.RoundingMethod,blockInfo.OverflowAction);
        else
            sNmrsplit=secNmulreg.split;
            sNregsplit=secout.split;
            for ii=1:blockInfo.FrameSize
                scalarNmul(ii)=net.addSignal(secMulType.BaseType,sprintf('scalar%dmul%d',sectionNum,ii));
                scalarNmul(ii).SimulinkRate=dataRate;
                scalarNdtc(ii)=net.addSignal(outputType.BaseType,sprintf('scalar%ddtc%d',sectionNum,ii));
                scalarNdtc(ii).SimulinkRate=dataRate;

                pirelab.getGainComp(net,sNregsplit.PirOutputSignals(ii),scalarNmul(ii),blockInfo.SVCoeffs(sectionNum+1),...
                blockInfo.gainMode,blockInfo.gainOptimMode);
                pirelab.getDTCComp(net,sNmrsplit.PirOutputSignals(ii),scalarNdtc(ii),...
                blockInfo.RoundingMethod,blockInfo.OverflowAction);
            end
            pirelab.getMuxComp(net,scalarNmul,secNmul);
            pirelab.getMuxComp(net,scalarNdtc,secNdtc);
        end
        pirelab.getUnitDelayComp(net,secNdtc,secNout,sprintf('sec%dOutRegister',sectionNum));
        pirelab.getUnitDelayComp(net,secNmulvalidreg,secNvalidout,sprintf('sec%dvalidoutregister',sectionNum));
        finalDelay=finalDelay+1;
        inDataSec=secNout;
        inValidSec=secNvalidout;
    end

    preout=net.addSignal(outputType,'preout');
    preout.SimulinkRate=dataRate;
    if blockInfo.FrameSize==1
        zerooutconst=net.addSignal(outputType,'zerooutconst');
        pirelab.getConstComp(net,zerooutconst,0);
        pirelab.getSwitchComp(net,[inDataSec,zerooutconst],preout,inValidSec,'','==',1);
    else
        zerooutconst=net.addSignal(outputType.BaseType,'zerooutconst');
        zerooutconst.SimulinkRate=dataRate;
        pirelab.getConstComp(net,zerooutconst,0);
        inDataSplit=inDataSec.split;
        for ii=1:blockInfo.FrameSize
            scalarpreout(ii)=net.addSignal(outputType.BaseType,sprintf('scalarpreout%d',ii));
            scalarpreout(ii).SimulinkRate=dataRate;
            pirelab.getSwitchComp(net,[inDataSplit.PirOutputSignals(ii),zerooutconst],scalarpreout(ii),inValidSec,'','==',1);
        end
        pirelab.getMuxComp(net,scalarpreout,preout);
    end
    pirelab.getUnitDelayComp(net,preout,dataOut,'OutRegister');
    pirelab.getUnitDelayComp(net,inValidSec,validOut,'ValidOutRegister');
end

