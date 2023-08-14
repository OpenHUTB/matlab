function eflagImpl=createExitflagImpl(val,solver,problemType)








    if isnan(val)
        eflagImpl=optim.internal.problemdef.exitflag.ExitflagUndefinedImpl;
    else



        try
            optim.internal.problemdef.exitflag.ExitflagImpl(val);
        catch ME
            if strcmp(ME.identifier,'MATLAB:class:InvalidEnum')
                ME=MException('MATLAB:class:InvalidEnum',...
                getString(message('optim_problemdef:Exitflag:InvalidExitflag')));
            end
            throwAsCaller(ME);
        end

        switch problemType

        case 'OptimizationProblem'
            switch solver
            case{'linprog','intlinprog'}
                eflagImpl=optim.internal.problemdef.exitflag.ExitflagLPImpl;
            case 'quadprog'
                eflagImpl=optim.internal.problemdef.exitflag.ExitflagQPImpl;
            case 'ga'
                eflagImpl=globaloptim.problemdef.internal.exitflag.ExitflagGAImpl;
            case 'surrogateopt'
                eflagImpl=globaloptim.problemdef.internal.exitflag.ExitflagSurrogateoptImpl;
            case 'simulannealbnd'
                eflagImpl=globaloptim.problemdef.internal.exitflag.ExitflagSimulannealbndImpl;
            case{'gamultiobj','patternsearch','paretosearch','particleswarm'}
                eflagImpl=globaloptim.problemdef.internal.exitflag.ExitflagGlobalSolverImpl;
            case{'MultiStart','GlobalSearch'}
                eflagImpl=globaloptim.problemdef.internal.exitflag.ExitflagMultipleStartPointsSolverImpl;
            otherwise
                eflagImpl=optim.internal.problemdef.exitflag.ExitflagSolverImpl;
            end

        case 'EquationProblem'
            switch solver
            case 'fzero'
                eflagImpl=optim.internal.problemdef.exitflag.ExitflagFzeroImpl;
            case 'fsolve'
                eflagImpl=optim.internal.problemdef.exitflag.ExitflagFsolveImpl;
            otherwise
                eflagImpl=optim.internal.problemdef.exitflag.ExitflagEqnImpl;
            end

        otherwise

            eflagImpl=optim.internal.problemdef.exitflag.ExitflagUndefinedImpl;

        end
    end

    eflagImpl.Solver=solver;
    eflagImpl.ProblemType=problemType;

end