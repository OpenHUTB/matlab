function checkFrequency(frequency)


    fmin=1e3;
    [fmin_eng,~,fmin_str]=engunits(fmin);
    fmax=200e9;
    [fmax_eng,~,fmax_str]=engunits(fmax);
    if any(frequency<=fmin)
        error(message('antenna:antennaerrors:InvalidValueGreater',...
        'frequency',[num2str(fmin_eng),' ',fmin_str,'Hz']));
    elseif any(frequency>fmax)
        error(message('antenna:antennaerrors:InvalidValueLess',...
        'frequency',[num2str(fmax_eng),' ',fmax_str,'Hz']));
    end