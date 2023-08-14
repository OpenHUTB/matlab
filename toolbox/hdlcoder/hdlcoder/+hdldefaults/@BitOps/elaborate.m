function hNewC=elaborate(~,hN,hC)




    slbh=hC.SimulinkHandle;
    paramMask=get_param(slbh,'MaskWSVariables');
    op=paramMask(arrayfun(@(x)strcmp(x.Name,'logicop'),paramMask)).Value;
    bitMask=paramMask(arrayfun(@(x)strcmp(x.Name,'BitMask'),paramMask)).Value;
    useBitMask=paramMask(arrayfun(@(x)strcmp(x.Name,'UseBitMask'),paramMask)).Value;
    bitMaskType=paramMask(arrayfun(@(x)strcmp(x.Name,'BitMaskRealWorld'),paramMask)).Value;

    hOutSignals=hC.PirOutputSignals(1);
    if useBitMask
        [~,outType]=pirelab.getVectorTypeInfo(hOutSignals(1));
        if bitMaskType==2&&outType.isWordType
            sign=outType.Signed;
            wordlen=outType.WordLength;
            flen=outType.FractionLength;


            bitMask=fi(bitMask,sign,wordlen,0,hdlfimath);

            bitMask=reinterpretcast(bitMask,numerictype(sign,wordlen,-flen));
        end
        bitMask=pirelab.getTypeInfoAsFi(hOutSignals(1).Type,'Floor','Wrap',bitMask,false);
    end

    if~isnumeric(bitMask)
        assert(ischar(bitMask));
        maskVal=hdlslResolve(bitMask,slbh);
    else
        maskVal=bitMask;
    end
    isBitMaskZero=isequal(zeros(size(maskVal)),maskVal);

    hNewC=pirelab.getBitwiseOpComp(hN,hC.PirInputSignals,hOutSignals,op,...
    hC.Name,useBitMask,bitMask,isBitMaskZero);
end
