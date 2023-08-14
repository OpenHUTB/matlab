function coeff_decomp=reshapeFilterCoeffInput(this,hN,coeffIn,FilterStructure,NoOfSubFilter)







    if NoOfSubFilter==1
        coeff_decomp=coeffIn;
    else
        FilterCoefficients=coeffIn.split.PirOutputSignals;

        numOfCoef=length(FilterCoefficients);
        zeroPadLen=NoOfSubFilter-mod(numOfCoef,NoOfSubFilter);
        if zeroPadLen==NoOfSubFilter
            coef_zeroPad=FilterCoefficients;
        else
            coef_zeroPad=FilterCoefficients(:);
            for ii=1:zeroPadLen
                ZEROCOEFF=hN.addSignal2('Type',FilterCoefficients(1).Type,'Name','ZEROPADD');
                ZEROCOEFF.SimulinkRate=coeffIn.SimulinkRate;
                pirelab.getConstComp(hN,ZEROCOEFF,0);
                coef_zeroPad=[coef_zeroPad(:);ZEROCOEFF];
            end
        end

        NumTaps=length(coef_zeroPad)/NoOfSubFilter;
        coef_reshape=reshape(coef_zeroPad,NoOfSubFilter,NumTaps);
        coeffIn_reshape=flipud(coef_reshape);









        if NumTaps==1
            coeff_decomp=transpose(coeffIn_reshape);
        else
            hAF=hdlcoder.tpc_arr_factory;
            hAF.addDimension(NumTaps);
            hAF.addBaseType(FilterCoefficients(1).Type)





            hAF.VectorOrientation='column';
            dType_array=hdlcoder.tp_array(hAF);
            for ii=1:NoOfSubFilter
                coeff_decomp(ii)=hN.addSignal2('Type',dType_array,'Name','coef_decomp');%#ok<*AGROW>
                coeff_decomp(ii).SimulinkRate=coeffIn.SimulinkRate;
                pirelab.getMuxComp(hN,coeffIn_reshape(ii,:),coeff_decomp(ii));
            end
        end
    end
end
