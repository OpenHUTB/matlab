function dzComp=getDeadZoneDynamicComp(hN,hInSignals,hOutSignals,compName)



    if(nargin<4)
        compName='deadzoneDynamic';
    end

    dzComp=hN.addComponent2(...
    'kind','deadzone_dynamic_comp',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals);

end


