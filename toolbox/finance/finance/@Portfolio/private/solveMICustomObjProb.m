function[pwgt,exitflag]=solveMICustomObjProb(obj,prob,fun,flags)






































    if flags.te
        error(message('finance:Portfolio:estimateCustomObjectivePortfolio:TENotSupportedInMIP'))
    end


    if~getSupportsAD(fun)
        error(message('finance:Portfolio:estimateCustomObjectivePortfolio:FunctionIsNotADSupported'))
    end


    nAssets=obj.NumAssets;
    solver=obj.solverMINLP;


    linFlag=false;
    quadFlag=false;
    exprType=getExprType(fun);
    if(exprType==optim.internal.problemdef.ImplType.Numeric||...
        exprType==optim.internal.problemdef.ImplType.Linear)

        linFlag=true;
    elseif exprType==optim.internal.problemdef.ImplType.Quadratic

        [H,g,g0]=extractQuadraticCoefficients(fun);

        if isempty(H)

            linFlag=true;
        else

            quadFlag=true;
        end
    end



    if~linFlag
        [~,fval]=solveContinuousCustomObjProb(obj,prob,fun,flags);
    end


    prob=addIntVarToOptimProb(obj,prob);


    if linFlag

        prob.Objective=fun;

        [sol,~,exitflag,output]=solve(prob,solver='intlinprog',...
        Options=solver.IntMasterSolverOptions);

        if exitflag<0

            error(message('finance:Portfolio:estimateCustomObjectivePortfolio:SolverMessage',...
            output.message))
        elseif exitflag==0

            warning(message('finance:Portfolio:estimateCustomObjectivePortfolio:SolverMessage',...
            output.message))
        end

        pwgt=sol.x;
        return
    end




    if strcmp(prob.ObjectiveSense,'maximize')
        fun=-fun;
        fval=-fval;
        if quadFlag
            H=-H;
            g=-g;
            g0=-g0;
        end
    end

    if quadFlag
        fval=fval-g0;
    end

    fval=fval-solver.AbsoluteGapTolerance;





    theta=optimvar('theta',1,1,'Type','continuous','LowerBound',fval);
    prob.Objective=theta;




    problem=prob2struct(prob);

    idx=varindex(prob);
    if~flags.auxVar
        idx.y=[];
        nContVar=nAssets;
    else
        nContVar=2*nAssets;
    end
    sortedIdx=[idx.x,idx.y,idx.v,idx.theta];
    nTotalVar=nContVar+nAssets;



    c=[zeros(nTotalVar,1);1];

    A=[];
    if~isempty(problem.Aineq)
        A=problem.Aineq(:,sortedIdx);
    end
    b=problem.bineq;

    Aeq=[];
    if~isempty(problem.Aeq)
        Aeq=problem.Aeq(:,sortedIdx);
    end
    beq=problem.beq;

    if isempty(problem.lb)
        lb=[-inf(nTotalVar,1);fval];
    else
        lb=problem.lb(sortedIdx);
    end

    if isempty(problem.ub)
        ub=inf(nTotalVar+1,1);
    else
        ub=problem.ub(sortedIdx);
    end

    intVar=(nContVar+1):(nContVar+nAssets);

    x0=[];


    if quadFlag

        cutsFcnHandle=@(x)QPCuts(x,H,g);


        quadOptions=getQuadprogOptions(obj);

        [~,status]=chol(H+(nAssets*eps)*eye(nAssets));
        if status~=0
            error(message('finance:Portfolio:estimateCustomObjectivePortfolio:NonConvexityInMIP'))
        end

        [iH,jH,vH]=find(H);
        H=sparse(iH,jH,vH,nTotalVar,nTotalVar)*solver.ObjectiveScalingFactor;
        [ig,jg,vg]=find(g);
        g=sparse(ig,jg,vg,nTotalVar,1)*solver.ObjectiveScalingFactor;

        NLPFcnHandle=@(intVar,x0)quadprog(2*H,g,A(:,1:end-1),b,...
        Aeq(:,1:end-1),beq,[lb(1:end-1-nAssets);intVar],...
        [ub(1:end-1-nAssets);intVar],x0,quadOptions);
    else

        [f,params]=optimexpr2fcn(fun,'objective',true,false,'reverseAD');
        cutsFcnHandle=@(x)NLPCuts(x,f,params);


        nonLinObj=@(x)fminconObjectiveFunction(x,f,params,nAssets,...
        solver.ObjectiveScalingFactor);
        nonLinCon=[];
        fminconOptions=getFminconOptions(obj);

        NLPFcnHandle=@(intVar,x0)fmincon(nonLinObj,x0,A(:,1:end-1),b,...
        Aeq(:,1:end-1),beq,[lb(1:end-1-nAssets);intVar],...
        [ub(1:end-1-nAssets);intVar],nonLinCon,fminconOptions);
    end



    orig_state=warning;
    cleanup=onCleanup(@()warning(orig_state));
    warning('off','optimlib:fmincon:ConvertingToFull');

    hasExtraVars=true;

    linearRiskCoef=[];

    [x,~,exitflag]=solver.solve(cutsFcnHandle,nAssets,c,A,b,Aeq,beq,...
    lb,ub,hasExtraVars,x0,intVar,NLPFcnHandle,linearRiskCoef);


    if exitflag<0

        error(message('finance:Portfolio:estimateCustomObjectivePortfolio:InfeasibleProblem'))
    elseif exitflag==0

        warning(message('finance:Portfolio:estimateCustomObjectivePortfolio:FailedToConverge',...
        obj.solverTypeMINLP))
    elseif any(strcmpi(solver.Display,{'final','iter'}))

        if exitflag==2

            fprintf('\n%s\n\n',getString(message('finance:Portfolio:estimateCustomObjectivePortfolio:AbsAndRelErrorStalled')))
        elseif exitflag==3

            fprintf('\n%s\n\n',getString(message('finance:Portfolio:estimateCustomObjectivePortfolio:StableIntegerVariables')))
        end
    end


    pwgt=x(1:nAssets);

    function[val,gradf]=QPCuts(x,H,g)

        val=x'*H*x+g'*x;
        gradf=2*H*x+g;

        function[val,gradf]=NLPCuts(x,f,params)

            [val,gradf]=f(x,params);

            function[val,gradf]=fminconObjectiveFunction(x,f,params,nAssets,scaling)




                w=x(1:nAssets);
                [val,gradf]=f(w,params);


                val=scaling*val;
                gradf=scaling*gradf;


                n=size(x,1);
                nPadding=n-nAssets;
                gradf=[gradf;zeros(nPadding,1)];
