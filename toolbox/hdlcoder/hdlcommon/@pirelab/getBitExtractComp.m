function cgirComp=getBitExtractComp(hN,hInSignals,hOutSignals,ul,ll,mode,compName)








    if(nargin<7)
        compName='extract';
    end

    cgirComp=pircore.getBitExtractComp(hN,hInSignals,hOutSignals,ul,ll,mode,compName);

end


