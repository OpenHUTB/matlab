function muxComp=getBusSelectorComp(hN,hInSignals,hOutSignal,indexStr,outputIsBus,compName)



    if nargin<6
        compName='bus_selector';
    end

    if nargin<5
        outputIsBus=false;
    end


    muxComp=hN.addComponent2(...
    'kind','busselector_comp',...
    'name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignal,...
    'IndexString',indexStr,...
    'OutputIsBus',outputIsBus);

end

