function v=validatePortDatatypes(~,hC)














    v=hdlvalidatestruct;
    blockname='Prelookup';
    nfpMode=targetcodegen.targetCodeGenerationUtils.isNFPMode;


    numin=length(hC.PirInputPorts);
    for ii=1:numin
        hP=hC.PirInputPorts(ii);
        hT=hP.Signal.Type;
        if hT.getLeafType.isEnumType
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:PrelookupEnumport',hP.Name));
        else
            if~nfpMode&&hT.getLeafType.isFloatType
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:floatports',...
                hP.Name,blockname));%#ok<*AGROW>
            end
        end
    end


    numout=length(hC.PirOutputPorts);
    for ii=1:numout
        hP=hC.PirOutputPorts(ii);
        hT=hP.Signal.Type;
        if hT.getLeafType.isEnumType
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:PrelookupEnumport',hP.Name));
        else
            if~nfpMode&&hT.getLeafType.isFloatType
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:floatports',...
                hP.Name,blockname));
            end
        end
    end
end
