function serializerComp=getCascadeSerializer(this,hN,hInSignals,hOutSignals,name,enbSig)











    if(nargin<5)
        name='serializer';
    end

    ipf='hdleml_cascade_serializer';
    bmp={};


    dimLen=pirelab.getVectorTypeInfo(hInSignals(2));

    if dimLen==1
        error(message('hdlcoder:validate:SerializerInputDimension'));
    elseif dimLen==2

        serializerComp=pirelab.getDemuxComp(hN,hInSignals(2),hOutSignals);
    else
        serializerComp=this.getCgirCompForEml(hN,hInSignals,hOutSignals,name,ipf,bmp);
        serializerComp.runLoopUnrolling(false);
        serializerComp.setClockEnable(enbSig);
    end


