function nComp=elaborate(this,hN,hC)






    blockInfo=getBlockInfo(this,hC);


    inportnames={};
    outportnames={};


    if strcmp(blockInfo.OutputMaskSrc,'Input port')
        inportnames{length(inportnames)+1}='inportOutputMaskVec';
    end

    if strcmp(blockInfo.Reset,'on')
        inportnames{length(inportnames)+1}='inportReset';
    end

    outportnames{1}='PN Sequence';




    topNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC,...
    'InportNames',inportnames,...
    'OutportNames',outportnames...
    );

    topNet.addComment('PN Sequence Generator');







    insignals=topNet.PirInputSignals;


    p_PNSeqOut=topNet.PirOutputSignals;
    p_PNSeqOut.SimulinkRate=blockInfo.SimulinkRate;



    polyOrder=length(blockInfo.Polynomial)-1;
    polyVecType=pirelab.createPirArrayType(pir_boolean_t,[1,polyOrder]);
    shiftVecType=pirelab.createPirArrayType(pir_boolean_t,[1,polyOrder-1]);
    polyTermsVecType=pirelab.createPirArrayType(pir_boolean_t,[1,length(find(blockInfo.Polynomial(2:end)))]);
    boolType=pir_boolean_t;
    ufixType=pir_unsigned_t(blockInfo.OutputDataBits);


    s_cInitStates=topNet.addSignal2('Name','InitStates','Type',polyVecType);
    s_cInitStates.SimulinkRate=blockInfo.SimulinkRate;


    s_Rst=topNet.addSignal2('Name','Reset','Type',boolType);
    if strcmp(blockInfo.Reset,'on')
        s_Rst=insignals(blockInfo.InportResetIdx);
        s_Rst.SimulinkRate=blockInfo.SimulinkRate;
    end


    s_OutputMask=topNet.addSignal2('Name','OutputMask','Type',polyVecType);
    s_OutputMask.SimulinkRate=blockInfo.SimulinkRate;


    s_tdlPrevous=topNet.addSignal2('Name','TDLPrevious','Type',polyVecType);
    s_tdlPrevous.SimulinkRate=blockInfo.SimulinkRate;


    if strcmp(blockInfo.OutputMaskSrc,'Input port')
        s_OutputMaskInp=insignals(blockInfo.InportMaskIdx);
        s_OutputMaskInp.SimulinkRate=blockInfo.SimulinkRate;
    end

    for sigStage=1:blockInfo.OutputDataBits

        s_tdl(sigStage)=topNet.addSignal2('Name','TDL','Type',polyVecType);%#ok
        s_tdl(sigStage).SimulinkRate=blockInfo.SimulinkRate;%#ok


        s_shiftSelToVecConcat(sigStage)=topNet.addSignal2('Name','ShiftTerms','Type',shiftVecType);%#ok
        s_shiftSelToVecConcat(sigStage).SimulinkRate=blockInfo.SimulinkRate;%#ok
        s_polySelToPolyXOR(sigStage)=topNet.addSignal2('Name','PolyTerms','Type',polyTermsVecType);%#ok
        s_polySelToPolyXOR(sigStage).SimulinkRate=blockInfo.SimulinkRate;%#ok
        s_polyXORToVecConcat(sigStage)=topNet.addSignal2('Name','PNSeqOut','Type',boolType);%#ok
        s_polyXORToVecConcat(sigStage).SimulinkRate=blockInfo.SimulinkRate;%#ok


        s_MaskAndToXOR(sigStage)=topNet.addSignal2('Name','MaskANDtoXOR','Type',polyVecType);%#ok
        s_MaskAndToXOR(sigStage).SimulinkRate=blockInfo.SimulinkRate;%#ok


        s_pnSeq(sigStage)=topNet.addSignal2('Name','PNSeqBits','Type',boolType);%#ok
        s_pnSeq(sigStage).SimulinkRate=blockInfo.SimulinkRate;%#ok
    end


    s_tdl(blockInfo.OutputDataBits+1)=topNet.addSignal2('Name','TDL','Type',polyVecType);
    s_tdl(blockInfo.OutputDataBits+1).SimulinkRate=blockInfo.SimulinkRate;


    s_PNSeqUfix=topNet.addSignal2('Name','PNUfix','Type',ufixType);



    pirelab.getConstComp(topNet,s_cInitStates,blockInfo.InitialStates,'c_InitStates','off');

    if strcmp(blockInfo.Reset,'off')
        pirelab.getConstComp(topNet,s_Rst,false,'c_ResetOff');
    end

    if~strcmp(blockInfo.OutputMaskSrc,'Input port')
        pirelab.getConstComp(topNet,s_OutputMask,blockInfo.OutputMaskVec,'c_OutputMask','off');
    else

        if s_OutputMaskInp.Type.isColumnVector
            pirelab.getTransposeComp(topNet,s_OutputMaskInp,s_OutputMask,'transColMaskInp');
        else
            pirelab.getWireComp(topNet,s_OutputMaskInp,s_OutputMask,'InpMaskToInpSig');
        end
    end

    switchArrayMode=1;
    pirelab.getMultiPortSwitchComp(topNet,[s_Rst,s_tdlPrevous,s_cInitStates],s_tdl(1),switchArrayMode);


    pirelab.getUnitDelayComp(topNet,s_tdl(end),s_tdlPrevous,'VectorTDL',blockInfo.InitialStates);


    for pnStage=1:blockInfo.OutputDataBits

        pirelab.getSelectorComp(topNet,s_tdl(pnStage),s_shiftSelToVecConcat(pnStage),'one-based',...
        {'Index vector (dialog)','Index vector (dialog)'},...
        {1,1:polyOrder-1},...
        {'Inherit from "Index"','Inherit from "Index"'},'2','selShift');

        pirelab.getSelectorComp(topNet,s_tdl(pnStage),s_polySelToPolyXOR(pnStage),'one-based',...
        {'Index vector (dialog)','Index vector (dialog)'},...
        {1,find(blockInfo.Polynomial(2:end))},...
        {'Inherit from "Index"','Inherit from "Index"'},'2','selShift');

        pirelab.getBitwiseOpComp(topNet,s_polySelToPolyXOR(pnStage),s_polyXORToVecConcat(pnStage),'XOR','xorPoly');

        pirelab.getConcatenateComp(topNet,[s_polyXORToVecConcat(pnStage),s_shiftSelToVecConcat(pnStage)],s_tdl(pnStage+1),'Vector',1,'polyShiftVecConcat');

        pirelab.getBitwiseOpComp(topNet,[s_tdl(pnStage),s_OutputMask],s_MaskAndToXOR(pnStage),'AND','andMask');

        pirelab.getBitwiseOpComp(topNet,s_MaskAndToXOR(pnStage),s_pnSeq(pnStage),'XOR','xorMask');
    end


    pirelab.getBitConcatComp(topNet,s_pnSeq,s_PNSeqUfix,'PNSeqBitConcatFix');
    pirelab.getDTCComp(topNet,s_PNSeqUfix,p_PNSeqOut);


    nComp=pirelab.instantiateNetwork(hN,topNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);
end
