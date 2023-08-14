function[x,resnorm,fval,exitflag,output,lambda,jacob]=lsscfsh(fun,x,lb,ub,options)












%#codegen
%#internal

    coder.columnMajor;
    coder.allowpcode('plain');
    coder.internal.prefer_const(fun,x,lb,ub,options);


    [x,resnorm,fval,exitflag,output,lambda,jacob]=lsqnonlin(fun,x,lb,ub,options);