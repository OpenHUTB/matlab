function[exitflag,iter]=checkStoppingCriteria(...
    options,gradf,relFactor,funDiff,x,dx,lb,ub,funcCount,stepSuccessful,iter,projSteepestDescentInfNorm,hasFiniteBounds)

%#codegen

    coder.allowpcode('plain');
    coder.internal.prefer_const(options,gradf,funDiff,dx,funcCount,stepSuccessful,hasFiniteBounds);

    validateattributes(options,{'struct'},{'scalar'});
    validateattributes(gradf,{'double'},{'column'});
    validateattributes(relFactor,{'double'},{'scalar'});
    validateattributes(funDiff,{'double'},{'scalar'});


    validateattributes(lb,{'double'},{'column'});
    validateattributes(ub,{'double'},{'column'});
    validateattributes(funcCount,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(stepSuccessful,{'logical'},{'scalar'});
    validateattributes(iter,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(projSteepestDescentInfNorm,{'double'},{'scalar'});
    validateattributes(hasFiniteBounds,{'logical'},{'scalar'});

    normGradF=norm(gradf,'inf');
    if hasFiniteBounds&&projSteepestDescentInfNorm^2...
        <=1e-4*options.FunctionTolerance*normGradF*relFactor

        exitflag=coder.const(optim.coder.SolutionState('Optimal'));
    elseif~hasFiniteBounds&&normGradF<=1e-4*options.FunctionTolerance*relFactor

        exitflag=coder.const(optim.coder.SolutionState('Optimal'));
    elseif funcCount>=options.MaxFunctionEvaluations

        exitflag=coder.const(optim.coder.SolutionState('MaxIterReached'));
    elseif iter>=options.MaxIterations

        exitflag=coder.const(optim.coder.SolutionState('MaxIterReached'));
    elseif norm(dx(:))<options.StepTolerance*(sqrt(eps)+norm(x(:)))

        exitflag=coder.const(optim.coder.SolutionState('IllPosed'));
        if~stepSuccessful



            iter=iter+1;
            if strcmpi(options.Display,'testing')
                fprintf(' %5d       %5d                                                %12.6g\n',...
                iter,funcCount,norm(dx(:)));
            end
        end
    elseif funDiff<=options.FunctionTolerance

        exitflag=coder.const(optim.coder.SolutionState('Unbounded'));
    else

        exitflag=coder.const(optim.coder.SolutionState('StartContinue'));
    end

end