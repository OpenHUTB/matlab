function newComp=getDecrementSI(hN,hInSignals,hOutSignals,compName)



    if(nargin<4)
        compName='decSI';
    end

    newComp=hN.addComponent2(...
    'kind','dec_si_comp',...
    'name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals);


end
