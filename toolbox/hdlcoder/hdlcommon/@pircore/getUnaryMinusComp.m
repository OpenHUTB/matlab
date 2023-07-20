function unaryMinusComp=getUnaryMinusComp(hN,hInSignals,hOutSignals,satMode,compName)




    if(nargin<5)
        compName='uminus';
    end

    if(nargin<4)
        satMode='Wrap';
    end

    unaryMinusComp=hN.addComponent2(...
    'kind','uminus_comp',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'OverflowMode',satMode);

end
