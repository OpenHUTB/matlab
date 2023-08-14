function hC=getBitUnpackingComp(hN,hInSignals,hOutSignals,regID)








    data_in=hInSignals(1);
    data_out=hOutSignals(1);


    [inputDimLen,inputBaseType]=pirelab.getVectorTypeInfo(data_in);


    data_ins=hdlhandles(inputDimLen,1);
    for ii=1:inputDimLen
        data_ins(ii)=hN.addSignal(inputBaseType,sprintf('unpack_in_%s_%d',regID,ii));
    end
    hC=pirelab.getDemuxComp(hN,data_in,data_ins);


    [outputDimLen,outputBaseType]=pirelab.getVectorTypeInfo(data_out);
    outputWordLength=outputBaseType.WordLength;
    outputUnsignedType=pir_ufixpt_t(outputWordLength,0);
    vecUnsignedType=pirelab.getPirVectorType(outputUnsignedType,outputDimLen);


    data_out_mux=hN.addSignal(vecUnsignedType,sprintf('unpack_out_%s',regID));
    data_outs=hdlhandles(outputDimLen,1);
    for ii=1:outputDimLen
        data_outs(ii)=hN.addSignal(outputUnsignedType,sprintf('unpack_out_%s_%d',regID,ii));
    end
    pirelab.getMuxComp(hN,data_outs,data_out_mux);


    pirelab.getDTCComp(hN,data_out_mux,data_out,'Floor','Wrap','SI');


    inputWordLength=inputBaseType.WordLength;
    packNumber=floor(inputWordLength/outputWordLength);
    if packNumber~=inputWordLength/outputWordLength
        error(message('hdlcommon:workflow:BitPackingUnsupported',sprintf('bitunpacking_%s',regID)));
    end


    for ii=1:inputDimLen
        slice_in=data_ins(ii);

        for jj=1:packNumber

            idx_out=(ii-1)*packNumber+jj;

            if idx_out<=outputDimLen
                slice_out=data_outs(idx_out);

                lsbPos=(jj-1)*outputWordLength;
                msbPos=jj*outputWordLength-1;

                pirelab.getBitSliceComp(hN,slice_in,slice_out,msbPos,lsbPos,sprintf('slice_%s',regID));
            end
        end
    end

end


