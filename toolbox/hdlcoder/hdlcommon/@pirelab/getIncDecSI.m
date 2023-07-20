function newComp=getIncDecSI(hN,hInSignals,hOutSignals,mode,name)



    if(nargin<6)
        name='inc_dec_si';
    end

    if(nargin<5)
        mode=1;
    end

    if(mode==1)
        newComp=pirelab.getIncrementSI(hN,hInSignals,hOutSignals,name);
    else
        newComp=pirelab.getDecrementSI(hN,hInSignals,hOutSignals,name);
    end

end


