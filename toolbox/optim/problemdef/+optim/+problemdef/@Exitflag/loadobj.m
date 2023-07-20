function exout=loadobj(exin)










    if isstruct(exin)&&~isfield(exin,'ExitflagVersion')

        problemType=repmat("OptimizationProblem",numel(exin.Data),1);
        exout=optim.problemdef.Exitflag(exin.Data,exin.Solver,problemType);
    else
        exout=exin;
    end
