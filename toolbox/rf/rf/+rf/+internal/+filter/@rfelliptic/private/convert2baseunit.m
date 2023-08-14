function Outval=convert2baseunit(Inval,Unit)





    first_letter_of_unit=Unit(1);
    switch first_letter_of_unit
    case 'k'
        Outval=1e3*Inval;
    case 'M'
        Outval=1e6*Inval;
    case 'G'
        Outval=1e9*Inval;
    case 'T'
        Outval=1e12*Inval;
    case 'm'
        Outval=1e-3*Inval;
    case 'u'
        Outval=1e-6*Inval;
    case 'n'
        Outval=1e-9*Inval;
    case 'p'
        Outval=1e-12*Inval;
    otherwise
        if strcmpi(Unit,'dBm')
            Outval=0.001*10.^(Inval/10);
        elseif strcmpi(Unit,'dBW')
            Outval=10.^(Inval/10);
        else
            Outval=Inval;
        end
    end

end