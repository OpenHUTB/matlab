function tolFunValue=getFunctionToleranceForSolve(solver,varargin)



    TolFunAtDefault=true;
    nOpt=numel(varargin);
    for i=1:nOpt
        if strcmp(varargin{i},'Options')
            opts=varargin{i+1};
            if isstruct(opts)
                if isfield(opts,'FunctionTolerance')
                    tolFunValue=opts.FunctionTolerance;
                    TolFunAtDefault=false;
                elseif isfield(opts,'TolFunValue')
                    tolFunValue=opts.TolFunValue;
                    TolFunAtDefault=false;
                end
            elseif(isa(opts,'optim.options.Fsolve')||...
                isa(opts,'optim.options.Lsqnonlin')||...
                isa(opts,'optim.options.Lsqlin'))
                tolFunValue=opts.FunctionTolerance;
                TolFunAtDefault=false;
            end
            break
        end
    end
    if TolFunAtDefault
        opts=optimoptions(solver);
        tolFunValue=opts.FunctionTolerance;
    end
