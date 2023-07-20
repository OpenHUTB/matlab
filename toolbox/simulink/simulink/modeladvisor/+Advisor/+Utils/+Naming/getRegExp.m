function regExpr=getRegExp(group)
    switch group
    case 'MAAB'
        regExpr='(^.{32,}$)|([^a-zA-Z_0-9])|(^\d)|(^ )|(__)|(^_)|(_$)';
    case 'JMAAB'
        regExpr='([^a-zA-Z_0-9])|(^\d)|(^ )|(__)|(^_)|(_$)|(\\)';
    otherwise
        regExpr='(^.{32,}$)|([^a-zA-Z_0-9])|(^\d)|(^ )|(__)|(^_)|(_$)';
    end
end
