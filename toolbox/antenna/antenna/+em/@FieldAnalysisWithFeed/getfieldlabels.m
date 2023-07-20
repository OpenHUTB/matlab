function[quantitity,unit]=getfieldlabels(optype)

    if strcmpi(optype,'Directivity')
        quantitity='Directivity';
        unit='dBi';
    elseif strcmpi(optype,'Gain')
        quantitity='Gain';
        unit='dBi';
    elseif strcmpi(optype,'RealizedGain')
        quantitity='RealizedGain';
        unit='dBi';
    elseif strcmpi(optype,'efield')
        quantitity='E-field ';
        unit='V/m';
    elseif strcmpi(optype,'power')
        quantitity='Power ';
        unit='W';
    elseif strcmpi(optype,'powerdb')
        quantitity='Power ';
        unit='dB';
    elseif strcmpi(optype,'Array factor')
        quantitity='Array factor ';
        unit='dB';
    elseif strcmpi(optype,'phase')
        quantitity='Phase ';
        unit='deg';
    elseif strcmpi(optype,'rcs')
        quantitity='RCS';
        unit='dBsm';
    else
        quantitity='';
        unit='';
    end

end