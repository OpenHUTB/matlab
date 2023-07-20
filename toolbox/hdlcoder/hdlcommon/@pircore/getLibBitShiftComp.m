function cgirComp=getLibBitShiftComp(hN,hInSignals,hOutSignals,opName,shiftLength,compName)








    if(nargin<6)
        compName='bitopShift';
    end

    cgirComp=hN.addComponent2(...
    'kind','bitshiftlib_comp',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'OpName',opName,...
    'ShiftLength',shiftLength);

end

