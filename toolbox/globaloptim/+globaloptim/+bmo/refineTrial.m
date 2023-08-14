function[xout,fval,eflag]=refineTrial(surrogates,x0,problem,samplingRadius,options)







    fval=[];
    xout=[];
    eflag=[];

    if~verify_surrogate_x0(problem,surrogates,x0)

        if options.Verbosity>=3
            disp('Surrogate did not evaluate to a real number at x0.');
            disp('Not running the NLP solver.');
        end
        return;
    end

    if~isempty(samplingRadius)

        problem.lb=max(problem.lb,x0'-samplingRadius/2);
        problem.ub=min(problem.ub,x0'+samplingRadius/2);
    end


    globaloptim.bmo.surrogateNLPsolver;




    globaloptim.bmo.surrogateNLPsolver(problem.nobj_expensive,...
    problem.mineq_expensive,surrogates,options,...
    problem.intcon,struct('RoundingHeurisics',true));

    if options.Verbosity>=3&&numel(x0)>300
        fprintf('Using (MI)NLP solver for local search; this may take some time.\n');
    end

    if isempty(problem.intcon)
        try

            solution=globaloptim.bmo.surrogateNLPsolver(x0,problem.lb,problem.ub,...
            problem.Aineq,problem.bineq,problem.Aeq,problem.beq);

            eflag=solution.exitflag;
            if eflag>=0
                xout=solution.x;
            end
        catch ME
            xout=[];
            eflag=[];
            if options.Verbosity>=3
                disp(ME);
            end
        end
    else

        [xout,eflag]=solveSurrogateBB(x0,problem,options);
    end


    globaloptim.bmo.surrogateNLPsolver;

end

function[xout,eflag]=solveSurrogateBB(x0,problem,options)


    input.ProbData=problem;
    input.ProbData.x0=x0;
    input.ProbData.fixedID=find(problem.fixedID)-1;

    input.NodeOptions=options.NodeOptions;
    input.TreeSearchOptions=options.TreeSearchOptions;

    try

        solution=globaloptim.internal.mexfiles.mx_SurrogateMINLP(input);
        if~isempty(solution.x)
            xout=reshape(solution.x,size(x0));
            eflag=1;
        else
            xout=[];
            eflag=[];
        end
    catch ME
        xout=[];
        eflag=[];
        if options.Verbosity>=3
            disp(ME);
        end
    end

end

function TF=verify_surrogate_x0(problem,surrogates,x0)




    TF=true;
    if problem.nobj_expensive>0
        objSurrogate=@(x)surrogates(x,'Fval');
        fval=objSurrogate(x0);
        TF=TF&&~any(isnan(fval));
    end

    if problem.mineq_expensive>0
        constrSurrogates=@(x)surrogates(x,'Ineq');
        ineq=constrSurrogates(x0);
        TF=TF&&~any(isnan(ineq));
    end

end

