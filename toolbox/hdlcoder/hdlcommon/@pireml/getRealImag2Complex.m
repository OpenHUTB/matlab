function ri2cComp=getRealImag2Complex(hN,hInSignals,hOutSignals,inputTypeMode,cval,compName)



    if(nargin<6)
        compName='reim2cplx';
    end

    if(nargin<5)
        cval=0;
    end

    if(nargin<4)
        inputTypeMode='Real and imag';
    end

    switch lower(inputTypeMode)
    case 'real and imag'
        mode=1;
    case 'real'
        mode=2;
    case 'imag'
        mode=3;
    otherwise
        mode=inputTypeMode;
    end

    cval=pirelab.getValueWithType(cval,hInSignals(1).Type);


    ri2cComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName','hdleml_reim2cplx',...
    'EMLParams',{mode,cval,cval},...
    'EMLFlag_ParamsFollowInputs',false,...
    'EMLFlag_RunLoopUnrolling',false);

end


