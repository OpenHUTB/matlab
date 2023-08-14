function[x,fval,exitflag,output,jacob]=fsolve(fun,x,options)




























%#codegen

    eml_allow_mx_inputs;
    coder.columnMajor;
    coder.allowpcode('plain');
    coder.internal.prefer_const(fun,x,options)

    nInputs=nargin();


    coder.internal.errorIf(nInputs==1&&isstruct(fun),'optimlib_codegen:common:NoProbStructSupport');

    coder.internal.assert(nInputs==3,'optimlib_codegen:common:TooFewInputs','FSOLVE',3,'Levenberg-Marquardt');

    optim.coder.validate.checkProducts();


    coder.internal.assert(isa(fun,'function_handle'),'optimlib_codegen:common:InvalidObjectiveType');


    optim.coder.validate.checkX0(x);


    coder.internal.assert(isa(options,'struct'),...
    'optimlib_codegen:common:OnlyOptimoptionsSupported');

    coder.internal.assert(isfield(options,'SolverName'),...
    'optimlib_codegen:common:OnlyOptimoptionsSupported');
    coder.internal.assert(strcmp(options.SolverName,'fsolve'),...
    'optimlib_codegen:optimoptions:InvalidSolverOptions','fsolve');

    coder.internal.assert(strcmpi(options.Algorithm,'levenberg-marquardt'),...
    'optimlib_codegen:optimoptions:InvalidType','Algorithm','fsolve',[char(13),'''levenberg-marquardt''']);

    coder.internal.assert(strcmpi(options.FiniteDifferenceType,'forward')||strcmpi(options.FiniteDifferenceType,'central'),...
    'optimlib_codegen:optimoptions:InvalidType','FiniteDifferenceType','fsolve',[char(13),'''forward'', ''central''']);

    coder.internal.errorIf(options.SpecifyObjectiveGradient&&abs(nargout(fun))~=2&&nargout(fun)~=-1,...
    'optimlib_codegen:common:IncorrectOutputsObjective');



    lb=zeros(0,1);
    ub=zeros(0,1);

    [x,resnorm,fval,exitflag,output,~,jacob]=...
    optim.coder.levenbergMarquardt.driver(fun,x,lb,ub,options);

    if exitflag>0&&resnorm>sqrt(options.FunctionTolerance)
        exitflag=double(optim.coder.SolutionState('Infeasible'));
    end

end