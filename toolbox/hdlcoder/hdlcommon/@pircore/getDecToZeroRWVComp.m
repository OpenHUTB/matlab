function newComp=getDecToZeroRWVComp(hN,hInSignals,hOutSignals,compName)



    if(nargin<4)
        compName='dec2zero';
    end

    newComp=hN.addComponent2(...
    'kind','dec_zero_comp',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals);

end


