function v=validatePortDatatypes(~,hC)














    v=hdlvalidatestruct;
    numin=length(hC.SLInputPorts);
    blockname='Direct Lookup Table (n-D)';

    for ii=1:numin
        hP=hC.PirInputPorts(ii);
        hT=hP.Signal.Type;
        if hT.isFloatType
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:floatports',...
            hP.Name,blockname));%#ok<*AGROW>
        end
    end


    numout=length(hC.PirOutputPorts);
    for ii=1:numout
        hP=hC.PirOutputPorts(ii);
        hT=hP.Signal.Type;
        if hT.getLeafType.isEnumType
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:DirectLookupEnumport',hP.Name));
        end
    end
end
