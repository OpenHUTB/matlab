function e=makeEnum(enumType,varargin)









    if enumType(1)=='$'
        switch enumType
        case '$rptgen_automanual'
            e=rptgen.enumAutoManual;
        case '$rptgen_table_halign'
            e=rptgen.enumTableHorizAlign;
        otherwise
            error(message('rptgen:rptgen:unrecognizedEnumType'));
        end
    else
        e=rptgen.enum(enumType,varargin{:});
    end

