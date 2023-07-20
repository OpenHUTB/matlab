function[nlfunStruct,jacStruct,hessStruct]=compileHessianFunction(expr,varargin)
























































    nlfunStruct=optim.problemdef.OptimizationExpression.createNLfunStruct([varargin,{'reverseAD'},{true}]);


    jacStruct=optim.problemdef.OptimizationExpression.createNLfunStruct([varargin,{'HessianAD'},{true}]);


    hessStruct=optim.problemdef.OptimizationExpression.createNLfunStruct(varargin);













    [nlfunStruct,jacStruct,hessStruct]=compileHessianFunction(expr.OptimExprImpl,...
    nlfunStruct,jacStruct,hessStruct);



    nlfunStruct.fcnBody=strip(nlfunStruct.fcnBody,'right');
    jacStruct.fcnBody=strip(jacStruct.fcnBody,'right');
    hessStruct.fcnBody=strip(hessStruct.fcnBody,'right');

end