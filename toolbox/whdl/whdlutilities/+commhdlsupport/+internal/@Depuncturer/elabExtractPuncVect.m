function extPncVecNet=elabExtractPuncVect(~,topNet,blockInfo,dataRate)



    punclen=blockInfo.PuncturingLength;
    ufix1Type=pir_ufixpt_t(1,0);
    cntType=pir_ufixpt_t(5,0);

    if(punclen~=28)
        padType=pirelab.getPirVectorType(ufix1Type,28-punclen);
    end
    pType=pirelab.getPirVectorType(ufix1Type,28);

    inTop=topNet.PirInputSignals(2);


    extPncVecNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','extractPuncVect',...
    'InportNames',{'Pattern','validin'},...
    'InportTypes',[inTop.Type,ufix1Type],...
    'Inportrates',[dataRate,dataRate],...
    'OutportNames',{'initCount','initCount_vld'},...
    'OutportTypes',[cntType,ufix1Type]...
    );


    pattern=extPncVecNet.PirInputSignals(1);
    validin=extPncVecNet.PirInputSignals(2);

    initcount=extPncVecNet.PirOutputSignals(1);
    initcount_vld=extPncVecNet.PirOutputSignals(2);

    validinReg=extPncVecNet.addSignal(validin.Type,'validinReg');
    pirelab.getIntDelayComp(extPncVecNet,validin,validinReg,2,'validinReg',0);

    pv=extPncVecNet.addSignal(pType,'pv');

    if(punclen~=28)
        punc=extPncVecNet.addSignal(padType,'punc');
        pirelab.getConstComp(extPncVecNet,punc,0);
        pirelab.getConcatenateComp(extPncVecNet,[pattern,punc],pv,'vector',1);
    else
        pirelab.getConcatenateComp(extPncVecNet,pattern,pv,'vector',1);
    end

    flag=extPncVecNet.addSignal(ufix1Type,'flag');
    index=extPncVecNet.addSignal(cntType,'index');

    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities','+commhdlsupport',...
    '+internal','@Depuncturer','cgireml','initPosPuncVector.m'),'r');
    initPosPuncVector=fread(fid,Inf,'char=>char');
    fclose(fid);

    extPncVecNet.addComponent2(...
    'kind','cgireml',...
    'Name','initPosPuncVector',...
    'InputSignals',pv,...
    'OutputSignals',[flag,index],...
    'ExternalSynchronousResetSignal','',...
    'EMLFileName','initPosPuncVector',...
    'EMLFileBody',initPosPuncVector,...
    'EMLFlag_TreatInputIntsAsFixpt',true);


    pirelab.getWireComp(extPncVecNet,index,initcount);

    pirelab.getLogicComp(extPncVecNet,[flag,validinReg],initcount_vld,'and');

end