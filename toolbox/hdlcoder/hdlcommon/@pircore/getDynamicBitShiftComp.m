function hC=getDynamicBitShiftComp(hN,hInSignals,hOutSignals,shift_mode,compName)






    if(nargin<5)
        compName='dynamic_shift';
    end

    if(nargin<4)
        shift_mode='left';
    end


    if~any(strcmpi({'left','right'},shift_mode))
        error(message('hdlcoder:validate:unsupportedBitshiftMode',shift_mode));
    end

    hC=hN.addComponent2(...
    'kind','dynamic_shift_comp',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'ShiftMode',lower(shift_mode));

end
