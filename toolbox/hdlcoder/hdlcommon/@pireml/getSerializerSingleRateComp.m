function serializerComp=getSerializerSingleRateComp(hN,hInSignals,hOutSignals,compName)










    if(nargin<4)
        compName='serializer';
    end

    parallel_in=hInSignals(1);
    in_vld=hInSignals(2);
    serial_enb=hInSignals(3);

    serial_out=hOutSignals(1);


    dimLenIn=pirelab.getVectorTypeInfo(parallel_in);


    if dimLenIn==1
        serializerComp=pirelab.getWireComp(hN,parallel_in,serial_out);
    else

        scalarZero=pirelab.getTypeInfoAsFi(parallel_in.Type.BaseType);
        len=parallel_in.Type.Dimensions;
        initValue=repmat(scalarZero,len,1);

        serializerComp=hN.addComponent2(...
        'kind','cgireml',...
        'Name',compName,...
        'InputSignals',[parallel_in,in_vld,serial_enb],...
        'OutputSignals',serial_out,...
        'EmlParams',{initValue},...
        'EMLFileName','hdleml_serializer_singlerate',...
        'EMLFlag_RunLoopUnrolling',false);

        if targetmapping.isValidDataType(hOutSignals(1).Type)
            serializerComp.setSupportTargetCodGenWithoutMapping(true);
        end
    end


