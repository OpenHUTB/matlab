function cgirComp=getBitReduceComp(hN,hInSignals,hOutSignals,opName,compName)






    if(nargin<5)
        compName='reduce';
    end

    cgirComp=pircore.getBitReduceComp(hN,hInSignals,hOutSignals,opName,compName);

end