function matlabNamedOp=opConversionMtreeToMATLAB(mtreeNamedOp)







    switch mtreeNamedOp
    case 'PLUS'
        matlabNamedOp='plus';
    case 'MINUS'
        matlabNamedOp='minus';
    case 'DOTMUL'
        matlabNamedOp='times';
    case 'DOTDIV'
        matlabNamedOp='rdivide';
    case 'DOTLDIV'
        matlabNamedOp='ldivide';
    case 'MUL'
        matlabNamedOp='mtimes';
    case 'DIV'
        matlabNamedOp='mrdivide';
    case 'LDIV'
        matlabNamedOp='mldivide';
    case 'UMINUS'
        matlabNamedOp='uminus';
    case 'UPLUS'
        matlabNamedOp='uplus';
    case 'OROR'
        matlabNamedOp='||';
    case 'NOT'
        matlabNamedOp='~';
    otherwise
        assert(false,'illegal operation ''%s''.',mtreeNamedOp);
    end




