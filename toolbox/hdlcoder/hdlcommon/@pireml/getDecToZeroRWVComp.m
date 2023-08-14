function c2riComp=getDecToZeroRWVComp(hN,hInSignals,hOutSignals,compName)



    if(nargin<4)
        compName='dec2zero';
    end

    c2riComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName','hdleml_dec2zero');

end


