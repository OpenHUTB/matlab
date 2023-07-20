function newComp=getIncrementSI(hN,hInSignals,hOutSignals,compName)



    if(nargin<4)
        compName='incSI';
    end

    newComp=hN.addComponent2(...
    'kind','inc_si_comp',...
    'name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals);


end
