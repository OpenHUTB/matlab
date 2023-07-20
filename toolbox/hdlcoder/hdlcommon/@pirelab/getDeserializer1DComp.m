function Deserializer1DComp=getDeserializer1DComp(hN,hInSignals,hOutSignals,ratio,idleCycles,initialCondition,startInPort,validInPort,validOutPort,compName)













    if(nargin<9)
        compName='Deserializer1D';
    end

    Deserializer1DComp=pircore.getDeserializer1DComp(hN,hInSignals,hOutSignals,ratio,idleCycles,initialCondition,startInPort,validInPort,validOutPort,compName);