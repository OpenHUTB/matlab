function[x,resnorm,residual,exitflag,output,lambda,jacobian]=lsqcurvefit(fun,x0,xdata,ydata,lb,ub,options)



































%#codegen

    eml_allow_mx_inputs;
    coder.columnMajor;
    coder.allowpcode('plain');
    coder.internal.prefer_const(fun,x0,xdata,ydata,lb,ub,options)

    nInputs=nargin();


    coder.internal.errorIf(nInputs==1&&isstruct(fun),'optimlib_codegen:common:NoProbStructSupport');

    coder.internal.assert(nInputs==7,'optimlib_codegen:common:TooFewInputs','LSQCURVEFIT',7,'Levenberg-Marquardt');

    optim.coder.validate.checkProducts()


    coder.internal.assert(isa(fun,'function_handle'),'optimlib_codegen:common:InvalidObjectiveType');


    optim.coder.validate.checkX0(x0);


    coder.internal.assert(isa(xdata,'double'),'optimlib_codegen:common:MustBeDoubleType','xdata');


    coder.internal.assert(isreal(xdata),'optimlib_codegen:common:MustBeRealValued','xdata');
    coder.internal.errorIf(issparse(xdata),'optimlib_codegen:common:InvalidSparse','xdata');
    coder.internal.assert(all(isfinite(xdata),'all'),'optimlib_codegen:common:InfNaNComplexDetected','xdata');


    coder.internal.assert(isa(ydata,'double'),'optimlib_codegen:common:MustBeDoubleType','ydata');


    coder.internal.assert(isreal(ydata),'optimlib_codegen:common:MustBeRealValued','ydata');
    coder.internal.errorIf(issparse(ydata),'optimlib_codegen:common:InvalidSparse','ydata');
    coder.internal.assert(all(isfinite(ydata),'all'),'optimlib_codegen:common:InfNaNComplexDetected','ydata');


    coder.internal.assert(numel(xdata)==numel(ydata),'optimlib_codegen:lsqcurvefit:DataSizeMismatch');


    optim.coder.validate.checkBounds(numel(x0),lb,ub);


    coder.internal.assert(isa(options,'struct'),'optimlib_codegen:common:OnlyOptimoptionsSupported');

    coder.internal.assert(isfield(options,'SolverName'),...
    'optimlib_codegen:common:OnlyOptimoptionsSupported');
    coder.internal.assert(strcmp(options.SolverName,'lsqcurvefit'),...
    'optimlib_codegen:optimoptions:InvalidSolverOptions','lsqcurvefit');

    coder.internal.assert(strcmpi(options.Algorithm,'levenberg-marquardt'),...
    'optimlib_codegen:optimoptions:InvalidType','Algorithm','lsqcurvefit',[char(13),'''levenberg-marquardt''']);

    coder.internal.assert(strcmpi(options.FiniteDifferenceType,'forward')||strcmpi(options.FiniteDifferenceType,'central'),...
    'optimlib_codegen:optimoptions:InvalidType','FiniteDifferenceType','lsqcurvefit',[char(13),'''forward'', ''central''']);

    coder.internal.errorIf(options.SpecifyObjectiveGradient&&abs(nargout(fun))~=2&&nargout(fun)~=-1,...
    'optimlib_codegen:common:IncorrectOutputsObjective');

    [x,resnorm,residual,exitflag,output,lambda,jacobian]=...
    optim.coder.levenbergMarquardt.driver(@(x)wrapper(x,fun,xdata,ydata,options),x0(:),lb(:),ub(:),options);

end

function[varargout]=wrapper(x,fun,xdata,ydata,options)
    m=numel(xdata);
    n=numel(x);
    if nargout(fun)==1
        F_temp=fun(x,xdata);
        J=0;
    else
        if options.SpecifyObjectiveGradient
            [F_temp,J_temp]=fun(x,xdata);
            J=coder.nullcopy(zeros(m,n));
            J=J_temp;
        else
            F_temp=fun(x,xdata);
            J=0;
        end
    end
    F=coder.nullcopy(zeros(m,1));
    F=F_temp;
    varargout={F-ydata,J};
end

