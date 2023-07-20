
function hComp=getDynamicBitShiftComp(hN,hInSignals,hOutSignals,shift_mode,compName)




    if nargin<5
        compName='dynamic_shift';
    end

    switch lower(shift_mode)
    case 'left'
        mode=1;
    case 'right'
        mode=2;
    case 'bidi'
        mode=3;
    otherwise
        error(message('hdlcommon:hdlcommon:unsupportedshiftmode'));
    end

    hComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName','hdleml_dynamic_bitshift',...
    'EMLParams',{mode},...
    'EMLFlag_ParamsFollowInputs',false,...
    'EMLFlag_RunLoopUnrolling',false);
end

