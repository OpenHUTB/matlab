function detectChangeComp=getDetectChangeComp(hN,hInSignals,hOutSignals,ic,outType,compName)


    if(nargin<6)
        compName='dc';
    end

    if(nargin<5)
        ic=0;
    end

    if strcmp(outType,'boolean')
        ot=1;
    else
        ot=2;
    end

    ipf='hdleml_detect_change';
    bmp={ic,ot};

    detectChangeComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName',ipf,...
    'EMLParams',bmp);

end