function muxComp=getBusCreatorComp(hN,hInSignals,hOutSignal,busTypeStr,nonVirtualBus,compName)


    narginchk(6,6);
    muxComp=hN.addComponent2(...
    'kind','buscreator_comp',...
    'name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignal,...
    'OutDataTypeStr',busTypeStr,...
    'nonVirtualBus',nonVirtualBus);
end
