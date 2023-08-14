function satComp=getSaturateComp(hN,hInSignals,hOutSignals,lowerLimit,upperLimit,rndMeth,name)



    if(nargin<7)
        name='saturate';
    end

    if(nargin<6)
        rndMeth='Floor';
    end

    satComp=hN.addComponent2(...
    'kind','saturation_comp',...
    'Name',name,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'LowerLimit',lowerLimit,...
    'UpperLimit',upperLimit,...
    'RoundingMode',rndMeth);

    doCompRoughSemanticsMaps(satComp,lowerLimit,upperLimit);
end

function doCompRoughSemanticsMaps(hNewC,lowerLimit,upperLimit)

    valid=all(lowerLimit<=upperLimit);
    if(~valid)
        return;
    end



    l=all(lowerLimit<=0);
    u=all(upperLimit>=0);

    if(l&&u)
        hNewC.setRetimingSafety(1);
    else
        hNewC.setRetimingSafety(0);
    end
end
