function hcComp=getHitCrossComp(hN,hInSignals,hOutSignals,hcOffset,hcDirectionMode,name)



    if(nargin<6)
        name='hitcross';
    end

    hcComp=pircore.getHitCrossComp(hN,hInSignals,hOutSignals,hcOffset,hcDirectionMode,name);
end
