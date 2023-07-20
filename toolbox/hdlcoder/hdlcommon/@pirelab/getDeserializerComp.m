function deserializerComp=getDeserializerComp(hN,hInSignals,hOutSignals,compName)












    if(nargin<4)
        compName='deserializer';
    end

    deserializerComp=pireml.getDeserializerComp(hN,hInSignals,hOutSignals,compName);