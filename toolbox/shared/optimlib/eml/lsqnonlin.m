function[xCurrent,resnorm,fval,exitflag,output,lambda,jacob]=lsqnonlin(fun,xCurrent,lb,ub,options)































%#codegen

    eml_allow_mx_inputs;
    coder.columnMajor;
    coder.allowpcode('plain');
    coder.internal.prefer_const(fun,xCurrent,lb,ub,options);

    nInputs=nargin();


    coder.internal.errorIf(nInputs==1&&isstruct(fun),'optimlib_codegen:common:NoProbStructSupport');

    coder.internal.assert(nInputs==5,'optimlib_codegen:common:TooFewInputs','LSQNONLIN',5,'Levenberg-Marquardt');

    optim.coder.validate.checkProducts();


    coder.internal.assert(isa(fun,'function_handle'),'optimlib_codegen:common:InvalidObjectiveType');


    optim.coder.validate.checkX0(xCurrent);


    optim.coder.validate.checkBounds(numel(xCurrent),lb,ub);


    coder.internal.assert(isa(options,'struct'),'optimlib_codegen:common:OnlyOptimoptionsSupported');

    coder.internal.assert(isfield(options,'SolverName'),...
    'optimlib_codegen:common:OnlyOptimoptionsSupported');
    coder.internal.assert(strcmp(options.SolverName,'lsqnonlin'),...
    'optimlib_codegen:optimoptions:InvalidSolverOptions','lsqnonlin');

    coder.internal.assert(strcmpi(options.Algorithm,'levenberg-marquardt'),...
    'optimlib_codegen:optimoptions:InvalidType','Algorithm','lsqnonlin',[char(13),'''levenberg-marquardt''']);

    coder.internal.assert(strcmpi(options.FiniteDifferenceType,'forward')||strcmpi(options.FiniteDifferenceType,'central'),...
    'optimlib_codegen:optimoptions:InvalidType','FiniteDifferenceType','lsqnonlin',[char(13),'''forward'', ''central''']);

    coder.internal.errorIf(options.SpecifyObjectiveGradient&&abs(nargout(fun))~=2&&nargout(fun)~=-1,...
    'optimlib_codegen:common:IncorrectOutputsObjective');

    [xCurrent,resnorm,fval,exitflag,output,lambda,jacob]=...
    optim.coder.levenbergMarquardt.driver(fun,xCurrent,reshape(lb,[],1),reshape(ub,[],1),options);

end