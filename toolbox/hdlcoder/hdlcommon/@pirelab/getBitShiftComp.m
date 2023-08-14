function cgirComp=getBitShiftComp(hN,hInSignals,hOutSignals,opName,shiftLength,shiftBinPtLength,compName)






    if(nargin<7)
        compName='shift';
    end

    if(nargin<6)
        shiftBinPtLength=0;
    end

    if strcmpi(opName,'srl')
        assert(shiftBinPtLength==0,'Shift Right logical cannot support binary point shifting');
        cgirComp=pircore.getLibBitShiftComp(hN,hInSignals,hOutSignals,'shift right logical',shiftLength,compName);
    else
        cgirComp=pircore.getBitShiftComp(hN,hInSignals,hOutSignals,opName,shiftLength,shiftBinPtLength,compName);
    end

end

