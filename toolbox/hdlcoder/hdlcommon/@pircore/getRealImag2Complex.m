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



    ri2cComp=hN.addComponent2(...
    'kind','ri2c_comp',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'Mode',mode,...
    'ConstantVal',cval);

end


