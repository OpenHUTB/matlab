function hOutSignal=getCompareToZero(hN,hSignal,opName,outSigName,compName)







    if nargin<5
        compName=sprintf('%s_cmpto_0',hSignal.Name);
    end

    if nargin<4
        outSigName=sprintf('%s_is_not0',hSignal.Name);
    end

    if nargin<3
        opName='==';
    end

    [dimlen,baseType]=pirelab.getVectorTypeInfo(hSignal);


    if baseType.is1BitType&&(strcmp(opName,'~=')||strcmp(opName,'>'))
        hOutSignal=hSignal;
    else
        if(dimlen>1)
            hOutType=pirelab.getPirVectorType(pir_boolean_t,dimlen);
        else
            hOutType=pir_boolean_t;
        end

        hOutSignal=hN.addSignal(hOutType,outSigName);
        hdtc=pireml.getCompareToValueComp(hN,hSignal,hOutSignal,opName,0,compName);
    end

