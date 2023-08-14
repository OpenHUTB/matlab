function newComp=getIncrementRWV(hN,hInSignals,hOutSignals,compName)



    if(nargin<4)
        compName='incRWV';
    end

    newComp=pircore.getIncrementRWV(hN,hInSignals,hOutSignals,compName);

end
