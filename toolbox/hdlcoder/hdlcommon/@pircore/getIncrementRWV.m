function newComp=getIncrementRWV(hN,hInSignals,hOutSignals,compName)



    if(nargin<4)
        compName='incRWV';
    end

    newComp=hN.addComponent2(...
    'kind','inc_rwv_comp',...
    'name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals);


end
