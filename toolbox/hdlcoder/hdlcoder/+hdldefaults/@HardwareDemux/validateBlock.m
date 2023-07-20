function v=validateBlock(~,hC)



    v=hdlvalidatestruct;

    bfp=hC.SimulinkHandle;

    factor=get_param(bfp,'factor');
    hInSignals=hC.SLInputSignals;
    hOutSignal=hC.SLOutputSignals(1);

    [dimLen,~]=pirelab.getVectorTypeInfo(hInSignals(1));
    if dimLen~=1
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:VectorInputsNotSupported'));
    end

    [dimLen,~]=pirelab.getVectorTypeInfo(hInSignals(2));
    if dimLen~=1
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:VectorInputsNotSupported'));
    end

    [dimLen,~]=pirelab.getVectorTypeInfo(hOutSignal);






end


