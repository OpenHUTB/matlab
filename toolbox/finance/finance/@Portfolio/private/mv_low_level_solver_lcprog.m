function[x,status]=mv_low_level_solver_lcprog(H,g,A,b,solverOptions)





























    if nargin<5
        solverOptions=[];
    end

    args={};

    if~isempty(solverOptions)
        if~isempty(solverOptions.MaxIter)
            args=[args,{'MaxIter',solverOptions.MaxIter}];
        end
        if~isempty(solverOptions.TieBreak)
            args=[args,{'TieBreak',solverOptions.TieBreak}];
        end
        if~isempty(solverOptions.TolPiv)
            args=[args,{'TolPiv',solverOptions.TolPiv}];
        end
    end

    M=[H,A';-A,zeros(numel(b))];
    q=[g;b];

    if isempty(args)
        [z,~,status]=lcprog(M,q,'TolPiv',5.0e-8);
    else
        [z,~,status]=lcprog(M,q,args{:});
    end

    x=z(1:numel(g));
