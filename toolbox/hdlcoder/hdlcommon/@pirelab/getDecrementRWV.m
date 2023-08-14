function newComp=getDecrementRWV(hN,hInSignals,hOutSignals,compName)



    if(nargin<4)
        compName='decRWV';
    end

    newComp=pircore.getDecrementRWV(hN,hInSignals,hOutSignals,compName);

end
