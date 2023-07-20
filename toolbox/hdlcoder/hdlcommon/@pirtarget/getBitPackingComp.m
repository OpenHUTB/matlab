function hC=getBitPackingComp(hN,hInSignals,hOutSignals,regID)








    data_in=hInSignals(1);
    data_out=hOutSignals(1);


    [inputDimLen,inputBaseType]=pirelab.getVectorTypeInfo(data_in);


    data_ins=hdlhandles(inputDimLen,1);
    for ii=1:inputDimLen
        data_ins(ii)=hN.addSignal(inputBaseType,sprintf('pack_in_%s_%d',regID,ii));
    end
    hC=pirelab.getDemuxComp(hN,data_in,data_ins);


    [outputDimLen,outputBaseType]=pirelab.getVectorTypeInfo(data_out);


    data_outs=hdlhandles(outputDimLen,1);
    for ii=1:outputDimLen
        data_outs(ii)=hN.addSignal(outputBaseType,sprintf('pack_out_%s_%d',regID,ii));
    end
    pirelab.getMuxComp(hN,data_outs,data_out);


    inputWordLength=inputBaseType.WordLength;
    outputWordLength=outputBaseType.WordLength;
    packNumber=floor(outputWordLength/inputWordLength);
    if packNumber~=outputWordLength/inputWordLength
        error(message('hdlcommon:workflow:BitPackingUnsupported',sprintf('bitpacking_%s',regID)));
    end


    for ii=1:outputDimLen
        concat_out=data_outs(ii);

        concat_ins=hdlhandles(packNumber,1);
        for jj=1:packNumber

            idx_in=(ii-1)*packNumber+jj;

            if idx_in<=inputDimLen
                concat_ins(jj)=data_ins(idx_in);
            else
                concat_ins(jj)=data_ins(end);
            end
        end

        pirelab.getBitConcatComp(hN,concat_ins(end:-1:1),concat_out,sprintf('concat_%s',regID));
    end

end


