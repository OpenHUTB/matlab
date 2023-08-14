function cgirComp=getBitRotateComp(hN,hInSignals,hOutSignals,opName,rotateLength,compName)






    if(nargin<6)
        compName='rotate';
    end

    cgirComp=pircore.getBitRotateComp(hN,hInSignals,hOutSignals,opName,rotateLength,compName);

end


