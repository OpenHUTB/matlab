function cgirComp=getBitShiftComp(hN,hInSignals,hOutSignals,opName,shiftLength,shiftBinPtLength,compName)







    if(nargin<7)
        compName='shift';
    end

    if(nargin<6)
        shiftBinPtLength=0;
    end

    cgirComp=hN.addComponent2(...
    'kind','bitshift_comp',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'OpName',opName,...
    'ShiftLength',shiftLength,...
    'BinPtShiftLength',shiftBinPtLength);

end

