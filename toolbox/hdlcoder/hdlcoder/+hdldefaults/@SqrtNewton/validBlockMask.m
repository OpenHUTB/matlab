function v=validBlockMask(~,slbh)





    v=true;
    if slbh<0
        return;
    end
    blkFunction=get_param(slbh,'Function');
    invalidFunctionsMath={...
    'exp',...
    'log',...
    '10^u',...
    'log10',...
    'magnitude^2',...
    'square',...
    'pow',...
    'conj',...
    'reciprocal',...
    'hypot',...
    'rem',...
    'mod',...
    'transpose',...
    'hermitian',...
    };
    invalidFunctionsSqrt={...
    'rSqrt',...
    'signedSqrt',...
    };
    validFunctions={...
'sqrt'...
    };

    switch blkFunction
    case invalidFunctionsMath
        v=false;
    case invalidFunctionsSqrt
        v=false;
    end

