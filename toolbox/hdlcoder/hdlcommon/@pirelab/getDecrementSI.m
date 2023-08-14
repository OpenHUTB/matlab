function newComp=getDecrementSI(hN,hInSignals,hOutSignals,compName)



    if(nargin<4)
        compName='decSI';
    end

    newComp=pircore.getDecrementSI(hN,hInSignals,hOutSignals,compName);

end
