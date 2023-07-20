function newComp=getIncrementSI(hN,hInSignals,hOutSignals,compName)



    if(nargin<4)
        compName='incSI';
    end

    newComp=pircore.getIncrementSI(hN,hInSignals,hOutSignals,compName);

end
