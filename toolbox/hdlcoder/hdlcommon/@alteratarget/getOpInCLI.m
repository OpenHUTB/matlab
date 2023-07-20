function opInCLI=getOpInCLI(op)


    switch(op)
    case alteratarget.AddSub
        opInCLI='AddSub';
    case alteratarget.Mul
        opInCLI='Mul';
    case alteratarget.Div
        opInCLI='Div';
    case alteratarget.Convert
        opInCLI='Convert';
    case alteratarget.Relop
        opInCLI='Relop';
    case alteratarget.Abs
        opInCLI='Abs';
    case alteratarget.Sqrt
        opInCLI='Sqrt';
    case alteratarget.InvSqrt
        opInCLI='Rsqrt';
    case alteratarget.Recip
        opInCLI='Recip';
    case alteratarget.Exp
        opInCLI='Exp';
    case alteratarget.Log
        opInCLI='Log';
    case alteratarget.Sin
        opInCLI='Sin';
    case alteratarget.Cos
        opInCLI='Cos';
    case alteratarget.MultAdd
        opInCLI='MultAdd';
    otherwise
        assert(0);
    end

