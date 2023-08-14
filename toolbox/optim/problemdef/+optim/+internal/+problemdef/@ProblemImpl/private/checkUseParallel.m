function useParallel=checkUseParallel(options,globalSolver)








    useParallel=false;

    if~isempty(options)&&(isa(options,'optim.options.SolverOptions')...
        &&(isa(options,'optim.options.Fmincon')||isa(options,'optim.options.Fminunc')...
        ||isa(options,'optim.options.Lsqnonlin')||isa(options,'optim.options.Lsqcurvefit')...
        ||isa(options,'optim.options.Fsolve')||isa(options,'optim.options.GacommonOptions')...
        ||isa(options,'optim.options.Paretosearch')||isa(options,'optim.options.Particleswarm')...
        ||isa(options,'optim.options.PatternsearchOptions')...
        ||isa(options,'optim.options.Surrogateopt'))...
        ||isfield(options,'UseParallel'))
        useParallel=options.UseParallel;
        if isempty(useParallel)

            useParallel=false;
        end
    end


    if~isempty(globalSolver)&&isa(globalSolver,'MultiStart')&&globalSolver.UseParallel
        useParallel=true;
    end
