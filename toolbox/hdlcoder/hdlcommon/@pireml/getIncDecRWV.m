function c2riComp=getIncDecRWV(hN,hInSignals,hOutSignals,mode,name)



    if(nargin<6)
        name='rwv';
    end

    if(nargin<5)
        mode=1;
    end

    if mode==1
        name=['inc_',name];
    else
        name=['dec_',name];
    end

    c2riComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',name,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName','hdleml_inc_dec_rwv',...
    'EMLParams',{mode});

end


