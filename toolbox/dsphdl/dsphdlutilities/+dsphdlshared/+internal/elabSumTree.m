function sumTreeImpl=elabSumTree(hNet,insignals,outsignals,...
    RoundingMethod,OverflowAction,hasSyncResetInput,compName)




    if nargin<7
        compName='sumTree';
    end

    din=insignals;
    dout=outsignals;

    dataRate=din(1).simulinkRate;
    InportNames={din(1).Name};
    InportTypes=[din(1).Type];
    InportRates=[dataRate];

    OutportNames={dout(1).Name};
    OutportTypes=[dout(1).Type];
    for loop=2:length(din)
        InportNames{end+1}=din(loop).Name;
        InportTypes=[InportTypes;din(loop).Type];%#ok<*AGROW>
        InportRates=[InportRates;dataRate];
    end
    for loop=2:length(dout)
        OutportNames{end+1}=dout(loop).Name;
        OutportTypes=[OutportTypes;dout(loop).Type];
    end


    sumTreeImpl=pirelab.createNewNetwork(...
    'Network',hNet,...
    'Name',compName,...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );
    insignals=sumTreeImpl.PirInputSignals;

    outsignals=sumTreeImpl.PirOutputSignals;

    for loop=1:length(outsignals)
        outsignals(loop).SimulinkRate=insignals(1).SimulinkRate;
    end

    dataIn=insignals(1);
    dataInType=pirgetdatatypeinfo(dataIn.Type);
    if dataInType.iscomplex
        FPType=hdlcoder.tp_complex(pir_fixpt_t(dataInType.issigned,dataInType.wordsize,dataInType.binarypoint));
    else
        FPType=pir_fixpt_t(dataInType.issigned,dataInType.wordsize,dataInType.binarypoint);
    end
    dataRate=dataIn.simulinkRate;
    din_vld=insignals(2);
    din_vld.SimulinkRate=dataRate;
    if hasSyncResetInput
        syncReset=insignals(3);
        syncReset.Simulinkrate=dataRate;
    else
        syncReset='';
    end

    DATA_VECSIZE=dataInType.dims;
    DATA_CMPLX=dataInType.iscomplex;

    for loop=1:DATA_VECSIZE
        if DATA_VECSIZE==1
            dinV(loop)=dataIn;
        else
            dinV(loop)=dataIn.split.PirOutputSignals(loop);
        end
    end


    adderDepth=ceil(log2(length(dinV)));
    for loop1=1:adderDepth
        oddInput=mod(length(dinV),2);
        if oddInput
            dinOdd=dinV(end);
            dinEven=dinV(1:end-1);
            clear dinV;
            dinV=dinEven;
        end
        for loop2=1:2:length(dinV)
            index=ceil(loop2/2);
            accS(index)=sumTreeImpl.addSignal2('Type',FPType,'Name',['accS_',int2str(index)]);
            accS(index).SimulinkRate=dataRate;
            accReg(index)=sumTreeImpl.addSignal2('Type',FPType,'Name',['accReg_',int2str(index)]);
            accReg(index).SimulinkRate=dataRate;
            pirelab.getAddComp(sumTreeImpl,[dinV(loop2),dinV(loop2+1)],accS(index));
            pirelab.getIntDelayEnabledResettableComp(sumTreeImpl,accS(index),accReg(index),'',syncReset,1);
        end
        if oddInput
            dinOddReg=sumTreeImpl.addSignal2('Type',FPType,'Name',['dinOddReg',int2str(loop1)]);
            dinOddReg.SimulinkRate=dataRate;
            pirelab.getIntDelayEnabledResettableComp(sumTreeImpl,dinOdd,dinOddReg,'',syncReset,1);
            accReg(end+1)=dinOddReg;
        end
        clear dinV;
        dinV=accReg;
        clear accS;clear accReg;
    end
    if DATA_CMPLX==1
        hT=hdlcoder.tp_complex(outsignals(1).Type.BaseType);
        dout_cast=sumTreeImpl.addSignal2('Type',hT,'Name','dout_cast');
        dout_cast.SimulinkRate=dataRate;
    else
        dout_cast=sumTreeImpl.addSignal2('Type',outsignals(1).Type,'Name','dout_cast');
        dout_cast.SimulinkRate=dataRate;
    end

    pirelab.getDTCComp(sumTreeImpl,dinV(1),dout_cast,RoundingMethod,OverflowAction);

    pirelab.getIntDelayEnabledResettableComp(sumTreeImpl,dout_cast,outsignals(1),'',syncReset,1);
    pirelab.getIntDelayEnabledResettableComp(sumTreeImpl,din_vld,outsignals(2),'',syncReset,adderDepth+1);
    for loop=2:length(hNet.PirInputSignals)
        hNet.PirInputSignals(loop).SimulinkRate=hNet.PirInputSignals(1).SimulinkRate;
    end
end

