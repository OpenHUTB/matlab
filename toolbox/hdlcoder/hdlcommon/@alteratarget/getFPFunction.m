function fpFunction=getFPFunction(op,mnemonic)


    switch(op)
    case alteratarget.AddSub
        assert(nargin>1);
        if(strcmpi(mnemonic,'add'))
            fpFunction='ADD';
        else
            assert(strcmpi(mnemonic,'sub'));
            fpFunction='SUB';
        end
    case alteratarget.Mul
        fpFunction='MUL';
    case alteratarget.Div
        fpFunction='DIV';
    case alteratarget.Convert
        if(strcmpi(mnemonic,'fixed_to_floating'))
            fpFunction='FXP_FP';
        else
            assert(strcmpi(mnemonic,'floating_to_fixed'));
            fpFunction='FP_FXP';
        end
    case alteratarget.Relop
        switch(lower(mnemonic))
        case 'lt'
            fpFunction='LT';
        case 'le'
            fpFunction='LE';
        case 'eq'
            fpFunction='EQ';
        case 'neq'
            fpFunction='NEQ';
        case 'gt'
            fpFunction='GT';
        case 'ge'
            fpFunction='GE';
        otherwise
            assert(0);
        end
    case alteratarget.Sqrt
        fpFunction='SQRT';
    case alteratarget.InvSqrt
        fpFunction='INV_SQRT';
    case alteratarget.Abs
        fpFunction='ABS';
    case alteratarget.Recip
        fpFunction='INV';
    case alteratarget.Exp
        fpFunction='EXPE';
    case alteratarget.Log
        fpFunction='LOGE';
    case alteratarget.Sin
        fpFunction='SIN';
    case alteratarget.Cos
        fpFunction='COS';
    case alteratarget.MultAdd
        fpFunction='MULT_ADD';
    otherwise
        assert(0);
    end

