function[x,fval,exitflag,output,lambda]=callSolver(prob,probStruct)










    optim.internal.problemdef.display.printDerivativeMessageIfUserRequested(prob,probStruct);



    if isfield(probStruct,'globalSolver')&&~isempty(probStruct.globalSolver)
        validateSolverForMultiplePoint(prob,probStruct.globalSolver,probStruct.solver);
        [x,fval,exitflag,output,lambda]=callGlobalSolver(prob,probStruct);
        return
    end


    switch probStruct.solver
    case 'linprog'
        [x,fval,exitflag,output,lambda]=linprog(probStruct);
    case 'intlinprog'
        [x,fval,exitflag,output]=intlinprog(probStruct);
        lambda=[];
    case 'quadprog'
        probStruct=iSymmetrizeHessian(probStruct);
        [x,fval,exitflag,output,lambda]=quadprog(probStruct);
    case 'lsqlin'
        [x,fval,~,exitflag,output,lambda]=lsqlin(probStruct);



        fval=0.5*fval;
    case 'lsqnonneg'
        [x,fval,~,exitflag,output,lambda0]=lsqnonneg(probStruct);



        fval=0.5*fval;

        numVars=numel(x);
        lambda.upper=zeros(numVars,1);
        lambda.lower=-lambda0;
    case 'fmincon'
        iValidateX0ForNLP(probStruct)
        probStruct=iValidateOptionsForFmincon(probStruct);
        [x,fval,exitflag,output,lambda]=fmincon(probStruct);

        output.objectivederivative=probStruct.objectiveDerivative;
        output.constraintderivative=probStruct.constraintDerivative;
    case 'fminunc'
        iValidateX0ForNLP(probStruct)
        iValidateOptionsForFminunc(probStruct);
        [x,fval,exitflag,output]=fminunc(probStruct);
        lambda=[];

        output.objectivederivative=probStruct.objectiveDerivative;
    case 'lsqnonlin'
        iValidateX0ForNLP(probStruct)
        probStruct=iValidateOptionsForLsqnonlin(probStruct);
        [x,fval,~,exitflag,output,lambda]=lsqnonlin(probStruct);

        output.objectivederivative=probStruct.objectiveDerivative;
    case 'coneprog'
        [x,fval,exitflag,output,lambda]=coneprog(probStruct);
    case 'ga'
        [x,fval,exitflag,output]=ga(probStruct);
        lambda=[];
    case 'gamultiobj'
        [x,fval,exitflag,output,~,~,residuals]=gamultiobj(probStruct);
        output.probdefResiduals=residuals;
        lambda=[];
    case 'paretosearch'
        [x,fval,exitflag,output,residuals]=paretosearch(probStruct);
        output.probdefResiduals=residuals;
        lambda=[];
    case 'particleswarm'
        [x,fval,exitflag,output]=particleswarm(probStruct);
        lambda=[];
    case 'patternsearch'
        iValidateX0ForNLP(probStruct);
        [x,fval,exitflag,output]=patternsearch(probStruct);
        lambda=[];
    case 'simulannealbnd'
        iValidateX0ForNLP(probStruct);
        [x,fval,exitflag,output]=simulannealbnd(probStruct);
        lambda=[];
    case 'surrogateopt'
        probStruct=iValidateOptionsForSurrogateopt(probStruct);
        [x,fval,exitflag,output]=surrogateopt(probStruct);
        lambda=[];
    end


    fval=fval+probStruct.f0;

end

function probStruct=iSymmetrizeHessian(probStruct)



    H=probStruct.H;
    options=probStruct.options;
    if~issymmetric(H)

        if optim.internal.problemdef.display.allowsDisplay(options)
            disp(getString(message('optim:quadprog:HessianNotSym')));
        end
        H=(H+H')./2;
        probStruct.H=H;
    end

end

function iValidateX0ForNLP(probStruct)



    if isempty(probStruct.x0)
        error('optim_problemdef:OptimizationProblem:solve:MustSpecifyX0ForNLP',...
        getString(message('optim_problemdef:ProblemImpl:solve:MustSpecifyX0ForNLP')));
    end
end

function iValidateOptionsForFminunc(probStruct)

    opts=probStruct.options;



    hasAlgorithm=(isstruct(opts)&&isfield(opts,'Algorithm'))||isa(opts,'optim.options.Fminunc');
    if hasAlgorithm&&strcmp(opts.Algorithm,'trust-region')
        error(message('optim_problemdef:OptimizationProblem:solve:FminuncNoTrustRegion'));
    end

end

function probStruct=iValidateOptionsForFmincon(probStruct)

    opts=probStruct.options;


    hasAlgorithm=(isstruct(opts)&&isfield(opts,'Algorithm'))||isa(opts,'optim.options.Fmincon');
    if hasAlgorithm
        if any(strcmp(opts.Algorithm,{'sqp','sqp-legacy','active-set'}))


            probStruct.Aeq=full(probStruct.Aeq);
            probStruct.Aineq=full(probStruct.Aineq);
        elseif strcmp(opts.Algorithm,'trust-region-reflective')



            error(message('optim_problemdef:OptimizationProblem:solve:FminconNoTrustRegionReflective'));
        end
    end


    hasHessianFcn=(isstruct(opts)&&isfield(opts,'HessFcn'))||isa(opts,'optim.options.Fmincon');
    linkToDoc=addLink('Including Hessians','optim','ip_hessian',false);
    if hasHessianFcn&&~isempty(opts.HessFcn)
        error(message('optim_problemdef:OptimizationProblem:solve:FminconNoHessianOptions','HessianFcn',linkToDoc));
    end


    hasHessianMultiplyFcn=(isstruct(opts)&&isfield(opts,'HessMult'))||isa(opts,'optim.options.Fmincon');
    if hasHessianMultiplyFcn&&~isempty(opts.HessMult)
        error(message('optim_problemdef:OptimizationProblem:solve:FminconNoHessianOptions','HessianMultiplyFcn',linkToDoc));
    end

end

function probStruct=iValidateOptionsForLsqnonlin(probStruct)

    optim.internal.problemdef.ProblemImpl.checkForJacobianMultiplyFcn(...
    probStruct,'lsqnonlin','lsq_jacobian_example',"OptimizationProblem");

end

function probStruct=iValidateOptionsForSurrogateopt(probStruct)

    opts=probStruct.options;
    hasCheckpointFileOption=isa(opts,'optim.options.Surrogateopt')||...
    (isstruct(opts)&&isfield(opts,'CheckpointFile'));
    if hasCheckpointFileOption&&~isempty(opts.CheckpointFile)
        error(message('optim_problemdef:OptimizationProblem:solve:SurrogateoptNoCheckpointFile'));
    end

end


