function[nlfunStruct,jacStruct]=compileForwardAD(expr,varargin)





























































    [nlfunStruct,jacStruct]=compileForwardAD(expr.OptimExprImpl,varargin);



    nlfunStruct.fcnBody=strip(nlfunStruct.fcnBody,'right');
    jacStruct.fcnBody=strip(jacStruct.fcnBody,'right');

end