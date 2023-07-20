function satComp=getSaturateDynamicComp(hN,hInSignals,hOutSignals,rndMode,satMode,compName)



    if(nargin<6)
        compName='saturateDynamic';
    end

    if satMode==1
        satMode='on';
    elseif satMode==0
        satMode='off';
    end

    satComp=hN.addComponent2(...
    'kind','saturation_dynamic_comp',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'RoundingMode',rndMode,...
    'SaturationMode',satMode);

end


