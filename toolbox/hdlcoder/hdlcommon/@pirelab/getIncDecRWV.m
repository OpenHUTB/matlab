function newComp=getIncDecRWV(hN,hInSignals,hOutSignals,mode,name)



    if(nargin<6)
        name='rwv';
    end

    if(nargin<5)
        mode=1;
    end

    if mode==1
        name=['inc_',name];
    else
        name=['dec_',name];
    end

    if(mode==1)
        newComp=pirelab.getIncrementRWV(hN,hInSignals,hOutSignals,name);
    else
        newComp=pirelab.getDecrementRWV(hN,hInSignals,hOutSignals,name);
    end

end


