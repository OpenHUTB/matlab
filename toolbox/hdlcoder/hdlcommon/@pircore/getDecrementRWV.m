function newComp=getDecrementRWV(hN,hInSignals,hOutSignals,compName)



    if(nargin<4)
        compName='decRWV';
    end

    newComp=hN.addComponent2(...
    'kind','dec_rwv_comp',...
    'name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals);


end
