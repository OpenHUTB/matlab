function newComp=getDecToZeroRWVComp(hN,hInSignals,hOutSignals,compName)



    if(nargin<4)
        compName='dec2zero';
    end

    newComp=pircore.getDecToZeroRWVComp(hN,hInSignals,hOutSignals,compName);

end


