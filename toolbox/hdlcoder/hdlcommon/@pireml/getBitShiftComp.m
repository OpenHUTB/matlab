function cgirComp=getBitShiftComp(hN,hInSignals,hOutSignals,opName,shiftLength,shiftBinPtLength,compName)







    if(nargin<7)
        compName='shift';
    end

    if(nargin<6)
        shiftBinPtLength=0;
    end

    switch lower(opName)
    case{'shift left logical','sll'}
        mode=1;
    case{'shift right logical','srl'}
        mode=2;
    case{'shift right arithmetic','sra'}
        mode=3;
    otherwise
        error(message('hdlcommon:hdlcommon:unsupportedshiftmode'));
    end


    if shiftBinPtLength~=0
        hShiftOut=hN.addSignal(hInSignals);
        hShiftOut.Name=sprintf('%s_bitshift',compName);

        pireml.getDTCComp(hN,hShiftOut,hOutSignals,'Floor','Wrap','SI',sprintf('%s_binptshift',compName));
    else
        hShiftOut=hOutSignals;
    end

    cgirComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hShiftOut,...
    'EMLFileName','hdleml_bitshift',...
    'EMLParams',{mode,shiftLength},...
    'EMLFlag_ParamsFollowInputs',false,...
    'EMLFlag_RunLoopUnrolling',false);
end

