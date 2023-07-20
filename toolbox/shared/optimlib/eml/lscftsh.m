function[x,resnorm,fval,exitflag,output,lambda,jacob]=lscftsh(fun,x,xdata,ydata,lb,ub,options)












%#codegen
%#internal

    coder.columnMajor;
    coder.allowpcode('plain');
    coder.internal.prefer_const(fun,x,xdata,ydata,lb,ub,options);


    [x,resnorm,fval,exitflag,output,lambda,jacob]=lsqcurvefit(fun,x,xdata,ydata,lb,ub,options);