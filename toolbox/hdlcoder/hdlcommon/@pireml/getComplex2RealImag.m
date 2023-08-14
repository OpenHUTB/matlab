function c2riComp=getComplex2RealImag(hN,hInSignals,hOutSignals,opMode,compName)









    if(nargin<5)
        compName='cplx2reim';
    end

    if(nargin<4)

        opMode='Real and imag';
    end


    switch lower(opMode)
    case 'real and imag'
        opMode=1;
    case 'real'
        opMode=2;
    case 'imag'
        opMode=3;
    end


    c2riComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName','hdleml_cplx2reim',...
    'EMLParams',{opMode},...
    'EMLFlag_RunLoopUnrolling',false);

end


