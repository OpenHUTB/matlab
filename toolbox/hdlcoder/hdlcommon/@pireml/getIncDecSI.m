function c2riComp=getIncDecSI(hN,hInSignals,hOutSignals,mode,name)



    if(nargin<5)
        name='inc_dec_si';
    end

    if(nargin<4)
        mode=1;
    end

    c2riComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',name,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName','hdleml_inc_dec_si',...
    'EMLParams',{mode});

end


