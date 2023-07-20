function[pwgt,fval,exitflag]=solveContinuousCustomObjProb(obj,prob,fun,flags)




































    prob.Objective=fun;


    linFlag=false;
    quadFlag=false;
    exprType=getExprType(fun);
    if((exprType==optim.internal.problemdef.ImplType.Numeric||...
        exprType==optim.internal.problemdef.ImplType.Linear)&&~flags.te)

        linFlag=true;
    elseif(exprType==optim.internal.problemdef.ImplType.Quadratic&&~flags.te)

        quadFlag=true;
    end




    if quadFlag

        [sol,fval,exitflag,output]=solve(prob,Solver='quadprog',...
        Options=obj.getQuadprogOptions);

        if exitflag<0&&exitflag~=-6

            error(message('finance:Portfolio:estimateCustomObjectivePortfolio:SolverMessage',...
            output.message))
        elseif exitflag~=-6
            if exitflag==0

                warning(message('finance:Portfolio:estimateCustomObjectivePortfolio:SolverMessage',...
                output.message))
            end

            pwgt=sol.x;
            return
        end
    end


    if linFlag

        [sol,fval,exitflag,output]=solve(prob,Solver='linprog',...
        Options=obj.solverOptionsLP);
    else




        x0.x=1/obj.NumAssets*ones(obj.NumAssets,1);
        if flags.auxVar
            initPort=obj.InitPort;
            if isempty(initPort)
                initPort=zeros(obj.NumAssets,1);
            end
            x0.y=max(0,x0.x-initPort);
        end





        options=obj.getFminconOptions;
        options.SpecifyConstraintGradient=false;
        options.SpecifyObjectiveGradient=false;


        orig_state=warning;
        cleanup=onCleanup(@()warning(orig_state));
        warning('off','optim_problemdef:OptimizationProblem:solve:SpecifyGradientIgnored');


        [sol,fval,exitflag,output]=solve(prob,x0,Solver="fmincon",...
        Options=options);
    end


    if exitflag<0

        error(message('finance:Portfolio:estimateCustomObjectivePortfolio:SolverMessage',...
        output.message))
    elseif exitflag==0

        warning(message('finance:Portfolio:estimateCustomObjectivePortfolio:SolverMessage',...
        output.message))
    end


    pwgt=sol.x;