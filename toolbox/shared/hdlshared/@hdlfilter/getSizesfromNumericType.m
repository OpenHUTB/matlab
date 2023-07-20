function[size,bp,sign]=getSizesfromNumericType(ntype)





    switch ntype.DataTypeMode
    case 'Double'
        size=0;
        bp=0;
        sign=1;
    case{'Fixed-point: binary point scaling','Fixed-point: unspecified scaling'}
        size=ntype.WordLength;
        bp=ntype.FractionLength;
        switch ntype.Signedness
        case 'Unsigned'
            sign=0;
        case 'Signed'
            sign=1;
        case 'Auto'
            sign=1;
        otherwise
            error(message('HDLShared:hdlfilter:wrongsignedness'));
        end
    otherwise
        error(message('HDLShared:hdlfilter:wrongfpmode'));
    end



