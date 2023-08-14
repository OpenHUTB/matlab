function absComp=getAbsComp(hN,hInSignals,hOutSignals,roundingMode,satMode,compName)



    if(nargin<6)
        compName='abs';
    end

    if(nargin<5)
        satMode='Wrap';
    end

    if(nargin<4)
        roundingMode='floor';
    end


    absComp=hN.addComponent2(...
    'kind','abs_comp',...
    'name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'RoundingMode',roundingMode,...
    'OverflowMode',satMode);

    absComp.setSupportAlteraMegaFunctions(true);

end
